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
@property (weak, nonatomic) IBOutlet UILabel *numPiggybackers;
@property (weak, nonatomic) IBOutlet UILabel *numLikes;
@property (weak, nonatomic) IBOutlet UILabel *numSaves;

@end
