//
//  AppDelegate.h
//  Piggybackv2
//
//  Created by Michael Gao on 6/21/12.
//  Copyright (c) 2012 Calimucho. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BZFoursquare.h"
#import "CocoaLibSpotify.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate, BZFoursquareSessionDelegate, SPSessionDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) BZFoursquare *foursquare;
@property (strong, nonatomic) SPPlaybackManager *playbackManager;

@end
