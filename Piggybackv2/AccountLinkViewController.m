//
//  AccountLinkViewController.m
//  Piggybackv2
//
//  Created by Michael Gao on 6/21/12.
//  Copyright (c) 2012 Calimucho. All rights reserved.
//

#import "AccountLinkViewController.h"
#import "AppDelegate.h"
#import <QuartzCore/QuartzCore.h>
#import "SetAmbassadorsViewController.h"
#import "PiggybackTabBarController.h"

@interface AccountLinkViewController ()

@end

@implementation AccountLinkViewController
@synthesize youtubeToggle;
@synthesize spotifyToggle;
@synthesize foursquareToggle;

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewDidUnload
{
    [self setYoutubeToggle:nil];
    [self setSpotifyToggle:nil];
    [self setFoursquareToggle:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)foursquareConnect:(id)sender {
    if ([sender isOn] == YES) {
        [[(AppDelegate*)[[UIApplication sharedApplication] delegate] foursquare] startAuthorization];
    } else {
        [[(AppDelegate*)[[UIApplication sharedApplication] delegate] foursquare] invalidateSession];
    }
}

- (IBAction)spotifyConnect:(id)sender {
    if ([sender isOn] == YES) {
        SPLoginViewController *spotifyLogin = [SPLoginViewController loginControllerForSession:[SPSession sharedSession]];
        [self presentViewController:spotifyLogin animated:YES completion:nil];
    } else {
        [[SPSession sharedSession] logout:^{}];
    }
}

- (IBAction)youtubeConnect:(id)sender {
    if ([sender isOn] == YES) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Link Your YouTube Account\n\n" message:nil delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK",nil];
        
        // create text view
        UITextField *someTextField = [[UITextField alloc] initWithFrame:CGRectMake(20, 43, 245, 25)];
        someTextField.layer.cornerRadius = 2;
        someTextField.layer.masksToBounds = YES;
        
        // font of text
        someTextField.placeholder = @"YouTube login name";
        someTextField.backgroundColor = [UIColor whiteColor];
        someTextField.textColor = [UIColor blackColor];
        someTextField.font = [UIFont systemFontOfSize:14];
        someTextField.autocorrectionType = UITextAutocorrectionTypeNo;
        
        // alignment and padding of text
        someTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, 20)];
        someTextField.leftView = paddingView;
        someTextField.leftViewMode = UITextFieldViewModeAlways;
        [alert addSubview:someTextField];
        [alert show];
        
    } else {
        
    }
}

- (IBAction)continueButton:(id)sender {    
    // display set ambassadors view
    AppDelegate* appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    PiggybackTabBarController* rootViewController = (PiggybackTabBarController*)appDelegate.window.rootViewController;
    [self presentViewController:rootViewController.setAmbassadorsViewController animated:YES completion:nil];
}

#pragma mark - youtube alert delegate

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        self.youtubeToggle.on = FALSE;
    } else if (buttonIndex == 1) {
        NSLog(@"added youtube account");
    }
}

//- (IBAction)logout:(id)sender {
//    [[(AppDelegate *)[[UIApplication sharedApplication] delegate] facebook] logout];
//}

@end
