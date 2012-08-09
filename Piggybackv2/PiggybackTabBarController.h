//
//  PiggybackTabBarController.h
//  Piggybackv2
//
//  Created by Michael Gao on 6/21/12.
//  Copyright (c) 2012 Calimucho. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FBConnect.h"
#import <RestKit/RestKit.h>
#import <RestKit/CoreData.h>
#import "SetAmbassadorsNavigationController.h"
#import "FoursquareDelegate.h"

@interface PiggybackTabBarController : UITabBarController <FBRequestDelegate, RKObjectLoaderDelegate, RKRequestDelegate>

@property int currentFbAPICall;
@property (nonatomic, strong) SetAmbassadorsNavigationController* setAmbassadorsNavigationController;
@property (nonatomic, strong) FoursquareDelegate* foursquareDelegate;
@end
