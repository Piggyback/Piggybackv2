//
//  PlacesItemViewController.m
//  Piggybackv2
//
//  Created by Kimberly Hsiao on 8/7/12.
//  Copyright (c) 2012 Calimucho. All rights reserved.
//

#import "PlacesItemViewController.h"

@interface PlacesItemViewController ()
@property BOOL hasAddress;
@property BOOL hasPhone;
@property (nonatomic, strong) NSMutableArray* vendorInfo;
@end

@implementation PlacesItemViewController 

@synthesize placesItem = _placesItem;
@synthesize scrollView = _scrollView;
@synthesize vendorTableView = _vendorTableView;
@synthesize photos = _photos;
@synthesize photoScrollView = _photoScrollView;
@synthesize photoPageControl = _photoPageControl;

const CGFloat photoHeight = 213;
const CGFloat photoWidth = 320;

#pragma mark - setters / getters

- (void)setPlacesItem:(PBPlacesItem *)placesItem
{
    self.vendorInfo = [[NSMutableArray alloc] init];
    
    // check if vendor has address and phone number
    if ([placesItem.addr length] == 0 && [placesItem.addrCity length] == 0 && [placesItem.addrState length])
        self.hasAddress = NO;
    else {
        self.hasAddress = YES;
        // build self.formattedAddress
        NSMutableString* formattedAddress = [[NSMutableString alloc] init];
        formattedAddress = [[NSMutableString alloc] init];
        if ([placesItem.addr length])
            [formattedAddress appendFormat:@"%@\n", placesItem.addr];
        if ([placesItem.addrCity length] && [placesItem.addrState length])
            [formattedAddress appendFormat:@"%@, %@ ", placesItem.addrCity, placesItem.addrState];
        if ([placesItem.addrZip length])
            [formattedAddress appendString:[placesItem.addrZip substringToIndex:5]];
        
        [self.vendorInfo addObject:formattedAddress];
    }
    
    if ([placesItem.phone length] == 0)
        self.hasPhone = NO;
    else {
        self.hasPhone = YES;
        
        [self.vendorInfo addObject:placesItem.phone];
    }
    
    _placesItem = placesItem;
}

- (NSMutableArray*)photos
{
    if (_photos == nil) {
        _photos = [[NSMutableArray alloc] init];
    }
    return _photos;
}

#pragma mark - display scrolling photos

- (void)displayPhotos {
    dispatch_queue_t downloadImageQueue = dispatch_queue_create("downloadImage",NULL);
    dispatch_async(downloadImageQueue, ^{
        for (int i = 0; i < [self.photos count]; i++) {
            UIImage* photo = [self.photos objectAtIndex:i];
            [self.photoPageControl setNumberOfPages:[self.photos count]];
            [self.photoPageControl setCurrentPage:0];
            UIImageView *imageView = [[UIImageView alloc] initWithImage:photo];
            imageView.contentMode = UIViewContentModeScaleAspectFill;
            imageView.tag = i;
            imageView.frame = CGRectMake(0,0,photoWidth,photoHeight);
            [self.photoScrollView addSubview:imageView];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self layoutPhotoScrollImages];
        });
    });
}

- (void)layoutPhotoScrollImages {
    UIImageView *photo = nil;
    NSArray *subviews = [self.photoScrollView subviews];
    
    // reposition all image subviews in a horizontal serial fashion
    CGFloat curXLoc = photoWidth;
    for (photo in subviews) {
        if ([photo isKindOfClass:[UIImageView class]] && photo.tag > 0) {
            CGRect frame = photo.frame;
            frame.origin = CGPointMake(curXLoc,0);
            photo.frame = frame;
            
            curXLoc += (photoWidth);
        }
    }
    
    // set width of photo scroll view to fit all images
    [self.photoScrollView setContentSize:CGSizeMake([self.photos count] * photoWidth,self.photoScrollView.bounds.size.height)];
}

#pragma mark - table data source protocol methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.vendorInfo count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *VendorInfoCellIdentifier = @"vendorInfoCell";
    
    UITableViewCell *cell;
    
    cell = [tableView dequeueReusableCellWithIdentifier:VendorInfoCellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:VendorInfoCellIdentifier];
    }
    
    // only has address or phone, not both
    if ([self.vendorInfo count] == 1) {
        if (self.hasAddress) {
            cell.textLabel.numberOfLines = 0;
            cell.imageView.image = [UIImage imageNamed:@"Geolocation-icon"];
            
        } else {
            cell.imageView.image = [UIImage imageNamed:@"phone_icon"];
            cell.indentationWidth = 4;
        }
    }
    
    // has both address and phone
    else {
        if (indexPath.row == 0) {
            // address row
            cell.textLabel.numberOfLines = 0;
            cell.imageView.image = [UIImage imageNamed:@"Geolocation-icon"];
        } else {
            // phone number row
            cell.imageView.image = [UIImage imageNamed:@"phone_icon"];
            cell.indentationWidth = 4;
        }
    }
    
    cell.textLabel.text = [self.vendorInfo objectAtIndex:indexPath.row];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath: (NSIndexPath *) indexPath
{
    // has only address or phone, not both
    if ([self.vendorInfo count] == 1) {
        if (self.hasAddress) {
            return tableView.rowHeight + 10;
        }
    }
    
    // has both address and phone
    else {
        if (indexPath.row == 0) {
            // address row
            return tableView.rowHeight + 10;
        }
    }
    
    return tableView.rowHeight;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        if (indexPath.row == 0 && self.hasAddress) {
            // address row
            NSString *convertedAddressStr = [[self.vendorInfo objectAtIndex:0] stringByReplacingOccurrencesOfString:@"\n" withString:@" "];
            convertedAddressStr = [convertedAddressStr stringByReplacingOccurrencesOfString:@" " withString:@"+"];
            
            NSString *url = [NSString stringWithFormat:@"http://maps.google.com/maps?daddr=%@&saddr=%s", convertedAddressStr, "Current%20Location"];
            
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
        } else if (self.hasPhone) {
            // phone number row
            NSString *numberStr = self.placesItem.phone.description;
            
            NSCharacterSet *illegalCharSet = [[NSCharacterSet characterSetWithCharactersInString:@"1234567890*#"] invertedSet];
            NSString *convertedStr = [[numberStr componentsSeparatedByCharactersInSet:illegalCharSet] componentsJoinedByString:@""];
            
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[@"tel:" stringByAppendingString:convertedStr]]];
        }
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

-(void)viewDidLoad {
    self.title = self.placesItem.name;
    [self.scrollView setScrollEnabled:YES];
    [self.scrollView bringSubviewToFront:self.photoPageControl];
    
    // set up page control
    self.photoScrollView.delegate = self;
    CGRect frame = self.photoPageControl.frame;
    frame.size.height = frame.size.height/2.5;
    self.photoPageControl.frame = frame;
    
    // set photo
    [self displayPhotos];
}

@end
