//
//  NSOFDataTypes.m
//  NewtComm
//
//  Created by Zydeco on 2009-11-17.
//  Copyright 2009 namedfork.net. All rights reserved.
//

#import "NSOFDataTypes.h"


@implementation NSOFSymbol
+ (id)symbolWithString:(NSString*)str {
    return [[[NSOFSymbol alloc] initWithString:str] autorelease];
}

+ (id)symbolWithCString:(const char *)cstr {
    return [[[NSOFSymbol alloc] initWithCString:cstr] autorelease];
}

- (id)initWithString:(NSString*)str {
    return [self initWithCString:[str cStringUsingEncoding:NSASCIIStringEncoding]];
}

- (id)initWithCString:(const char *)cstr {
    if (cstr == NULL) return nil;
    if ((self = [super init])) {
        _name = strdup(cstr);
        _len = strlen(cstr);
    }
    return self;
}

- (BOOL)isEqual:(id)anObject {
    if (anObject == nil) return NO;
    if (![anObject isMemberOfClass:[NSOFSymbol class]]) return NO;
    if (strcmp(_name, ((NSOFSymbol*)anObject)->_name) == 0) return YES;
    return NO;
}

- (void)dealloc {
    if (_name) free(_name);
    [super dealloc];
}

- (NSUInteger)length {
    return _len;
}

- (const char *)bytes {
    return _name;
}

- (NSString*)description {
    return [NSString stringWithFormat:@"'%s", _name];
}

@end

@implementation NSValue (NSOSFAdditions)
+ (id)valueWithCharacter:(char)value {
    return [NSValue valueWithBytes:&value objCType:@encode(unsigned char)];
}

- (id)initWithCharacter:(char)value {
    return [self initWithBytes:&value objCType:@encode(unsigned char)];
}
+ (id)valueWithUnicodeCharacter:(unichar)value {
    return [NSValue valueWithBytes:&value objCType:@encode(unichar)];
}

- (id)initWithUnicodeCharacter:(unichar)value {
    return [self initWithBytes:&value objCType:@encode(unichar)];
}
@end

@implementation NSOFBinaryObject
@synthesize nsofClassName = className;
+ (id)binaryObjectWithClassName:(NSString*)className data:(NSData*)data {
    return [[[NSOFBinaryObject alloc] initWithClassName:className data:data] autorelease];
}

+ (id)binaryObjectWithClassName:(NSString*)className bytes:(const void*)bytes length:(NSUInteger)length {
    return [[[NSOFBinaryObject alloc] initWithClassName:className bytes:bytes length:length] autorelease];
}

+ (id)binaryObjectWithClassName:(NSString*)className bytesNoCopy:(void*)bytes length:(NSUInteger)length {
    return [[[NSOFBinaryObject alloc] initWithClassName:className bytesNoCopy:bytes length:length] autorelease];
}

+ (id)binaryObjectWithClassName:(NSString*)className bytesNoCopy:(void*)bytes length:(NSUInteger)length freeWhenDone:(BOOL)freeWhenDone {
    return [[[NSOFBinaryObject alloc] initWithClassName:className bytesNoCopy:bytes length:length freeWhenDone:freeWhenDone] autorelease];
}

- (id)initWithClassName:(NSString*)newClassName data:(NSData*)newData {
    if ((self = [super init])) {
        data = [[NSData alloc] initWithData:newData];
        className = [newClassName copy];
    }
    return self;
}

- (id)initWithClassName:(NSString*)newClassName bytes:(const void*)bytes length:(NSUInteger)length {
    if ((self = [super init])) {
        data = [[NSData alloc] initWithBytes:bytes length:length];
        className = [newClassName copy];
    }
    return self;
}

- (id)initWithClassName:(NSString*)newClassName bytesNoCopy:(void*)bytes length:(NSUInteger)length {
    if ((self = [super init])) {
        data = [[NSData alloc] initWithBytesNoCopy:bytes length:length];
        className = [newClassName copy];
    }
    return self;
}

- (id)initWithClassName:(NSString*)newClassName bytesNoCopy:(void*)bytes length:(NSUInteger)length freeWhenDone:(BOOL)b {
    if ((self = [super init])) {
        data = [[NSData alloc] initWithBytesNoCopy:bytes length:length freeWhenDone:b];
        className = [newClassName copy];
    }
    return self;
}

- (NSUInteger)length {
    return data.length;
}

- (const void *)bytes {
    return data.bytes;
}

- (NSString*)description {
    return [NSString stringWithFormat:@"{%@: %@}", className, data];
}

- (void)dealloc {
    [data release];
    [className release];
    [super dealloc];
}
@end

@implementation NSOFSmallRect
+ (id)smallRectWithTop:(uint8_t)top left:(uint8_t)left bottom:(uint8_t)bottom right:(uint8_t)right {
    return [[[NSOFSmallRect alloc] initWithTop:top left:left bottom:bottom right:right] autorelease];
}

- (id)initWithTop:(uint8_t)top left:(uint8_t)left bottom:(uint8_t)bottom right:(uint8_t)right {
    if ((self = [super init])) {
        values[0] = top;
        values[1] = left;
        values[2] = bottom;
        values[3] = right;
    }
    return self;
}

+ (id)smallRectWithRect:(CGRect)rect {
    return [NSOFSmallRect smallRectWithTop:(uint8_t)rect.origin.y left:(uint8_t)rect.origin.x bottom:(uint8_t)(rect.origin.y+rect.size.height) right:(uint8_t)(rect.origin.x+rect.size.width)];
}

- (id)initWithRect:(CGRect)rect {
    return [self initWithTop:(uint8_t)rect.origin.y left:(uint8_t)rect.origin.x bottom:(uint8_t)(rect.origin.y+rect.size.height) right:(uint8_t)(rect.origin.x+rect.size.width)];
}

- (NSString*)description {
    return [NSString stringWithFormat:@"{left: %d, top: %d, right: %d, botom: %d}", values[1], values[0], values[3], values[2]];
}

- (const void*)values {
    return values;
}

@end