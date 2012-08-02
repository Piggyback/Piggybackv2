//
//  HomeFeedNavigationController.m
//  Piggybackv2
//
//  Created by Kimberly Hsiao on 8/2/12.
//  Copyright (c) 2012 Calimucho. All rights reserved.
//

#import "HomeFeedNavigationController.h"

@interface HomeFeedNavigationController ()

@end

@implementation HomeFeedNavigationController

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

@end
