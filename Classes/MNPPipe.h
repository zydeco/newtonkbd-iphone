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
 * The Original Code is MNPPipe.h.
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

typedef enum {
    MNPPipeStatusUnknown,
    MNPPipeStatusListening,
    MNPPipeStatusLinkEstablished,
    MNPPipeStatusDisconnected
} MNPPipeStatus;

extern NSString * MNPPipeConnectionEstablishedNotification;
extern NSString * MNPPipeConnectionLostNotification;
extern NSString * MNPPipeDataAvailableNotification;

@interface MNPPipe : NSObject {
    NSString                *serialPort;
    NSUInteger              speed;
    NSFileHandle            *fh;
    MNPPipeStatus           status;
    NSMutableData           *frame, *inBuffer, *outBuffer;
    uint16_t                frmCRC, curCRC;
    uint8_t                 seqnIn, seqnOut; // next frame expected
    int                     state;
    NSTimeInterval          lAckTimeout;
    BOOL                    clearToSend;
    NSMutableArray          *outLT;
    NSData                  *lastSentLT;
    size_t                  maxLTSize;
    struct {
        int rcvCrcErrors;
        int framesResent; // due to errors or timeouts
    } stats;
}

@property (readonly) NSString * serialPort;
@property (readonly) NSUInteger speed;
@property (readonly) MNPPipeStatus status;

- (id)initWithSerialPort:(NSString*)path speed:(NSUInteger)serialSpeed;
- (void)open;
- (NSUInteger)numberOfBytesAvailable;
- (NSData*)readDataOfLength:(NSUInteger)length; // dosen't block, but may return less bytes than asked for
- (void)writeData:(NSData*)data;
- (void)writeBytes:(const uint8_t *)bytes length:(NSUInteger)length;
@end
