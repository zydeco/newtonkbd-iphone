/*
 * The contents of this file are subject to the Mozilla Public License Version
 * 1.1 (the "License"); you may not use this file except in compliance with
 * the License. You may obtain a copy of the License at 
 * http://www.mozilla.org/MPL/
 * 
 * Software distributed under the License is distributed on an "AS IS" basis,
 * WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License
 * for the specific language governing rights and limitations under the 
 * License.
 * 
 * The Original Code is NSOFDataTypes.h.
 * 
 * The Initial Developer of the Original Code is Jesús A. Álvarez.
 * Portions created by the Initial Developer are Copyright 
 * (C) 2009 namedfork.net. All Rights Reserved.
 * 
 * Contributor(s):
 *     Jesús A. Álvarez <zydeco@namedfork.net> (original author)
 * 
 */

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