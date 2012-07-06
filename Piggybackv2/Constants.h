//
//  Constants.h
//  Ambassadors
//
//  Created by Kimberly Hsiao on 6/19/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Constants : NSObject

extern float const VIDEOTHUMBNAILWIDTH;
extern float const VIDEOTHUMBNAILHEIGHT;
extern float const VIDEOTHUMBNAILMARGIN;
extern float const VIDEONAMETEXTWIDTH;
extern float const VIDEOTABLEROWHEIGHT;
extern float const SETAMBASSADORSROWHEIGHT;

typedef enum fbApiCall {
    fbAPIGraphMeFromLogin,
    fbAPIGraphMeFriends
} fbApiCall;

typedef enum fsApiCall {
    fsAPIGetSelf,
    fsAPIGetFriends,
    fsAPIGetRecentCheckins
} fsApiCall;

@end
