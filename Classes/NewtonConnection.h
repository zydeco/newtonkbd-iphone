//
//  NewtonConnection.h
//  NewtComm
//
//  Created by Zydeco on 2009-11-15.
//  Copyright 2009 namedfork.net. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NewtonInfo.h";

@class MNPPipe;

enum {
    kDKeyDelete = 8,
    kDKeyArrowLeft = 28,
    kDKeyArrowRight,
    kDKeyArrowUp,
    kDKeyArrowDown
};

typedef enum {
    kNewtonConnectionNotConnected,
    kNewtonConnectionListening,
    kNewtonConnectionProtocolError,
    kNewtonConnectionHandshake,
    kNewtonConnectionKeyExchange,
    kNewtonConnectionConnected,
    kNewtonConnectionKeyboard,
} NewtonConnectionStatus;

// Commands
#define kDRequestToDock     'rtdk'
#define kDInitiateDocking   'dock'
#define kDNewtonName        'name'
#define kDNewtonInfo        'ninf'
#define kDDesktopInfo       'dinf'
#define kDWhichIcons        'wicn'
#define kDResult            'dres'
#define kDSetTimeout        'stim'
#define kDPassword          'pass'
#define kDStartKeyboardPassthrough  'kybd'
#define kDKeyboardString    'kbds'
#define kDKeyboardChar      'kbdc'
#define kDOperationDone     'opdn'
#define kDOperationCanceled 'opca'
#define kDOpCanceledAck     'ocaa'
#define kDDisconnect        'disc'

// other constants
#define kDProtocolVersion   10
#define kDPlatformMac       0
#define kDPlatformWindows   1

// session types
enum {
    kDSessionNone = 0,
    kDSessionSettingUp,
    kDSessionSync,
    kDSessionRestore,
    kDSessionLoadPackage,
    kDSessionTestComm,
    kDSessionLoadPatch,
    kDSessionUpdatingStores
};

// icons
enum {
    kDIconBackup = 1,
    kDIconRestore = 2,
    kDIconInstall = 4,
    kDIconImport = 8,
    kDIconSync = 16,
    kDIconKeyboard = 32,
};

// errors
enum {
    kDErr_BadPassword = -28022,
    kDErr_RetryPassword = -28023
};

@interface NewtonConnection : NSObject {
    MNPPipe                 *mpipe;
    NewtonConnectionStatus  status;
    NewtonInfo              *info;
    uint32_t                dChallenge[2], nChallenge[2];
    NSTimer                 *helloTimer;
    // packet reading
    int                     btr; // bytes to read, 0 if expecting header
    OSType                  newPacketCmd;
    uint32_t                newPacketLen;
}

@property (readonly) NSString * serialPort;
@property (readonly) NSUInteger speed;
@property (readonly) NewtonConnectionStatus status;
@property (readonly) NewtonInfo *info;

- (id)initWithSerialPort:(NSString*)path speed:(NSUInteger)serialSpeed;
- (void)sendCommand:(OSType)cmd data:(NSData*)data;
- (void)sendCommand:(OSType)cmd withBytes:(const void*)bytes length:(NSUInteger)length;
- (void)sendCommand:(OSType)cmd withLong:(int32_t)value;
- (void)sendCommand:(OSType)cmd, ...;
- (void)disconnect;

- (void)startKeyboardPassthrough;
- (void)stopKeyboardPassthrough;
- (void)sendKeyboardString:(NSString*)str;
- (void)sendKeyboardCharacter:(unichar)chr;
- (void)sendKeyboardCharacter:(unichar)chr commandKeyDown:(BOOL)cmdKey;
@end
