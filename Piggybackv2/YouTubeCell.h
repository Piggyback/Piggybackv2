//
//  YouTubeCell.h
//  Piggybackv2
//
//  Created by Kimberly Hsiao on 6/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YouTubeCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UILabel* nameOfVideo;
@property (nonatomic, weak) IBOutlet UILabel* favoritedBy;
@property (nonatomic, weak) IBOutlet UIImageView* profilePic;
@property (nonatomic, weak) IBOutlet UILabel* date;

@end
