//
//  TodoPlacesCell.h
//  Piggybackv2
//
//  Created by Kimberly Hsiao on 8/3/12.
//  Copyright (c) 2012 Calimucho. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TodoPlacesCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *vendorImage;
@property (weak, nonatomic) IBOutlet UILabel *vendorName;
@property (weak, nonatomic) IBOutlet UILabel *vendorAddress;
@property (weak, nonatomic) IBOutlet UILabel *date;
@property (weak, nonatomic) IBOutlet UILabel *phone;

@end
