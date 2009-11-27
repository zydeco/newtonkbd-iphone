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
 * The Original Code is SoftKeyboard.h.
 * 
 * The Initial Developer of the Original Code is Jesús A. Álvarez.
 * Portions created by the Initial Developer are Copyright 
 * (C) 2009 namedfork.net. All Rights Reserved.
 * 
 * Contributor(s):
 *     Jesús A. Álvarez <zydeco@namedfork.net> (original author)
 * 
 */

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
