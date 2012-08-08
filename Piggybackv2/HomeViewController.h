//
//  HomeViewController.h
//  Piggybackv2
//
//  Created by Kimberly Hsiao on 7/10/12.
//  Copyright (c) 2012 Calimucho. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <RestKit/RestKit.h>
#import <RestKit/CoreData.h>
#import "FoursquareDelegate.h"
#import "YoutubeDelegate.h"
#import "CocoaLibSpotify.h"
#import "HomeMusicCell.h"
#import "HomePlacesCell.h"
#import "HomeVideosCell.h"

@interface HomeViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, RKObjectLoaderDelegate, FoursquareCheckinDelegate, YoutubeDelegate, HomeMusicCellDelegate, HomePlacesCellDelegate, HomeVideosCellDelegate, RKRequestDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) FoursquareDelegate* foursquareDelegate;
@property (nonatomic, strong) YoutubeDelegate* youtubeDelegate;
@property (strong, nonatomic) SPPlaybackManager *playbackManager;
@property (nonatomic, strong) SPPlaylist *piggybackPlaylist;

- (void)loadAmbassadorData;
- (void)fetchAmbassadorFavsFromCoreData;

@end
