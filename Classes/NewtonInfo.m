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
 * The Original Code is NewtonInfo.m.
 * 
 * The Initial Developer of the Original Code is Jesús A. Álvarez.
 * Portions created by the Initial Developer are Copyright 
 * (C) 2009 namedfork.net. All Rights Reserved.
 * 
 * Contributor(s):
 *     Jesús A. Álvarez <zydeco@namedfork.net> (original author)
 * 
 */

#import "NewtonInfo.h"


@implementation NewtonInfo

@synthesize newtonUniqueID, manufacturerID, machineType, romVersion, romStage, ramSize, screenHeight, screenWidth, systemUpdateVersion, objectSystemVersion, internalStoreSignature, vScreenRes, hScreenRes, screenDepth, ownerName;

- (id)initWithData:(NSData*)data {
    if ((self = [super init])) {
        const uint32_t * dataLongs = data.bytes;
        if (OSSwapBigToHostInt32(dataLongs[0]) < 56) {
            NSLog(@"[NewtonInfo initWithData:%@]: not enough data", data);
            [self release];
            return nil;
        }
        // get name
        const uint16_t * nameChars = (data.bytes+4+OSSwapBigToHostInt32(dataLongs[0]));
        NSUInteger nameLength = -1;
        while(nameChars[++nameLength]) {};
        self.ownerName = [[[NSString alloc] initWithBytes:nameChars length:2*nameLength encoding: NSUTF16BigEndianStringEncoding] autorelease];
        
        // get other properties
        int i = 1;
        self.newtonUniqueID = OSSwapBigToHostInt32(dataLongs[i++]);
        self.manufacturerID = OSSwapBigToHostInt32(dataLongs[i++]);
        self.machineType = OSSwapBigToHostInt32(dataLongs[i++]);
        self.romVersion = OSSwapBigToHostInt32(dataLongs[i++]);
        self.romStage = OSSwapBigToHostInt32(dataLongs[i++]);
        self.ramSize = OSSwapBigToHostInt32(dataLongs[i++]);
        self.screenHeight = OSSwapBigToHostInt32(dataLongs[i++]);
        self.screenWidth = OSSwapBigToHostInt32(dataLongs[i++]);
        self.systemUpdateVersion = OSSwapBigToHostInt32(dataLongs[i++]);
        self.objectSystemVersion = OSSwapBigToHostInt32(dataLongs[i++]);
        self.internalStoreSignature = OSSwapBigToHostInt32(dataLongs[i++]);
        self.vScreenRes = OSSwapBigToHostInt32(dataLongs[i++]);
        self.hScreenRes = OSSwapBigToHostInt32(dataLongs[i++]);
        self.screenDepth = OSSwapBigToHostInt32(dataLongs[i++]);
    }
    return self;
}

- (void)dealloc {
    [ownerName autorelease];
    [super dealloc];
}

@end
