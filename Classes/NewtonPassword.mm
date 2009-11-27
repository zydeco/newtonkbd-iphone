//
//  NewtonPassword.m
//  NewtComm
//
//  Created by Zydeco on 2009-11-17.
//  Copyright 2009 namedfork.net. All rights reserved.
//

#import "NewtonPassword.h"
#import "UDES.h"

@implementation NewtonPassword

+ (BOOL)verifyPassword:(NSString*)inPassword encrypted:(uint32_t*)encrypted challenge:(const uint32_t*)challenge {
    NSValue *encValue = [NSValue valueWithBytes:encrypted objCType:@encode(uint32_t[2])];
    NSValue *myValue = [NewtonPassword encryptPassword:inPassword challenge:challenge];
    return [encValue isEqualToValue:myValue];
}

+ (NSValue*)encryptPassword:(NSString*)inPassword challenge:(const uint32_t*)challenge {
    KUInt64 mCipheredPassword = (((uint64_t)challenge[0]) << 32) | ((uint64_t)challenge[1]);
    
	// Set the pointer to the password string. If we have nil, I get a pointer to 0.
	UInt16 theEmptyStr = 0;
	UInt16* thePasswordString;
	if (inPassword)
	{
        thePasswordString = (UInt16*)calloc([inPassword length]+1, sizeof(UInt16));
        thePasswordString[[inPassword length]] = 0;
        [inPassword getCharacters:thePasswordString range:NSMakeRange(0, [inPassword length])];
	} else {
		thePasswordString = &theEmptyStr;
	}
    thePasswordString = &theEmptyStr;
    
	// Decode the plain data with the password.
	KUInt64 theKey;
	UDES::CreateNewtonKey( thePasswordString, &theKey );
    if (thePasswordString!=&theEmptyStr) free(thePasswordString);    
	UDES:: NewtonEncodeBlock( theKey, &mCipheredPassword );
    
    uint32_t mPasswordLongs[2] = {mCipheredPassword>>32, mCipheredPassword};
    return [NSValue valueWithBytes:mPasswordLongs objCType:@encode(uint32_t[2])];
}
@end
