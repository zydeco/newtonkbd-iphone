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
 * The Original Code is NewtonConnection.m.
 * 
 * The Initial Developer of the Original Code is Jesús A. Álvarez.
 * Portions created by the Initial Developer are Copyright 
 * (C) 2009 namedfork.net. All Rights Reserved.
 * 
 * Contributor(s):
 *     Jesús A. Álvarez <zydeco@namedfork.net> (original author)
 * 
 */

#import "NewtonConnection.h"
#import "MNPPipe.h"
#import "NSOFEncoder.h"
#include "NewtonPassword.h"

#include <termios.h>
#include <fcntl.h>
#include <objc/runtime.h>

#define OSTypeToChars(_t) (char)(_t>>24),(char)((_t>>16)&0xFF),(char)((_t>>8)&0xFF),(char)(_t&0xFF)

@interface NewtonConnection ()
- (void)setStatus:(NewtonConnectionStatus)newStatus;
- (void)_receivedCommand:(OSType)cmd data:(NSData*)data;
- (void)handleProtocolError;
- (void)_startHelloTimer;
- (void)_stopHelloTimer;
@end

@implementation NewtonConnection

@synthesize status, info;

- (id)initWithSerialPort:(NSString*)path speed:(NSUInteger)serialSpeed {
    if ((self = [super init])) {
        // create mnp connection
        mpipe = [[MNPPipe alloc] initWithSerialPort:path speed:serialSpeed];
        helloTimer = nil;
        if (mpipe == nil) {
            [self release];
            return nil;
        }
        
        // register for notifications
        NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
        [nc addObserver:self selector:@selector(dataAvailable:) name:MNPPipeDataAvailableNotification object:mpipe];
        [nc addObserver:self selector:@selector(didConnect:) name:MNPPipeConnectionEstablishedNotification object:mpipe];
        [nc addObserver:self selector:@selector(didDisconnect:) name:MNPPipeConnectionLostNotification object:mpipe];
        
        // start listening
        [mpipe open];
        [self setStatus:kNewtonConnectionListening];
    }
    return self;
}

- (void)dealloc {
    [self _stopHelloTimer];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    if (status > kNewtonConnectionListening) {
        [self disconnect];
        // allow some time for the disconnect request to send
        [mpipe retain];
        [mpipe performSelector:@selector(release) withObject:nil afterDelay:1.0];
    }
    [mpipe release];
    [super dealloc];
}

- (void)setStatus:(NewtonConnectionStatus)newStatus {
    // ah, the magic of KVO
    if (status == newStatus) return;
    status = newStatus;
}

- (void)dataAvailable:(NSNotification*)notification {
    if ([notification object] != mpipe) return; // this shouldn't happen
    
    // read header?
    if (btr == 0) {
        if ([mpipe numberOfBytesAvailable] < 16) return;
        NSData *cmdHeaderData = [mpipe readDataOfLength:16];
        // check header
        uint32_t *cmdHeader = (uint32_t*)[cmdHeaderData bytes];
        if (OSSwapBigToHostInt32(cmdHeader[0]) != 'newt') goto fail;
        if (OSSwapBigToHostInt32(cmdHeader[1]) != 'dock') goto fail;
        newPacketCmd = OSSwapBigToHostInt32(cmdHeader[2]);
        newPacketLen = OSSwapBigToHostInt32(cmdHeader[3]);
        // get bytes to read
        btr = (newPacketLen+3) & -4; // round up to next multiple of 4
    }
    
    // read data?
    if ([mpipe numberOfBytesAvailable] >= btr) {
        // process packet
        if (btr == 0) {
            [self _receivedCommand:newPacketCmd data:nil];
        } else {
            [self _receivedCommand:newPacketCmd data:[mpipe readDataOfLength:btr]];
        }
        
        // prepare to read next header
        btr = 0;
    }
    
    return;
fail:
    [self setStatus:kNewtonConnectionProtocolError];
    [self handleProtocolError];
}

- (void)didConnect:(NSNotification*)notification {
    NSLog(@"Newton connected");
}

- (void)handleProtocolError {
    NSLog(@"Protocol error");
}

- (NSUInteger)speed {
    return mpipe.speed;
}

- (NSString*)serialPort {
    return mpipe.serialPort;
}

- (void)didDisconnect:(NSNotification*)notification {
    [self _stopHelloTimer];
    [self setStatus:kNewtonConnectionListening];
}

- (void)disconnect {
    NSLog(@"Disconnect");
    if (status <= kNewtonConnectionListening) return;
    [self _stopHelloTimer];
    [self sendCommand:kDDisconnect, nil];
    [self setStatus:kNewtonConnectionNotConnected];
}

- (void)_receivedCommand:(OSType)cmd data:(NSData*)data {
    char selName[] = "_cmdProc_xxxx:";
    if (cmd == 'helo') return;
    //NSLog(@"RCV %c%c%c%c %@", OSTypeToChars(cmd), data);
    OSWriteBigInt32(selName, 9, cmd);
    SEL cmdProc = sel_getUid(selName);
    if ([self respondsToSelector:cmdProc]) {
        [self performSelector:cmdProc withObject:data];
    } else {
        NSLog(@"don't know how to process %c%c%c%c %@", OSTypeToChars(cmd), data);
    }
}

#pragma mark Command Sending

- (void)sendCommand:(OSType)cmd withBytes:(const void*)bytes length:(NSUInteger)length {
    //NSLog(@"SND %c%c%c%c %@", OSTypeToChars(cmd), [NSData dataWithBytes:bytes length:length]);
    size_t pktLen = (16+length+3) & -4; // round up to next multiple of 4
    uint8_t *pkt = malloc(pktLen);
    // make header
    uint32_t *cmdHeader = (uint32_t*)pkt;
    cmdHeader[0] = OSSwapBigToHostConstInt32('newt');
    cmdHeader[1] = OSSwapBigToHostConstInt32('dock');
    cmdHeader[2] = OSSwapBigToHostInt32(cmd);
    cmdHeader[3] = OSSwapBigToHostInt32(length);
    // add data and zero end
    memcpy(pkt+16, bytes, length);
    bzero(pkt+16+length, pktLen-16-length);
    // send
    [mpipe writeBytes:pkt length:pktLen];
    free(pkt);
}

- (void)sendCommand:(OSType)cmd data:(NSData*)data {
    [self sendCommand:cmd withBytes:data.bytes length:data.length];
}

- (void)sendCommand:(OSType)cmd withLong:(int32_t)value {
    uint32_t value_be = OSSwapHostToBigInt32(value);
    [self sendCommand:cmd withBytes:&value_be length:4];
}

- (void)sendCommand:(OSType)cmd withString:(NSString*)str {
    NSUInteger bufsz = 4+2*[str length]+2;
    uint8_t *bytes = malloc(bufsz);
    [str getBytes:bytes+4 maxLength:bufsz-4 usedLength:NULL encoding:NSUTF16BigEndianStringEncoding options:0 range:NSMakeRange(0, [str length]) remainingRange:NULL];
    bzero(bytes+bufsz-2, 2);
    OSWriteBigInt32(bytes, 0, bufsz-4);
    [self sendCommand:cmd withBytes:bytes length:bufsz];
    free(bytes);
}

- (void)sendCommand:(OSType)cmd, ... {
    va_list args;
    NSMutableData *data = nil;
    id arg;
    va_start(args, cmd);
    arg = va_arg(args,id);
    if (arg) {
        data = [NSMutableData dataWithCapacity:128];
        do {
            // add argument
            if ([arg isKindOfClass:[NSString class]]) {
                // length-prefixed utf16 big endian string with zero-terminator
                int32_t lbe = OSSwapHostToBigInt32(2*([arg length]+1));
                [data appendBytes:&lbe length:4];
                NSUInteger pos = data.length;
                [data increaseLengthBy:2*([arg length]+1)];
                [arg getBytes:data.mutableBytes+pos maxLength:data.length-pos usedLength:NULL encoding:NSUTF16BigEndianStringEncoding options:0 range:NSMakeRange(0, [arg length]) remainingRange:NULL];
            } else if ([arg isKindOfClass:[NSNumber class]]) {
                // long
                int32_t lbe = OSSwapHostToBigInt32([arg longValue]);
                [data appendBytes:&lbe length:4];
            } else {
                NSLog(@"Can't add %@ to packet", NSStringFromClass([arg class]));
            }
        } while(arg = va_arg(args,id));
    }
    va_end(args);
    
    // send
    if (data == nil) [self sendCommand:cmd withBytes:NULL length:0];
    else [self sendCommand:cmd withBytes:data.bytes length:data.length];
}

#pragma mark Specific Commands

- (void)_sendHello {
    [self sendCommand:'helo', nil];
}

- (void)_sendDesktopInfo {
    NSMutableData *reply = [NSMutableData dataWithCapacity:128];
    [reply setLength:6*4];
    // create challenge
    srandomdev();
    dChallenge[0] = random();
    dChallenge[1] = random();
    // desktop info values
    void * bytes = reply.mutableBytes;
    OSWriteBigInt32(bytes, 0*4, kDProtocolVersion);
    OSWriteBigInt32(bytes, 1*4, kDPlatformMac);
    OSWriteBigInt32(bytes, 2*4, dChallenge[0]); // challenge
    OSWriteBigInt32(bytes, 3*4, dChallenge[1]); // challenge
    OSWriteBigInt32(bytes, 4*4, kDSessionSettingUp);
    OSWriteBigInt32(bytes, 5*4, 0); // allow selective sync
    // write desktop apps
    NSArray *desktopApps = [NSArray arrayWithObject:[NSDictionary dictionaryWithObjectsAndKeys:
                            @"Newton Connection Utilities", @"name",
                            [NSNumber numberWithInt:2], @"id",
                            [NSNumber numberWithInt:1], @"version", nil]];
    [reply appendData:[NSOFEncoder encodeObject:desktopApps]];
    [self sendCommand:kDDesktopInfo data:reply];
}

- (void)_sendPassword {
    NSValue *encPw = [NewtonPassword encryptPassword:@"" challenge:nChallenge];
    uint32_t password_be[2];
    [encPw getValue:&password_be];
    [self sendCommand:kDPassword, 
     [NSNumber numberWithUnsignedInt:password_be[0]], 
     [NSNumber numberWithUnsignedInt:password_be[1]], 
     nil];
    [self setStatus:kNewtonConnectionConnected];
}

- (void)_startHelloTimer {
    helloTimer = [[NSTimer alloc] initWithFireDate:[NSDate dateWithTimeIntervalSinceNow:15.0] interval:15.0 target:self selector:@selector(_sendHello) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:helloTimer forMode:NSRunLoopCommonModes];
}

- (void)_stopHelloTimer {
    if (helloTimer) {
        [helloTimer invalidate];
        [helloTimer release];
        helloTimer = nil;
    }
}

#pragma mark Command Processing

- (void)_cmdProc_dres:(NSData*)data {
    //int32_t result = OSReadBigInt32(data.bytes, 0);
}

- (void)_cmdProc_rtdk:(NSData*)data {
    if (status == kNewtonConnectionListening) {
        [self setStatus:kNewtonConnectionHandshake];
        [self sendCommand:kDInitiateDocking withLong:4];
    }
}

- (void)_cmdProc_name:(NSData*)data {
    info = [[NewtonInfo alloc] initWithData:data];
    if (status == kNewtonConnectionHandshake) {
        [self _sendDesktopInfo];
    }
}

- (void)_cmdProc_ninf:(NSData*)data {
    const uint32_t *cmdLongs = [data bytes];
    if (status == kNewtonConnectionHandshake) {
        [self sendCommand:kDWhichIcons withLong:0];
        [self sendCommand:kDSetTimeout withLong:30];
        nChallenge[0] = OSSwapBigToHostInt32(cmdLongs[1]);
        nChallenge[1] = OSSwapBigToHostInt32(cmdLongs[2]);
    }
}

- (void)_cmdProc_pass:(NSData*)data {
    const uint32_t *cmdLongs = [data bytes];
    uint32_t encPw[2];
    
    if (status == kNewtonConnectionHandshake || status == kNewtonConnectionKeyExchange) {
        [self setStatus:kNewtonConnectionKeyExchange];
        encPw[0] = OSSwapBigToHostInt32(cmdLongs[0]);
        encPw[1] = OSSwapBigToHostInt32(cmdLongs[1]);
    
        // verify password
        if (![NewtonPassword verifyPassword:@"" encrypted:encPw challenge:dChallenge]) {
            [self sendCommand:kDResult withLong:kDErr_RetryPassword];
        } else {
            [self _sendPassword];
        }
    }
}

- (void)_cmdProc_kybd:(NSData*)data {
    [self setStatus:kNewtonConnectionKeyboard];
    [self _startHelloTimer];
    
}

- (void)_cmdProc_opca:(NSData*)data {
    [self _stopHelloTimer];
    if (status == kNewtonConnectionKeyboard) {
        [self setStatus:kNewtonConnectionConnected];
    }
    [self sendCommand:kDOpCanceledAck, nil];
}

- (void)_cmdProc_ocaa:(NSData*)data {
    [self setStatus:kNewtonConnectionConnected];
}

- (void)_cmdProc_disc:(NSData*)data {
    [self setStatus:kNewtonConnectionNotConnected];
    [self disconnect];
}

- (void)_cmdProc_unkn:(NSData*)data {
    // unknown command
    OSType cmd = OSReadBigInt32(data.bytes, 0);
    NSLog(@"Unknown command: %c%c%c%c", OSTypeToChars(cmd));
    // this ugly hack seems to work if you don't look at it
    if (cmd == kDDisconnect) {
        [self sendCommand:kDOperationCanceled data:nil];        
        [self sendCommand:kDDisconnect data:nil];
    }
}

#pragma mark Keyboard
- (void)startKeyboardPassthrough {
    [self sendCommand:kDStartKeyboardPassthrough, nil];
}

- (void)stopKeyboardPassthrough {
    if (status == kNewtonConnectionKeyboard) {
        [self _stopHelloTimer];
        [self sendCommand:kDOperationCanceled, nil];
    }
}

- (void)sendKeyboardString:(NSString*)str {
    // kDKeyboardString didn't seem to work
    unichar *uc = malloc(sizeof(unichar)*str.length);
    [str getCharacters:uc];
    for(int i=0; i < str.length; i++) [self sendKeyboardCharacter:uc[i] commandKeyDown:NO];
    free(uc);
}

- (void)sendKeyboardCharacter:(unichar)chr {
    [self sendKeyboardCharacter:chr commandKeyDown:NO];
}

- (void)sendKeyboardCharacter:(unichar)chr commandKeyDown:(BOOL)cmdKey {
    uint16_t cmd[2];
    cmd[0] = OSSwapHostToBigInt16(chr);
    cmd[1] = cmdKey?OSSwapHostToBigInt16(1):0;
    [self sendCommand:kDKeyboardChar withBytes:cmd length:4];
}

@end
