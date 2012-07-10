//
//  FBImageToDataTransformer.m
//  Piggybackv2
//
//  Created by Kimberly Hsiao on 7/6/12.
//  Copyright (c) 2012 Calimucho. All rights reserved.
//

#import "FBImageToDataTransformer.h"

@implementation FBImageToDataTransformer


+ (BOOL)allowsReverseTransformation {
    return YES;
}

+ (Class)transformedValueClass {
    return [NSData class];
}


- (id)transformedValue:(id)value {
    NSData *data = UIImagePNGRepresentation(value);
    return data;
}


- (id)reverseTransformedValue:(id)value {
    UIImage *uiImage = [[UIImage alloc] initWithData:value];
    return uiImage;
}

@end