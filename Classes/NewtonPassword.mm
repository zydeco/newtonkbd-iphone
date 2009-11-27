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
 * The Original Code is NewtonPassword.mm.
 * 
 * The Initial Developer of the Original Code is Jesús A. Álvarez.
 * Portions created by the Initial Developer are Copyright 
 * (C) 2009 namedfork.net. All Rights Reserved.
 * 
 * Contributor(s):
 *     Jesús A. Álvarez <zydeco@namedfork.net> (original author)
 * 
 */

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
