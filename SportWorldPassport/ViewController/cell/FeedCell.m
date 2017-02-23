//
//  FeedCell.m
//  SportWorldPassport
//
//  Created by star on 12/2/15.
//  Copyright (c) 2015 UWP. All rights reserved.
//

#import "FeedCell.h"
#import "ParseUtils.h"
#import <AVFoundation/AVFoundation.h>
#import <AVKit/AVKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import <MobileCoreServices/MobileCoreServices.h>

@implementation FeedCell

- (void)setData:(PFObject *)feed {
    
    PFUser *poster = feed[PARSE_FIELD_USER];
    
    [self.lblTitle setText:feed[PARSE_FEED_TITLE]];
    [self.lblUsername setText:[NSString stringWithFormat:@"@%@", poster.username]];
    [self.lblLikeCount setText:[NSString stringWithFormat:@"%d", [feed[PARSE_FEED_LIKE_COUNT] intValue]]];
    [self.lblCommentCount setText:[NSString stringWithFormat:@"%d", [feed[PARSE_FEED_COMMENT_COUNT] intValue]]];
    
    if (feed[PARSE_FEED_VIDEO]){
//        self.feedImageView.hidden = YES;
//        self.videoView.hidden = NO;
        self.lblView.hidden = NO;
//        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//            [self showVideoMoment:feed[PARSE_FEED_VIDEO]];
//        });
        [ParseUtils setParsePictureOf:self.feedImageView file:feed[PARSE_FEED_SMALL_PHOTO] default:nil];
    } else {
        self.videoView.hidden = YES;
        self.feedImageView.hidden = NO;
        self.lblView.hidden = YES;
        [ParseUtils setParsePictureOf:self.feedImageView file:feed[PARSE_FEED_SMALL_PHOTO] default:nil];
    }
    
    [ParseUtils setParsePictureOf:self.avatarImageView file:poster[PARSE_USER_AVATAR] default:nil];
    
    NSArray *likers = feed[PARSE_FEED_LIKES];
    if ([likers containsObject:[PFUser currentUser].objectId]) {
        [self.btnLike setSelected:YES];
    } else {
        [self.btnLike setSelected:NO];
    }
}

- (void) showVideoMoment:(PFFile *)file
{
    [MBProgressHUD hideHUDForView:self animated:YES];
    
    if (!file){
        if (self.avplayer){
            [self.avplayer seekToTime:kCMTimeZero];
            [self.avplayer pause];
        }
        return;
    }
    
    NSString *docPath = [self getDocumentDirectoryPath];
    NSString *filePath = [NSString stringWithFormat:@"%@/%@", docPath, file.name];
    BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:filePath];
    if (fileExists){
        [self playVideo:filePath];
    } else {
        [MBProgressHUD showHUDAddedTo:self animated:YES];
        [file getDataInBackgroundWithBlock:^(NSData *data, NSError *error){
            [MBProgressHUD hideHUDForView:self animated:YES];
            if (error){
                NSLog(@"Error get Video Data from Server");
            } else {
                [data writeToFile:filePath atomically:YES];
                [self playVideo:filePath];
            }
        }];
    }
}

- (void)playVideo:(NSString *)filePath
{
    //play video
    NSURL *url = [NSURL fileURLWithPath:filePath];
    self.avplayer = [AVPlayer playerWithURL:url];
    self.avplayer.actionAtItemEnd = AVPlayerActionAtItemEndNone;
    [self.avplayer setMuted:YES];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerItemDidReachEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:[self.avplayer currentItem]];
    AVPlayerLayer *videoLayer = [AVPlayerLayer playerLayerWithPlayer:self.avplayer];
    videoLayer.frame = CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height);
    videoLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    [self.videoView.layer addSublayer:videoLayer];
    [self.avplayer play];
}

- (void)playerItemDidReachEnd:(NSNotification *) notification // video end notificaton
{
    AVPlayerItem *process = [notification object];
    [process seekToTime:kCMTimeZero];
}

- (NSString *) getDocumentDirectoryPath
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDirectory = [paths objectAtIndex:0];
    return documentDirectory;
}

- (IBAction)onLikeUnlike:(id)sender {
    if (self.delegate) {
        [self.delegate onLikeFeed:self liked:[self.btnLike isSelected]];
    }
}

- (void) seekToStart
{
    [self showVideoMoment:nil];
}

@end
