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

@interface AccountLinkViewController ()

@end

@implementation AccountLinkViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)viewDidUnload
{
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
        
    } else {
        
    }
}

- (IBAction)youtubeConnect:(id)sender {
    if ([sender isOn] == YES) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Link Your YouTube Account\n\n" message:@"" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK",nil];
        
        // create text view
        UITextField *someTextField = [[UITextField alloc] initWithFrame:CGRectMake(20, 50, 245, 25)];
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
    [self dismissModalViewControllerAnimated:YES];
}

@end
