//
//  LoginViewController.h
//  Piggybackv2
//
//  Created by Kimberly Hsiao on 6/25/12.
//  Copyright (c) 2012 Calimucho. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Facebook.h"

@interface LoginViewController : UIViewController

- (IBAction)loginWithFacebook:(id)sender;
- (void)getAndStoreCurrentUserFbInformationAndUid;

@end
