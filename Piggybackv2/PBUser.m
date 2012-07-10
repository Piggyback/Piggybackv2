//
//  PBUser.m
//  Piggybackv2
//
//  Created by Kimberly Hsiao on 6/28/12.
//  Copyright (c) 2012 Calimucho. All rights reserved.
//

#import "PBUser.h"
#import "PBAmbassador.h"


@implementation PBUser

@dynamic email;
@dynamic fbId;
@dynamic firstName;
@dynamic foursquareId;
@dynamic lastName;
@dynamic spotifyUsername;
@dynamic uid;
@dynamic youtubeUsername;
@dynamic isPiggybackUser;
@dynamic thumbnail;
@dynamic ambassadors;

@end

//@implementation UserFBImageToDataTransformer
//
//
//+ (BOOL)allowsReverseTransformation {
//return YES;
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
