//
//  MyFeedCell.m
//  SportWorldPassport
//
//  Created by star on 1/8/16.
//  Copyright (c) 2016 UWP. All rights reserved.
//

#import "MyFeedCell.h"
#import "ParseUtils.h"

@implementation MyFeedCell

- (void)setData:(PFObject *)feed {
    
    [self.lblTitle setText:feed[PARSE_FEED_TITLE]];
    [self.lblLikeCount setText:[NSString stringWithFormat:@"%d", [feed[PARSE_FEED_LIKE_COUNT] intValue]]];
    [self.lblCommentCount setText:[NSString stringWithFormat:@"%d", [feed[PARSE_FEED_COMMENT_COUNT] intValue]]];
    
    [ParseUtils setParsePictureOf:self.feedImageView file:feed[PARSE_FEED_SMALL_PHOTO] default:nil];

}

@end
