//
//  NewtonKeyboardViewController.h
//  NewtonKeyboard
//
//  Created by Zydeco on 2009-11-21.
//  Copyright namedfork.net 2009. All rights reserved.
//

#import <UIKit/UIKit.h>

@class NewtonConnection, SoftKeyboard;
@protocol InfoViewControllerDelegate;

@interface NewtonKeyboardViewController : UIViewController {
    IBOutlet UILabel *label1, *label2;
    IBOutlet SoftKeyboard *softKeyboard;
    NewtonConnection *newton;
}

@end

