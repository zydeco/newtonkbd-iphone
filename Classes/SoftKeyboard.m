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
 * The Original Code is SoftKeyboard.m.
 * 
 * The Initial Developer of the Original Code is Jesús A. Álvarez.
 * Portions created by the Initial Developer are Copyright 
 * (C) 2009 namedfork.net. All Rights Reserved.
 * 
 * Contributor(s):
 *     Jesús A. Álvarez <zydeco@namedfork.net> (original author)
 * 
 */

#import "SoftKeyboard.h"

@interface SoftKeyboard ()
- (void)_setup;
- (void)_setCommandKeyUp;
@end

@implementation SoftKeyboard

@synthesize keyboardDelegate;

- (id)init {
    if ((self = [super init])) {
        [self _setup];
    }
    return self;
}

- (void)awakeFromNib {
    [self _setup];
}

- (void)_setup {
    // set input traits
    self.autocorrectionType = UITextAutocorrectionTypeNo; // 1
    self.autocapitalizationType = UITextAutocapitalizationTypeNone; // 0
    self.enablesReturnKeyAutomatically = NO;
    // register for keyboard notifications
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [nc addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    // create view with extra keys
    if (extraKeysBar) {
        CGRect f = extraKeysBar.frame;
        f.origin.y = [self.superview frame].size.height;
        extraKeysBar.frame = f;
    }
}

- (void)dealloc {
    [super dealloc];
}

- (BOOL)keyboardInput:(id)fp8 shouldInsertText:(NSString*)text isMarkedText:(BOOL)marked {
    unichar c;
    if ([keyboardDelegate respondsToSelector:@selector(handleKeyPress:commandKeyDown:)]) {
        [text getCharacters:&c range:NSMakeRange(0, 1)];
        [keyboardDelegate handleKeyPress:c commandKeyDown:commandKeyDown];
        if (commandKeyDown) [self _setCommandKeyUp];
    }
    return NO;
}

- (BOOL)keyboardInputShouldDelete:(id)fp8 {
    if ([keyboardDelegate respondsToSelector:@selector(handleKeyPress:commandKeyDown:)]) {
        [keyboardDelegate handleKeyPress:0x0008 commandKeyDown:commandKeyDown];
        if (commandKeyDown) [self _setCommandKeyUp];
    }
    return NO;
}

- (void)_setCommandKeyUp {
    commandKeyDown = NO;
    [commandKey setImage:[UIImage imageNamed:@"KeyCmd.png"]];
}

- (IBAction)keyboardInputFromTag:(id)sender {
    [keyboardDelegate handleKeyPress:[sender tag] commandKeyDown:commandKeyDown];
    if (commandKeyDown) [self _setCommandKeyUp];
}

- (IBAction)commandKeyTap:(id)sender {
    commandKeyDown = !commandKeyDown;
    [sender setImage:[UIImage imageNamed:commandKeyDown?@"KeyCmd_Down.png":@"KeyCmd.png"]];
}

- (IBAction)show:(id)sender {
    keyboardShowing = YES;
    [self becomeFirstResponder];
}

- (IBAction)hide:(id)sender {
    keyboardShowing = NO;
    [self resignFirstResponder];
}

- (void)keyboardWillShow:(NSNotification*)note {
    if (extraKeysBar) {
        CGRect r = extraKeysBar.frame, t;
        [[note.userInfo valueForKey:UIKeyboardBoundsUserInfoKey] getValue: &t];
        r.origin.y -=  (t.size.height + r.size.height);
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.3];
        extraKeysBar.frame = r;
        [UIView commitAnimations];
    }
}

- (void)keyboardWillHide:(NSNotification*)note {
    if (extraKeysBar) {
        CGRect r = extraKeysBar.frame, t;
        [[note.userInfo valueForKey:UIKeyboardBoundsUserInfoKey] getValue: &t];
        r.origin.y += (t.size.height + r.size.height);
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.3];
        extraKeysBar.frame = r;
        [UIView commitAnimations];
    }
}

- (BOOL)canResignFirstResponder {
    return !keyboardShowing;
}

@end
