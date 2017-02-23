//
//  MyFeedCell.h
//  SportWorldPassport
//
//  Created by star on 1/8/16.
//  Copyright (c) 2016 UWP. All rights reserved.
//

#import "MGSwipeTableCell.h"

@interface MyFeedCell : MGSwipeTableCell

@property (strong, nonatomic) IBOutlet UIImageView *feedImageView;
@property (strong, nonatomic) IBOutlet UILabel *lblTitle;
@property (strong, nonatomic) IBOutlet UILabel *lblCommentCount;
@property (strong, nonatomic) IBOutlet UILabel *lblLikeCount;

- (void)setData:(PFObject *)feed;

@end
