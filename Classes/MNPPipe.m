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
 * The Original Code is MNPPipe.m.
 * 
 * The Initial Developer of the Original Code is Jesús A. Álvarez.
 * Portions created by the Initial Developer are Copyright 
 * (C) 2009 namedfork.net. All Rights Reserved.
 * 
 * Contributor(s):
 *     Jesús A. Álvarez <zydeco@namedfork.net> (original author)
 * 
 */

#import "MNPPipe.h"
#include <termios.h>
#include <fcntl.h>

#define MNPLog(__fmt, ...) NSLog(__fmt, ## __VA_ARGS__)
//#define MNPLog(__fmt, ...)

NSString * MNPPipeConnectionEstablishedNotification = @"MNPPipeConnectionEstablished";
NSString * MNPPipeConnectionLostNotification = @"MNPPipeConnectionLost";
NSString * MNPPipeDataAvailableNotification = @"MNPPipeDataAvailable";

@interface MNPPipe ()
static inline int MNPPipe__gotByte(MNPPipe *self, const uint8_t *byte);
static inline uint16_t MNPPipe__updateCRC16(uint16_t crc, uint8_t byte);
- (void)_frameError;
- (int)_sendLinkAcknowledge:(uint8_t)num;
- (int)_writeFrame:(const uint8_t *)data length:(size_t)size;
- (int)_writeData:(const uint8_t*)data length:(size_t)size;
- (void)_linkTransferAcknowledged;
- (void)_receivedFrame;
- (NSData*)_linkTransferBlockWithBytes:(const uint8_t*)data length:(size_t)size number:(uint8_t)num;
- (int)_resendLastLT;
- (int)_keepAlive;

- (void)_connectionEstablished;
- (void)_connectionLost;
- (void)_receivedData:(const uint8_t*)data length:(size_t)length;
@end

enum {
    MNPLinkRequest = 1,
    MNPLinkDisconnect = 2,
    MNPLinkTransfer = 4,
    MNPLinkAcknowledge = 5,
    MNPLinkAttention = 6,
    MNPLinkAttentionAcknowledge = 7,
};

static uint16_t crcTab[256] =
{
    0x0000, 0xc0c1, 0xc181, 0x0140, 0xc301, 0x03c0, 0x0280, 0xc241,
    0xc601, 0x06c0, 0x0780, 0xc741, 0x0500, 0xc5c1, 0xc481, 0x0440,
    0xcc01, 0x0cc0, 0x0d80, 0xcd41, 0x0f00, 0xcfc1, 0xce81, 0x0e40,
    0x0a00, 0xcac1, 0xcb81, 0x0b40, 0xc901, 0x09c0, 0x0880, 0xc841,
    0xd801, 0x18c0, 0x1980, 0xd941, 0x1b00, 0xdbc1, 0xda81, 0x1a40,
    0x1e00, 0xdec1, 0xdf81, 0x1f40, 0xdd01, 0x1dc0, 0x1c80, 0xdc41,
    0x1400, 0xd4c1, 0xd581, 0x1540, 0xd701, 0x17c0, 0x1680, 0xd641,
    0xd201, 0x12c0, 0x1380, 0xd341, 0x1100, 0xd1c1, 0xd081, 0x1040,
    0xf001, 0x30c0, 0x3180, 0xf141, 0x3300, 0xf3c1, 0xf281, 0x3240,
    0x3600, 0xf6c1, 0xf781, 0x3740, 0xf501, 0x35c0, 0x3480, 0xf441,
    0x3c00, 0xfcc1, 0xfd81, 0x3d40, 0xff01, 0x3fc0, 0x3e80, 0xfe41,
    0xfa01, 0x3ac0, 0x3b80, 0xfb41, 0x3900, 0xf9c1, 0xf881, 0x3840,
    0x2800, 0xe8c1, 0xe981, 0x2940, 0xeb01, 0x2bc0, 0x2a80, 0xea41,
    0xee01, 0x2ec0, 0x2f80, 0xef41, 0x2d00, 0xedc1, 0xec81, 0x2c40,
    0xe401, 0x24c0, 0x2580, 0xe541, 0x2700, 0xe7c1, 0xe681, 0x2640,
    0x2200, 0xe2c1, 0xe381, 0x2340, 0xe101, 0x21c0, 0x2080, 0xe041,
    0xa001, 0x60c0, 0x6180, 0xa141, 0x6300, 0xa3c1, 0xa281, 0x6240,
    0x6600, 0xa6c1, 0xa781, 0x6740, 0xa501, 0x65c0, 0x6480, 0xa441,
    0x6c00, 0xacc1, 0xad81, 0x6d40, 0xaf01, 0x6fc0, 0x6e80, 0xae41,
    0xaa01, 0x6ac0, 0x6b80, 0xab41, 0x6900, 0xa9c1, 0xa881, 0x6840,
    0x7800, 0xb8c1, 0xb981, 0x7940, 0xbb01, 0x7bc0, 0x7a80, 0xba41,
    0xbe01, 0x7ec0, 0x7f80, 0xbf41, 0x7d00, 0xbdc1, 0xbc81, 0x7c40,
    0xb401, 0x74c0, 0x7580, 0xb541, 0x7700, 0xb7c1, 0xb681, 0x7640,
    0x7200, 0xb2c1, 0xb381, 0x7340, 0xb101, 0x71c0, 0x7080, 0xb041,
    0x5000, 0x90c1, 0x9181, 0x5140, 0x9301, 0x53c0, 0x5280, 0x9241,
    0x9601, 0x56c0, 0x5780, 0x9741, 0x5500, 0x95c1, 0x9481, 0x5440,
    0x9c01, 0x5cc0, 0x5d80, 0x9d41, 0x5f00, 0x9fc1, 0x9e81, 0x5e40,
    0x5a00, 0x9ac1, 0x9b81, 0x5b40, 0x9901, 0x59c0, 0x5880, 0x9841,
    0x8801, 0x48c0, 0x4980, 0x8941, 0x4b00, 0x8bc1, 0x8a81, 0x4a40,
    0x4e00, 0x8ec1, 0x8f81, 0x4f40, 0x8d01, 0x4dc0, 0x4c80, 0x8c41,
    0x4400, 0x84c1, 0x8581, 0x4540, 0x8701, 0x47c0, 0x4680, 0x8641,
    0x8201, 0x42c0, 0x4380, 0x8341, 0x4100, 0x81c1, 0x8081, 0x4040
};

static uint8_t frmMNPLinkRequestAck[] = {23,1,2,1,6,1,0,0,0,0,255,2,1,2,3,1,1,4,2,64,0,8,1,3};
//static uint8_t frmMNPLinkRequestAck[] = {0x1d, 0x01, 0x02, 0x01, 0x06, 0x01, 0x00, 0x00, 0x00, 0x00, 0xFF, 0x02, 0x01, 0x02, 0x03, 0x01, 0x08, 0x04, 0x02, 0x40, 0x00, 0x08, 0x01, 0x03, 0x0E, 0x04, 0x02, 0x04, 0x00, 0xFA};
//static uint8_t frmMNPLinkRequestAck[] = {0x26, 0x01, 0x02, 0x01, 0x06, 0x01, 0x00, 0x00, 0x00, 0x00, 0xFF, 0x02, 0x01, 0x02, 0x03, 0x01, 0x08, 0x04, 0x02, 0x40, 0x00, 0x08, 0x01, 0x03, 0x09, 0x01, 0x01, 0x0E, 0x04, 0x03, 0x04, 0x00, 0xFA, 0xC5, 0x06, 0x01, 0x04, 0x00, 0x00, 0xE1, 0x00};
//static uint8_t frmMNPLinkDisconnect[] = {7,2,1,1,255,2,1,0};

@implementation MNPPipe

- (id)initWithSerialPort:(NSString*)path speed:(NSUInteger)serialSpeed {
    if ((self = [super init])) {
        // open serial port
        int fd = open([path fileSystemRepresentation], O_RDWR | O_NOCTTY | O_NDELAY);
        if (fd == -1) fd = open([[@"/dev" stringByAppendingPathComponent:path] fileSystemRepresentation], O_RDWR | O_NOCTTY | O_NDELAY);
        if (fd == -1) {
            NSLog(@"[MNPPipe initWithSerialPort:\"%@\" speed:%lu]: %s", path, serialSpeed, strerror(errno));
            [self release];
            return nil;
        }
        
        // set serial properties
        struct termios t;
        tcgetattr(fd, &t);
        t.c_cflag = CS8 | CREAD | HUPCL | CLOCAL;
        t.c_iflag = IGNBRK | IGNPAR;
        t.c_oflag = 0;
        t.c_lflag = 0;
        t.c_cc[VMIN ] = 1;
        t.c_cc[VTIME] = 0;
        cfsetispeed(&t, serialSpeed);
        cfsetospeed(&t, serialSpeed);
        tcsetattr(fd, TCSANOW, &t);
        
        // set properties
        fh = [[NSFileHandle alloc] initWithFileDescriptor:fd closeOnDealloc:YES];
        serialPort = [path retain];
        speed = serialSpeed;
        status = MNPPipeStatusListening;
        state = 0;
        seqnIn = 1;
        seqnOut = 1;
        clearToSend = YES;
        lAckTimeout = 3.0;
        maxLTSize = 250;
        frame = [[NSMutableData alloc] initWithCapacity:512];
        inBuffer = [[NSMutableData alloc] initWithCapacity:256];
        outBuffer = [[NSMutableData alloc] initWithCapacity:256];
        
        // register for notifications
        NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
        [nc addObserver:self selector:@selector(_dataAvailable:) name:NSFileHandleDataAvailableNotification object:fh];
        
        
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [frame release];
    [inBuffer release];
    [outBuffer release];
    [fh release];
    [serialPort release];
    [super dealloc];
}

- (void)open {
    // wait for data
    [fh waitForDataInBackgroundAndNotify];
}

- (void)_dataAvailable:(NSNotification*)notification {
    if ([notification object] != fh) return; // this shouldn't happen
    NSData *newData = [fh availableData];
    const uint8_t *bytes = [newData bytes];
    
    for(int i=0; i < [newData length]; i++) {
        if (MNPPipe__gotByte(self, &bytes[i])) {
            [self _frameError];
            break;
        }
    }
    
    [fh waitForDataInBackgroundAndNotify];
}

enum {
    stSYN, stDLE, stSTX, stFrameData, stEscapedByte, stCRC1, stCRC2
};

static inline int MNPPipe__gotByte(MNPPipe *self, const uint8_t *byte) {
    switch (self->state) {
        case stSYN:
            // expect a SYN byte
            if (*byte == 0x16) self->state = stDLE;
            break;
        case stDLE:
            // expect DLE, may have SYNs
            if (*byte == 0x16) break;
            if (*byte == 0x10) self->state = stSTX;
            else return -1;
            break;
        case stSTX:
            // expect STX
            if (*byte == 0x02) {
                self->state = stFrameData;
                self->curCRC = 0;
            }
            else return -1;
            break;
        case stFrameData:
            // frame data
            if (*byte == 0x10) {
                self->state = stEscapedByte;
            } else {
                [self->frame appendBytes:byte length:1];
                self->curCRC = MNPPipe__updateCRC16(self->curCRC, *byte);
            }
            break;
        case stEscapedByte:
            // should only be DLE or ETX
            if (*byte == 0x03) {
                // ETX, end of frame data
                self->state = stCRC1;
                self->curCRC = MNPPipe__updateCRC16(self->curCRC, *byte);
            } else {
                // escaped byte
                [self->frame appendBytes:byte length:1];
                self->curCRC = MNPPipe__updateCRC16(self->curCRC, *byte);
                self->state = stFrameData;
            }
            break;
        case stCRC1:
            self->frmCRC = *byte;
            self->state = stCRC2;
            break;
        case stCRC2:
            self->frmCRC |= (*byte) << 8;
            self->state = stSYN;
            if (self->frmCRC != self->curCRC) {
                // CRC error, ask for resend
                MNPLog(@"MNP: CRC error: (got %02x, calc'd %02x) %@", self->frmCRC, self->curCRC, self->frame);
                self->stats.rcvCrcErrors++;
                [self->frame setLength:0];
                [self _sendLinkAcknowledge:self->seqnIn-1];
            } else {
                // frame received
                [self _receivedFrame];
                [self->frame setLength:0];
            }
            break;
        default:
            break;
    }
    
    return 0;
}

- (void)_receivedFrame {
    const uint8_t *bytes = [frame bytes];
    switch (bytes[1]) {
        case MNPLinkRequest:
            MNPLog(@"MNP: Link Request: %@", frame);
            // write our link request
            [self _writeFrame:frmMNPLinkRequestAck length:sizeof frmMNPLinkRequestAck];
            
            break;
        case MNPLinkDisconnect:
            MNPLog(@"MNP: Disconnect: %@", frame);
            [self _connectionLost];
            break;
        case MNPLinkTransfer:
            MNPLog(@"MNP: Transfer: %@ (%04x)", frame, curCRC);
            if (bytes[2] == seqnIn) {
                [self _sendLinkAcknowledge:seqnIn++];
                [self _receivedData:frame.bytes+3 length:frame.length-3];
            } else if (bytes[2] > seqnIn) {
                MNPLog(@"MNP: Out of order transfer (expected 0x%02x)", seqnIn);
                [self _sendLinkAcknowledge:seqnIn-1];
            }
            break;
        case MNPLinkAcknowledge:
            MNPLog(@"MNP: Acknowledge: %@", frame);
            if (bytes[2] == 0 && status != MNPPipeStatusLinkEstablished) {
                // connection established?
                [self _connectionEstablished];
            } else if (bytes[2] == seqnOut) {
                // last frame sent ok
                [self _linkTransferAcknowledged];
            } else if (bytes[2] == seqnOut-1) {
                // asked for resend
                [self _resendLastLT];
            } else {
                // uh oh
                MNPLog(@"MNP: Requested resend, but we don't have it anymore.");
            }
            break;
        case MNPLinkAttention:
            MNPLog(@"MNP: Attention: %@", frame);
            break;
        case MNPLinkAttentionAcknowledge:
            MNPLog(@"MNP: Attention Acknowledge: %@", frame);
            break;
        default:
            MNPLog(@"MNP: Unsupported frame type 0x%02X: %@", frame, bytes[2]);
            break;
    }
}

- (int)_resendLastLT {
    MNPLog(@"MNP: Resending last frame");
    stats.framesResent++;
    return [self _writeFrame:lastSentLT.bytes length:lastSentLT.length];
}

- (void)_frameError {
    MNPLog(@"MNP: frame error at state %d", state);
}

- (int)_sendLinkAcknowledge:(uint8_t)num {
    uint8_t ack[] = {3, MNPLinkAcknowledge, num, 8};
    return [self _writeFrame:ack length:4];
}

- (int)_writeFrame:(const uint8_t *)data length:(size_t)size {
    NSLog(@"MNP Send: %@", [NSData dataWithBytes:data length:size]);
    int fd = [fh fileDescriptor];
    uint16_t crc = 0;
    // TODO error checking on write
    
    // header
    uint8_t header[] = {0x16, 0x10, 0x02};
    write(fd, header, 3);
    
    // data
    for(int i=0; i < size; i++) {
        write(fd, data, 1);
        // write DLE twice
        if (*data == 0x10) write(fd, data, 1);
        // update CRC
        crc = MNPPipe__updateCRC16(crc, *data);
        data++;
    }
    
    // footer and CRC
    crc = MNPPipe__updateCRC16(crc, 0x03);
    uint8_t footer[4] = {0x10, 0x03};
    footer[2] = crc & 0xFF;
    footer[3] = crc >> 8;
    write(fd, footer, 4);
    
    return 0;
}

- (int)_writeData:(const uint8_t*)data length:(size_t)size { 
    if (!clearToSend) {
        // send later
        MNPLog(@"MNP: Cannot send now, adding %d bytes to buffer", size);
        [outBuffer appendBytes:data length:size];
        return 1;
    }
    
    // create frame and send
    clearToSend = NO;
    lastSentLT = [[self _linkTransferBlockWithBytes:data length:size number:seqnOut] retain];
    [self _writeFrame:lastSentLT.bytes length:lastSentLT.length];
    [self performSelector:@selector(_resendLastLT) withObject:nil afterDelay:lAckTimeout];
    // wait for acknowledge
    return 1;
}

- (void)_linkTransferAcknowledged {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(_resendLastLT) object:nil];
    seqnOut++;
    [lastSentLT release];
    lastSentLT = nil;
    if ([outBuffer length]) {
        // more data to send
        size_t newSize = [outBuffer length];
        if (newSize > maxLTSize) newSize = maxLTSize;
        MNPLog(@"MNP: Buffer has %lu bytes, sending %lu", [outBuffer length], newSize);
        lastSentLT = [[self _linkTransferBlockWithBytes:outBuffer.bytes length:newSize number:seqnOut] retain];
        [outBuffer replaceBytesInRange:NSMakeRange(0, newSize) withBytes:NULL length:0];
        [self _writeFrame:lastSentLT.bytes length:lastSentLT.length];
    } else clearToSend = YES;
}

- (NSData*)_linkTransferBlockWithBytes:(const uint8_t*)data length:(size_t)size number:(uint8_t)num {
    uint8_t *block = malloc(size+3);
    block[0] = 2; // header length
    block[1] = MNPLinkTransfer;
    block[2] = num;
    memcpy(&block[3], data, size);
    return [NSData dataWithBytesNoCopy:block length:size+3 freeWhenDone:YES];
}

static inline uint16_t MNPPipe__updateCRC16(uint16_t crc, uint8_t byte) {
    return (uint16_t)(((crc >> 8) & 0xFF) ^ crcTab[(crc & 0xFF) ^ byte]);
}

- (int)_keepAlive {
    MNPLog(@"Keeping alive");
    if ([self _sendLinkAcknowledge:seqnIn-1] == 0) {
        [self performSelector:@selector(_keepAlive) withObject:nil afterDelay:lAckTimeout];
        return 0;
    } else {
        // TODO something, this is a write error
        return -1;
    }
}

- (void)_connectionEstablished {
    status = MNPPipeStatusLinkEstablished;
    [[NSNotificationCenter defaultCenter] postNotificationName:MNPPipeConnectionEstablishedNotification object:self userInfo:nil];
}

- (void)_connectionLost {
    status = MNPPipeStatusDisconnected;
    [[NSNotificationCenter defaultCenter] postNotificationName:MNPPipeConnectionLostNotification object:self userInfo:nil];
}

- (void)_receivedData:(const uint8_t*)data length:(size_t)length {
    [inBuffer appendBytes:data length:length];
    [[NSNotificationCenter defaultCenter] postNotificationName:MNPPipeDataAvailableNotification object:self userInfo:nil];
}

#pragma mark Public Interface
@synthesize status, serialPort, speed;

- (NSUInteger)numberOfBytesAvailable {
    return inBuffer.length;
}

- (NSData*)readDataOfLength:(NSUInteger)length {
    NSRange range = {.location = 0, .length = length};
    if (range.length > inBuffer.length) range.length = inBuffer.length;
    NSData *readData = [inBuffer subdataWithRange:range];
    [inBuffer replaceBytesInRange:range withBytes:NULL length:0];
    return readData;
}

- (void)writeData:(NSData*)data {
    [self _writeData:data.bytes length:data.length];
}

- (void)writeBytes:(const uint8_t *)bytes length:(NSUInteger)length {
    [self _writeData:bytes length:length];
}

@end
