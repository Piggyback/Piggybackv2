//
//  AccountLinkViewController.h
//  Piggybackv2
//
//  Created by Michael Gao on 6/21/12.
//  Copyright (c) 2012 Calimucho. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AccountLinkViewController : UIViewController

- (IBAction)foursquareConnect:(id)sender;
- (IBAction)spotifyConnect:(id)sender;
- (IBAction)youtubeConnect:(id)sender;
- (IBAction)continueButton:(id)sender;
@property (weak, nonatomic) IBOutlet UISwitch *youtubeToggle;
@property (weak, nonatomic) IBOutlet UISwitch *spotifyToggle;
@property (weak, nonatomic) IBOutlet UISwitch *foursquareToggle;

@end
