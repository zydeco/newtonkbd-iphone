//
//  NewtonKeyboardAppDelegate.m
//  NewtonKeyboard
//
//  Created by Zydeco on 2009-11-21.
//  Copyright namedfork.net 2009. All rights reserved.
//

#import "NewtonKeyboardAppDelegate.h"
#import "NewtonKeyboardViewController.h"

@implementation NewtonKeyboardAppDelegate

@synthesize window;
@synthesize viewController;


- (void)applicationDidFinishLaunching:(UIApplication *)application {    
    [application setStatusBarOrientation:UIInterfaceOrientationLandscapeRight animated:NO];
    
    [window addSubview:viewController.view];
    [window makeKeyAndVisible];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // if we wait, it's more likely to disconnect gracefully
    [[NSRunLoop mainRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:5.0]];
}

- (void)dealloc {
    [viewController release];
    [window release];
    [super dealloc];
}


@end
