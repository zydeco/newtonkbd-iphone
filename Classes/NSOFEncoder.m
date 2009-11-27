//
//  NSOFEncoder.m
//  NewtComm
//
//  Created by Zydeco on 2009-11-17.
//  Copyright 2009 namedfork.net. All rights reserved.
//

#import "NSOFEncoder.h"
#import "NSOFDataTypes.h"

@interface NSOFEncoder ()
- (BOOL)_addObject:(id)obj;
- (BOOL)_canHasPrecedent:(id)obj;
- (BOOL)_cantHavePrecedent:(id)obj;
- (BOOL)_addPObject:(id)obj;
- (BOOL)_addNPObject:(id)obj;
- (BOOL)_addPrecedent:(NSUInteger)num;
- (void)_appendByte:(uint8_t)b;
- (void)_appendHalfword:(uint16_t)hw;
- (void)_appendLong:(uint32_t)l;
- (void)_appendXLong:(uint32_t)xl;
- (BOOL)_canEncodeObject:(id)obj;
@end

@implementation NSOFEncoder

+ (NSData*)encodeObject:(id)obj {
    NSOFEncoder *encoder = [[NSOFEncoder alloc] init];
    if (![encoder _canEncodeObject:obj]) {
        NSLog(@"Can't encode %@", obj);
        [encoder release];
        return nil;
    }
    [encoder _addObject:obj];
    NSData *data = [[NSData dataWithData:encoder->data] retain];
    [encoder release];
    return [data autorelease];
}

- (id)init {
    if ((self = [super init])) {
        data = [[NSMutableData alloc] initWithCapacity:64];
        pObjects = [[NSMutableArray alloc] initWithCapacity:8];
        
        // add NSOF version
        uint8_t version = kNSOFVersion;
        [data appendBytes:&version length:1];
    }
    return self;
}

- (void)dealloc {
    [pObjects release];
    [data release];
    [super dealloc];
}

- (BOOL)_addObject:(id)obj {
    if ([self _canHasPrecedent:obj]) {
        NSUInteger prec = [pObjects indexOfObject:obj];
        if (prec == NSNotFound) return [self _addPObject:obj];
        else return [self _addPrecedent:prec];
    } else if ([self _cantHavePrecedent:obj]) {
        return [self _addNPObject:obj];
    } else return NO;
}

- (BOOL)_canHasPrecedent:(id)obj {
    if ([obj isKindOfClass:[NSOFBinaryObject class]]) return YES;
    if ([obj isKindOfClass:[NSArray class]]) return YES;
    if ([obj isKindOfClass:[NSDictionary class]]) return YES;
    if ([obj isKindOfClass:[NSString class]]) return YES;
    if ([obj isKindOfClass:[NSOFSmallRect class]]) return YES;
    if ([obj isKindOfClass:[NSOFSymbol class]]) return YES;
    return NO;
}

- (BOOL)_cantHavePrecedent:(id)obj {
    if ([obj isKindOfClass:[NSNumber class]]) return YES; // immediate integer
    if ([obj isKindOfClass:[NSNull class]]) return YES; // NIL
    if ([obj isKindOfClass:[NSValue class]]) return YES; // character, unicode character
    return NO;
}

- (BOOL)_addPObject:(id)obj {
    // add object assigning a precedent
    [pObjects addObject:obj];
    //NSLog(@"Added %@ with precedent %d", [obj className], [pObjects count]-1);
    if ([obj isKindOfClass:[NSOFBinaryObject class]]) {
        // binary object
        [self _appendByte:NSOFTagBinaryObject];
        // length
        [self _appendXLong:[obj length]];
        // class name
        [self _addPObject:[NSOFSymbol symbolWithString:[obj nsofClassName]]];
        // binary data
        [data appendBytes:[obj bytes] length:[obj length]];
    } else if ([obj isKindOfClass:[NSArray class]]) {
        // plain array (FIXME when is it not?)
        [self _appendByte:NSOFTagPlainArray];
        // number of slots
        [self _appendXLong:[obj count]];
        // values
        for(id item in obj) [self _addObject:item];
    } else if ([obj isKindOfClass:[NSDictionary class]]) {
        // frame
        [self _appendByte:NSOFTagFrame];
        // number of slots
        [self _appendXLong:[obj count]];
        id objects[[obj count]], keys[[obj count]]; // srsly wtf
        [obj getObjects:objects andKeys:keys];
        // keys (symbols)
        for(int i=0; i<[obj count]; i++) {
            if ([keys[i] isKindOfClass:[NSString class]]) {
                [self _addObject:[NSOFSymbol symbolWithString:keys[i]]];
            } else if ([keys[i] isKindOfClass:[NSOFSymbol class]]) {
                [self _addObject:keys[i]];
            }
        }
        // values
        for(int i=0; i<[obj count]; i++) [self _addObject:objects[i]];
    } else if ([obj isKindOfClass:[NSOFSymbol class]]) {
        // symbol
        [self _appendByte:NSOFTagSymbol];
        // length
        uint32_t len = [obj length];
        [self _appendXLong:len];
        // data
        [data appendBytes:[obj bytes] length:len];
    } else if ([obj isKindOfClass:[NSString class]]) {
        // string
        [self _appendByte:NSOFTagString];
        // length in  bytes
        NSData *strData = [obj dataUsingEncoding:NSUTF16BigEndianStringEncoding];
        [self _appendXLong:strData.length+2];
        // string in big-endian UTF16
        [data appendData:strData];
        // unicode null terminator
        [self _appendByte:0];
        [self _appendByte:0];
    } else if ([obj isKindOfClass:[NSOFSmallRect class]]) {
        // small rect
        [self _appendByte:NSOFTagSmallRect];
        // values
        [data appendBytes:[(NSOFSmallRect*)obj values] length:4];
    } else return NO;
    return YES;
}

- (BOOL)_addNPObject:(id)obj {
    // add object without assigning precedent
    //NSLog(@"Added unprecedentable %@: %@", [obj className], obj);
    if ([obj isKindOfClass:[NSNull class]]) {
        // NIL value
        [self _appendByte:NSOFTagNIL];
    } else if ([obj isKindOfClass:[NSNumber class]]) {
        // immediate integer
        [self _appendByte:NSOFTagImmediate];
        [self _appendXLong:([obj intValue]<<2)];
    } else if ([obj isKindOfClass:[NSValue class]]) {
        if (0 == strcmp([obj objCType],@encode(unichar))) {
            // unicode character
            unichar uc;
            [obj getValue:&uc];
            [self _appendByte:NSOFTagUnicodeCharacter];
            [self _appendByte:(uc >> 8)];
            [self _appendByte:(uc & 0xFF)];
        } else if (0 == strcmp([obj objCType],@encode(unsigned char))) {
            // character
            uint8_t c;
            [obj getValue:&c];
            [self _appendByte:NSOFTagCharacter];
            [self _appendByte:c];
        }
    }
    // FIXME: immediate NIL, character, TRUE, and magicptr
    return YES;
}

- (BOOL)_addPrecedent:(NSUInteger)num {
    // add precedent
    [self _appendByte:NSOFTagPrecedent];
    [self _appendXLong:num];
    return YES;
}

- (void)_appendByte:(uint8_t)b {
    [data appendBytes:&b length:1];
}
- (void)_appendHalfword:(uint16_t)hw {
    uint16_t hw_be = OSSwapHostToBigInt16(hw);
    [data appendBytes:&hw_be length:2];
}
- (void)_appendLong:(uint32_t)l {
    uint32_t l_be = OSSwapHostToBigInt32(l);
    [data appendBytes:&l_be length:4];
}

- (void)_appendXLong:(uint32_t)xl {
    if (0 <= xl && xl <= 254) {
        [self _appendByte:(uint8_t)xl];
    } else {
        [self _appendByte:0xFF];
        [self _appendLong:xl];
    }
}

- (BOOL)_canEncodeObject:(id)obj {
    if ([obj isKindOfClass:[NSNumber class]]) return YES; // immediate integer
    if ([obj isKindOfClass:[NSValue class]]) {
        if (0 == strcmp([obj objCType],@encode(unichar))) return YES; // unicode character
        if (0 == strcmp([obj objCType],@encode(unsigned char))) return YES; // character
        return NO; // unknown value
    }
    if ([obj isKindOfClass:[NSOFBinaryObject class]]) return YES; // binary object
    if ([obj isKindOfClass:[NSArray class]]) {
        // could be plain array, check elements
        for(id elem in obj) if (![self _canEncodeObject:elem]) return NO;
        return YES;
    }
    if ([obj isKindOfClass:[NSDictionary class]]) {
        // could be frame, check keys and values
        for(id elem in [obj allKeys]) {
            // keys must be strings or symbols
            if (!([elem isKindOfClass:[NSString class]]||[elem isKindOfClass:[NSOFSymbol class]])) return NO;
        }
        for(id elem in [obj allValues]) if (![self _canEncodeObject:elem]) return NO;
        return YES;
    }
    if ([obj isKindOfClass:[NSOFSymbol class]]) return YES; // symbol
    if ([obj isKindOfClass:[NSString class]]) return YES; // string
    if ([obj isKindOfClass:[NSNull class]]) return YES; // NIL
    if ([obj isKindOfClass:[NSOFSmallRect class]]) return YES; // small rect
    return NO;
}

@end
