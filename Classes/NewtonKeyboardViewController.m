//
//  NewtonKeyboardViewController.m
//  NewtonKeyboard
//
//  Created by Zydeco on 2009-11-21.
//  Copyright namedfork.net 2009. All rights reserved.
//

#import "NewtonKeyboardViewController.h"
#import "NewtonConnection.h"
#import "NewtonInfo.h"
#import "SoftKeyboard.h"

@implementation NewtonKeyboardViewController

#if TARGET_IPHONE_SIMULATOR
#define SERIAL_PORT "/dev/tty.usbserial-FTCVKDOW"
#else
#define SERIAL_PORT "/dev/tty.iap"
#endif

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationLandscapeRight);
}

- (void)viewWillDisappear:(BOOL)animated {
    [newton removeObserver:self forKeyPath:@"status"];
    [newton stopKeyboardPassthrough];
    [[NSRunLoop mainRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:2.0]];
    [newton disconnect];
    // allow some time for the disconnect request to send
    [newton performSelector:@selector(release) withObject:nil afterDelay:2.0];
    newton = nil;
    [softKeyboard hide:self];
}

- (void)viewWillAppear:(BOOL)animated {
    newton = [[NewtonConnection alloc] initWithSerialPort:@SERIAL_PORT speed:38400];
    [newton addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil];
    [softKeyboard show:self];
    label1.text = @"Waiting for Newton…";
    label2.text = @"";
}

- (void)dealloc {
    [super dealloc];
}

- (void)handleKeyPress:(unichar)c commandKeyDown:(BOOL)cmd {
    if (c == '\n') c = '\r';
    [newton sendKeyboardCharacter:c commandKeyDown:cmd];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    int oldValue;
    switch (newton.status) {
        case kNewtonConnectionConnected:
            label1.text = @"Connected to Newton";
            label2.text = newton.info.ownerName;
            oldValue = [[change objectForKey:NSKeyValueChangeOldKey] intValue];
            if (oldValue < kNewtonConnectionConnected) {
                [newton startKeyboardPassthrough];
            } else if (oldValue == kNewtonConnectionKeyboard) {
                [newton disconnect];
            }
            break;
        case kNewtonConnectionHandshake:
        case kNewtonConnectionKeyExchange:
            label1.text = @"Connecting…";
            label2.text = @"";
            break;
        case kNewtonConnectionNotConnected:
        case kNewtonConnectionListening:
            // recycling the connection object doesn't really work, make a new one
            [newton removeObserver:self forKeyPath:@"status"];
            [newton release];
            newton = [[NewtonConnection alloc] initWithSerialPort:@SERIAL_PORT speed:38400];
            [newton addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil];
            label1.text = @"Waiting for Newton…";
            label2.text = @"";
            break;
        case kNewtonConnectionKeyboard:
            [softKeyboard show:self];
            break;
        case kNewtonConnectionProtocolError:
            label1.text = @"Protocol error";
            break;
        default:
            break;
    }
}

@end
