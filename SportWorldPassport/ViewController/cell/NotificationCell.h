//
//  NotificationCell.h
//  SportWorldPassport
//
//  Created by star on 1/7/16.
//  Copyright (c) 2016 UWP. All rights reserved.
//

#import <UIKit/UIKit.h>

@class NotificationCell;

@protocol NewsCellDelegate <NSObject>
@required
- (void)onSeeNews:(NotificationCell *)cell;
@end

@interface NotificationCell : UITableViewCell

@property (strong, nonatomic) IBOutlet CircleImageView *avatarImageView;
@property (strong, nonatomic) IBOutlet UIImageView *postImageView;
@property (strong, nonatomic) IBOutlet UILabel *lblContent;

@property (strong, nonatomic) id<NewsCellDelegate> delegate;

- (void)setData:(PFObject *)object;

@end
