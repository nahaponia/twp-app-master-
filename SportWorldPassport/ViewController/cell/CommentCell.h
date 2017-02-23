//
//  CommentCell.h
//  SportWorldPassport
//
//  Created by star on 12/2/15.
//  Copyright (c) 2015 UWP. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CommentCell;
@protocol CommentCellDelegate <NSObject>
@required
- (void)onSeeUser:(CommentCell *)cell;
@end

@interface CommentCell : UITableViewCell

@property (strong, nonatomic) IBOutlet CircleImageView *avatarImageView;
@property (strong, nonatomic) IBOutlet UILabel *lblUsername;
@property (strong, nonatomic) IBOutlet UITextView *txtComment;
@property (strong, nonatomic) IBOutlet UILabel *lblLikeCount;
@property (strong, nonatomic) IBOutlet UIButton *btnUp;
@property (strong, nonatomic) IBOutlet UIButton *btnDown;
@property (strong, nonatomic) IBOutlet UILabel *lblComment;
@property (nonatomic) int boldIndex;
@property (strong, nonatomic) PFUser *poster;
@property (strong, nonatomic) id<CommentCellDelegate> delegate;

- (IBAction)onLikeComment:(id)sender;

- (void)setdata:(PFObject *)data;

@end
