//
//  LoginViewController.m
//  Piggybackv2
//
//  Created by Kimberly Hsiao on 6/25/12.
//  Copyright (c) 2012 Calimucho. All rights reserved.
//

#import "LoginViewController.h"
#import "AppDelegate.h"

@interface LoginViewController ()

@end

@implementation LoginViewController

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

#pragma mark - IBAction definitions

- (IBAction)loginWithFacebook:(id)sender {
    NSArray *permissions = [[NSArray alloc] initWithObjects:@"user_likes", @"friends_likes", nil];
    [[(AppDelegate *)[[UIApplication sharedApplication] delegate] facebook] authorize:permissions];
}

@end
