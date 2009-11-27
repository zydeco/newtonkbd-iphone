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
 * The Original Code is NewtonInfo.h.
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


@interface NewtonInfo : NSObject {
    uint32_t      newtonUniqueID, manufacturerID, machineType, romVersion, romStage, ramSize, screenHeight, screenWidth, systemUpdateVersion, objectSystemVersion, internalStoreSignature, vScreenRes, hScreenRes, screenDepth;
    NSString    *ownerName;
}

@property (nonatomic, assign) uint32_t newtonUniqueID;
@property (nonatomic, assign) uint32_t manufacturerID;
@property (nonatomic, assign) uint32_t machineType;
@property (nonatomic, assign) uint32_t romVersion;
@property (nonatomic, assign) uint32_t romStage;
@property (nonatomic, assign) uint32_t ramSize;
@property (nonatomic, assign) uint32_t screenHeight;
@property (nonatomic, assign) uint32_t screenWidth;
@property (nonatomic, assign) uint32_t systemUpdateVersion;
@property (nonatomic, assign) uint32_t objectSystemVersion;
@property (nonatomic, assign) uint32_t internalStoreSignature;
@property (nonatomic, assign) uint32_t vScreenRes;
@property (nonatomic, assign) uint32_t hScreenRes;
@property (nonatomic, assign) uint32_t screenDepth;
@property (nonatomic, copy) NSString *ownerName;

- (id)initWithData:(NSData*)data;

@end
