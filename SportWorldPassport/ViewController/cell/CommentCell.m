//
//  CommentCell.m
//  SportWorldPassport
//
//  Created by star on 12/2/15.
//  Copyright (c) 2015 UWP. All rights reserved.
//

#import "CommentCell.h"

@interface CommentCell()
{
    PFObject *comment;
}
@end


@implementation CommentCell
@synthesize poster;

- (void)setdata:(PFObject *)data {
    comment = data;
    
    poster = comment[PARSE_FIELD_USER];
    [self.lblUsername setText:[NSString stringWithFormat:@"@%@", poster.username]];
    [ParseUtils setParsePictureOf:self.avatarImageView file:poster[PARSE_USER_AVATAR] default:nil];
    
    self.txtComment.text = comment[@"comment"];
    if (_boldIndex == -1){
        
    } else if (_boldIndex == 100){
        [self.lblComment setFont:[UIFont fontWithName:@"Arial-BoldMT" size:16]];
    }
    [self.lblComment setText:comment[PARSE_COMMENT_TEXT]];
    
    [self refreshLikesCountLabel];
}

- (void)refreshLikesCountLabel {
    
    NSArray *likes = comment[PARSE_COMMENT_LIKES];
    NSArray *dislikes = comment[PARSE_COMMENT_DISLIKES];
    
    int count = likes.count - dislikes.count;
    if (count > 0) {
        [self.btnUp setBackgroundImage:[UIImage imageNamed:@"ic_arrow_above_green"] forState:UIControlStateNormal];
        [self.btnDown setBackgroundImage:[UIImage imageNamed:@"ic_arrow_below_gray"] forState:UIControlStateNormal];
        
        _lblLikeCount.text = [NSString stringWithFormat:@"+%d", count];
        _lblLikeCount.textColor = [UIColor colorWithRed:89/255.0 green:191/255.0 blue:49/255.0 alpha:1];
    } else if (count < 0) {
        [self.btnUp setBackgroundImage:[UIImage imageNamed:@"ic_arrow_above_gray"] forState:UIControlStateNormal];
        [self.btnDown setBackgroundImage:[UIImage imageNamed:@"ic_arrow_below_orange"] forState:UIControlStateNormal];
        
        _lblLikeCount.text = [NSString stringWithFormat:@"%d", count];
        _lblLikeCount.textColor = [UIColor colorWithRed:1 green:82/255.0 blue:16/255.0 alpha:1];
    } else {
        [self.btnUp setBackgroundImage:[UIImage imageNamed:@"ic_arrow_above_gray"] forState:UIControlStateNormal];
        [self.btnDown setBackgroundImage:[UIImage imageNamed:@"ic_arrow_below_gray"] forState:UIControlStateNormal];
        
        _lblLikeCount.text = [NSString stringWithFormat:@"%d", count];
        _lblLikeCount.textColor = [UIColor grayColor];
    }
}

- (IBAction)onLikeComment:(id)sender {
    NSInteger tag = [sender tag];
    
    NSMutableArray *likes = [[NSMutableArray alloc] initWithArray:comment[PARSE_COMMENT_LIKES]];
    NSMutableArray *dislikes = [[NSMutableArray alloc] initWithArray:comment[PARSE_COMMENT_DISLIKES]];
    PFUser *me = [PFUser currentUser];
    
    if (tag == 100) { // like
        if ([dislikes containsObject:me.objectId]) {
            [dislikes removeObject:me.objectId];
            comment[PARSE_COMMENT_DISLIKES] = dislikes;
            [comment saveInBackground];
        } else if (![likes containsObject:me.objectId]) {
            [likes addObject:me.objectId];
            comment[PARSE_COMMENT_LIKES] = likes;
            [comment saveInBackground];
        }
        
        [self refreshLikesCountLabel];
    } else { // dislike
        if ([likes containsObject:me.objectId]) {
            [likes removeObject:me.objectId];
            comment[PARSE_COMMENT_LIKES] = likes;
            [comment saveInBackground];
        } else if (![dislikes containsObject:me.objectId]) {
            [dislikes addObject:me.objectId];
            comment[PARSE_COMMENT_DISLIKES] = dislikes;
            [comment saveInBackground];
        }
        
        [self refreshLikesCountLabel];
    }
}
- (IBAction)onTapAvatar:(id)sender {
    if (self.delegate){
        [self.delegate onSeeUser:self];
    }
}

@end
