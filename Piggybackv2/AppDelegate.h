//
//  AppDelegate.h
//  Piggybackv2
//
//  Created by Michael Gao on 6/21/12.
//  Copyright (c) 2012 Calimucho. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BZFoursquare.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate, BZFoursquareRequestDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) BZFoursquare *foursquare;

@end
