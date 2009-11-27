//
//  MNPPipe.h
//  NewtComm
//
//  Created by Zydeco on 2009-11-15.
//  Copyright 2009 namedfork.net. All rights reserved.
//

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
