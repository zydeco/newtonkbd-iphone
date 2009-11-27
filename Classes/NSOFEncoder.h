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
 * The Original Code is NSOFEncoder.h.
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
#import "NSOFDataTypes.h"

#define kNSOFVersion 2

enum {
    NSOFTagImmediate,
    NSOFTagCharacter,
    NSOFTagUnicodeCharacter,
    NSOFTagBinaryObject,
    NSOFTagArray,
    NSOFTagPlainArray,
    NSOFTagFrame,
    NSOFTagSymbol,
    NSOFTagString,
    NSOFTagPrecedent,
    NSOFTagNIL,
    NSOFTagSmallRect,
    NSOFTagLargeBinary,
} NSOFTag;

@interface NSOFEncoder : NSObject {
    NSMutableData   *data;
    NSMutableArray  *pObjects;
}

+ (NSData*)encodeObject:(id)obj;
@end
