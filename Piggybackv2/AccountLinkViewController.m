//
//  AccountLinkViewController.m
//  Piggybackv2
//
//  Created by Michael Gao on 6/21/12.
//  Copyright (c) 2012 Calimucho. All rights reserved.
//

#import "AccountLinkViewController.h"
#import "AppDelegate.h"

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
        
    } else {
        
    }
}

- (IBAction)continueButton:(id)sender {
    
}

@end
