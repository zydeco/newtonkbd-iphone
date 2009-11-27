//
//  SoftKeyboard.h
//  NewtonKeyboard
//
//  Created by Zydeco on 2009-11-21.
//  Copyright 2009 namedfork.net. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SoftKeyboardDelegate <NSObject>
- (void)handleKeyPress:(unichar)c commandKeyDown:(BOOL)cmd;
@end

@interface SoftKeyboard : UITextView {
    IBOutlet id<SoftKeyboardDelegate> keyboardDelegate;
    BOOL commandKeyDown;
    BOOL keyboardShowing;
    IBOutlet UIView *extraKeysBar;
    IBOutlet UIBarButtonItem *commandKey;
}

- (IBAction)show:(id)sender;
- (IBAction)hide:(id)sender;
- (IBAction)keyboardInputFromTag:(id)sender;
- (IBAction)commandKeyTap:(id)sender;

@property (nonatomic, assign) id <SoftKeyboardDelegate> keyboardDelegate;
@end
