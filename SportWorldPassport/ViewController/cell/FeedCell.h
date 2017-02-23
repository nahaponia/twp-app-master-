//
//  FeedCell.h
//  SportWorldPassport
//
//  Created by star on 12/2/15.
//  Copyright (c) 2015 UWP. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@class FeedCell;

@protocol FeedCellDelegate <NSObject>
@required
- (void)onLikeFeed:(FeedCell *)cell liked:(BOOL)liked;
@end


@interface FeedCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UIImageView *feedImageView;
@property (strong, nonatomic) IBOutlet UIView *videoView;
@property (strong, nonatomic) IBOutlet CircleImageView *avatarImageView;
@property (strong, nonatomic) IBOutlet UILabel *lblTitle;
@property (strong, nonatomic) IBOutlet UILabel *lblUsername;
@property (strong, nonatomic) IBOutlet UILabel *lblCommentCount;
@property (strong, nonatomic) IBOutlet UILabel *lblLikeCount;
@property (strong, nonatomic) IBOutlet UIButton *btnLike;

@property (strong, nonatomic) id<FeedCellDelegate> delegate;
@property (strong, nonatomic) AVPlayer *avplayer;
@property (strong, nonatomic) IBOutlet UIView *lblView;

- (void)setData:(PFObject *)feed;
- (void)seekToStart;
- (IBAction)onLikeUnlike:(id)sender;

@end
