//
//  NewtonInfo.h
//  NewtComm
//
//  Created by Zydeco on 2009-11-17.
//  Copyright 2009 namedfork.net. All rights reserved.
//

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
