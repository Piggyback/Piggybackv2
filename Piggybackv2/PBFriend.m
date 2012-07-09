//
//  PBFriend.m
//  Piggybackv2
//
//  Created by Kimberly Hsiao on 7/5/12.
//  Copyright (c) 2012 Calimucho. All rights reserved.
//

#import "PBFriend.h"


@implementation PBFriend

@dynamic fbId;
@dynamic firstName;
@dynamic foursquareId;
@dynamic lastName;
@dynamic email;
@dynamic spotifyUsername;
@dynamic youtubeUsername;
@dynamic thumbnail;

@end

//@implementation FriendFBImageToDataTransformer
//
//
//+ (BOOL)allowsReverseTransformation {
//    return YES;
//}
//
//+ (Class)transformedValueClass {
//    return [NSData class];
//}
//
//
//- (id)transformedValue:(id)value {
//    NSData *data = UIImagePNGRepresentation(value);
//    return data;
//}
//
//
//- (id)reverseTransformedValue:(id)value {
//    UIImage *uiImage = [[UIImage alloc] initWithData:value];
//    return uiImage;
//}
//
//@end