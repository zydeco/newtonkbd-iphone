//
//  NewtonPassword.h
//  NewtComm
//
//  Created by Zydeco on 2009-11-17.
//  Copyright 2009 namedfork.net. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NewtonPassword : NSObject {

}

+ (BOOL)verifyPassword:(NSString*)inPassword encrypted:(const uint32_t*)encrypted challenge:(const uint32_t*)challenge;
+ (NSValue*)encryptPassword:(NSString*)inPassword challenge:(const uint32_t*)challenge;

@end
