//
//  NSOFEncoder.h
//  NewtComm
//
//  Created by Zydeco on 2009-11-17.
//  Copyright 2009 namedfork.net. All rights reserved.
//

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
