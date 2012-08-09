//
//  ProfileViewController.h
//  Piggybackv2
//
//  Created by Michael Gao on 8/7/12.
//  Copyright (c) 2012 Calimucho. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <RestKit/RestKit.h>
#import <RestKit/CoreData.h>

@interface ProfileViewController : UIViewController <RKRequestDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *profilePic;
@property (weak, nonatomic) IBOutlet UIProgressView *statusBar;
@property (weak, nonatomic) IBOutlet UILabel *numMusicPiggybackers;
@property (weak, nonatomic) IBOutlet UILabel *numPlacesPiggybackers;
@property (weak, nonatomic) IBOutlet UILabel *numVideosPiggybackers;
@property (weak, nonatomic) IBOutlet UILabel *numMusicLikes;
@property (weak, nonatomic) IBOutlet UILabel *numPlacesLikes;
@property (weak, nonatomic) IBOutlet UILabel *numVideosLikes;
@property (weak, nonatomic) IBOutlet UILabel *numMusicSaves;
@property (weak, nonatomic) IBOutlet UILabel *numPlacesSaves;
@property (weak, nonatomic) IBOutlet UILabel *numVideosSaves;
@property (weak, nonatomic) IBOutlet UILabel *progressText;

@end
