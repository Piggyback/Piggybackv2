//
//  PBTextLayer.m
//  Piggybackv2
//
//  Created by Michael Gao on 8/8/12.
//  Copyright (c) 2012 Calimucho. All rights reserved.
//

#import "PBTextLayer.h"

@implementation PBTextLayer

- (void)drawInContext:(CGContextRef)ctx
{
    CGContextSetRGBFillColor (ctx, 255, 255, 255, 1);
    CGContextFillRect (ctx, [self bounds]);
    CGContextSetShouldSmoothFonts (ctx, true);
    [super drawInContext:ctx];
}

@end
