//
//  LoginViewController.m
//  Piggybackv2
//
//  Created by Kimberly Hsiao on 6/25/12.
//  Copyright (c) 2012 Calimucho. All rights reserved.
//

#import "LoginViewController.h"
#import "AppDelegate.h"
#import "PiggybackTabBarController.h"
#import "Constants.h"

@interface LoginViewController ()
@end

@implementation LoginViewController

#pragma mark - public helper functions

- (void)getAndStoreCurrentUserFbInformationAndUid {
    Facebook *facebook = [(AppDelegate *)[[UIApplication sharedApplication] delegate] facebook];
    
    // Uid is retrieved from request:didLoad: method (FBRequestDelegate method) -- for synchronous purposes
    AppDelegate* appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    PiggybackTabBarController* rootViewController = (PiggybackTabBarController*)appDelegate.window.rootViewController; 
    rootViewController.currentFbAPICall = fbAPIGraphMeFromLogin;
    [facebook requestWithGraphPath:@"me" andDelegate:rootViewController];
}

#pragma mark - view lifecycle

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(void)dealloc {
    NSLog(@"login view controller dealloc");
}

#pragma mark - IBAction definitions

- (IBAction)loginWithFacebook:(id)sender {
    NSArray *permissions = [[NSArray alloc] initWithObjects:@"email", nil];
    [[(AppDelegate *)[[UIApplication sharedApplication] delegate] facebook] authorize:permissions];
}

@end
