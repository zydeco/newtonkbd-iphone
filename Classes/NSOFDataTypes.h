//
//  NSOFDataTypes.h
//  NewtComm
//
//  Created by Zydeco on 2009-11-17.
//  Copyright 2009 namedfork.net. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSOFSymbol : NSObject {
    char *_name;
    NSUInteger _len;
}
+ (id)symbolWithString:(NSString*)str;
+ (id)symbolWithCString:(const char *)cstr;
- (id)initWithString:(NSString*)str;
- (id)initWithCString:(const char *)cstr;
- (BOOL)isEqual:(id)anObject;
- (NSUInteger)length;
- (const char *)bytes;
@end

@interface NSValue (NSOSFAdditions)
+ (id)valueWithCharacter:(char)value;
- (id)initWithCharacter:(char)value;
+ (id)valueWithUnicodeCharacter:(unichar)value;
- (id)initWithUnicodeCharacter:(unichar)value;
@end

@interface NSOFBinaryObject : NSObject {
    NSData      *data;
    NSString    *className;
}
+ (id)binaryObjectWithClassName:(NSString*)className data:(NSData*)data;
+ (id)binaryObjectWithClassName:(NSString*)className bytes:(const void*)data length:(NSUInteger)length;
+ (id)binaryObjectWithClassName:(NSString*)className bytesNoCopy:(void*)bytes length:(NSUInteger)length;
+ (id)binaryObjectWithClassName:(NSString*)className bytesNoCopy:(void*)bytes length:(NSUInteger)length freeWhenDone:(BOOL)freeWhenDone;
- (id)initWithClassName:(NSString*)newClassName data:(NSData*)data;
- (id)initWithClassName:(NSString*)newClassName bytes:(const void*)bytes length:(NSUInteger)length;
- (id)initWithClassName:(NSString*)newClassName bytesNoCopy:(void*)bytes length:(NSUInteger)length;
- (id)initWithClassName:(NSString*)newClassName bytesNoCopy:(void*)bytes length:(NSUInteger)length freeWhenDone:(BOOL)freeWhenDone;
@property (nonatomic, readonly) NSString* nsofClassName;
@property (nonatomic, readonly) const void * bytes;
@property (nonatomic, readonly) NSUInteger length;
@end

@interface NSOFSmallRect : NSObject {
    uint8_t values[4]; // top,left,bottom,right
}
+ (id)smallRectWithTop:(uint8_t)top left:(uint8_t)left bottom:(uint8_t)bottom right:(uint8_t)right;
+ (id)smallRectWithRect:(CGRect)rect;
- (id)initWithTop:(uint8_t)top left:(uint8_t)left bottom:(uint8_t)bottom right:(uint8_t)right;
- (id)initWithRect:(CGRect)rect;
- (const void*)values;
@end