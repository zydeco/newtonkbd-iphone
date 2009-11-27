//
//  NewtonKeyboardAppDelegate.h
//  NewtonKeyboard
//
//  Created by Zydeco on 2009-11-21.
//  Copyright namedfork.net 2009. All rights reserved.
//

#import <UIKit/UIKit.h>

@class NewtonKeyboardViewController;

@interface NewtonKeyboardAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    NewtonKeyboardViewController *viewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet NewtonKeyboardViewController *viewController;

@end

