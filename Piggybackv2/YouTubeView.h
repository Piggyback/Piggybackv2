//
//  YouTubeView.h
//  Piggybackv2
//
//  Created by Kimberly Hsiao on 7/27/12.
//  Copyright (c) 2012 Calimucho. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YouTubeView : UIWebView

- (YouTubeView *)initWithStringAsURL:(NSString *)urlString frame:(CGRect)frame;

@end