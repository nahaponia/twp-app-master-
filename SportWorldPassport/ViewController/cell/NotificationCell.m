//
//  NotificationCell.m
//  SportWorldPassport
//
//  Created by star on 1/7/16.
//  Copyright (c) 2016 UWP. All rights reserved.
//

#import "NotificationCell.h"
#import "ParseUtils.h"
#import "NSDate+Convenience.h"
#import "NSDate+String.h"

@implementation NotificationCell

- (void)awakeFromNib {
    UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAvatar:)];
    [gesture setNumberOfTapsRequired:1];
    [gesture setEnabled:YES];

    [self.avatarImageView setUserInteractionEnabled:YES];
    [self.avatarImageView addGestureRecognizer:gesture];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setData:(PFObject *)object {
    int type = [object[PARSE_NEWS_TYPE] intValue];
    PFUser *poster = object[PARSE_NEWS_POSTER];
    [ParseUtils setParsePictureOf:self.avatarImageView file:poster[PARSE_USER_AVATAR] default:nil];
    
    if (type == NEWS_COMMENT) {
        PFObject *feed = object[PARSE_NEWS_FEED];
        [ParseUtils setParsePictureOf:self.postImageView file:feed[PARSE_FEED_SMALL_PHOTO] default:nil];
        
        NSString *username = poster.username;
        NSString *content = @"commented your";
        NSString *comment = @"experience.";
        NSString *time = [NSDate offsetStringBetweenStartDate:object.createdAt endDate:[NSDate date]];
        
        NSString *text = [NSString stringWithFormat:@"%@ %@ %@ %@",
                          username, content, comment, time];
        CGFloat fontSize = self.lblContent.font.pointSize;
        
        // If attributed text is supported (iOS6+)
        if ([self.lblContent respondsToSelector:@selector(setAttributedText:)]) {
            NSDictionary *attribs = @{
                                      NSForegroundColorAttributeName: COLOR_BLUE,
                                      NSFontAttributeName: self.lblContent.font
                                      };
            NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString:text attributes:attribs];
            
            // Bold text attributes
            NSRange usernameTextRange = [text rangeOfString:username];
            NSRange commentTextRange = [text rangeOfString:comment];
            [attributedText setAttributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:fontSize]}
                                    range:usernameTextRange];
            [attributedText setAttributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:fontSize]}
                                    range:commentTextRange];
            
            // Gray text attributes
            UIColor *grayColor = [UIColor colorWithRed:128/255.0 green:138/255.0 blue:156/255.0 alpha:1.0];
            NSRange timeTextRange = [text rangeOfString:time];
            [attributedText setAttributes:@{NSForegroundColorAttributeName:grayColor}
                                    range:timeTextRange];
            
            self.lblContent.attributedText = attributedText;
        } else { // If attributed text is NOT supported (iOS5-)
            self.lblContent.text = text;
        }
    } else if (type == NEWS_LIKED) {
        PFObject *feed = object[PARSE_NEWS_FEED];
        [ParseUtils setParsePictureOf:self.postImageView file:feed[PARSE_FEED_SMALL_PHOTO] default:nil];
        
        NSString *username = poster.username;
        NSString *content = @"liked your";
        NSString *comment = @"experience.";
        NSString *time = [NSDate offsetStringBetweenStartDate:object.createdAt endDate:[NSDate date]];
        
        NSString *text = [NSString stringWithFormat:@"%@ %@ %@ %@",
                          username, content, comment, time];
        CGFloat fontSize = self.lblContent.font.pointSize;
        
        // If attributed text is supported (iOS6+)
//        if ([self.lblContent respondsToSelector:@selector(setAttributedText:)]) {
//            NSDictionary *attribs = @{
//                                      NSForegroundColorAttributeName: COLOR_BLUE,
//                                      NSFontAttributeName: self.lblContent.font
//                                      };
//            NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString:text attributes:attribs];
//            
//            // Bold text attributes
//            NSRange usernameTextRange = [text rangeOfString:username];
//            NSRange commentTextRange = [text rangeOfString:comment];
////            [attributedText setAttributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:fontSize]}
////                                    range:usernameTextRange];
////            [attributedText setAttributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:fontSize]}
////                                    range:commentTextRange];
//            
//            // Gray text attributes
//            UIColor *grayColor = [UIColor colorWithRed:128/255.0 green:138/255.0 blue:156/255.0 alpha:1.0];
//            NSRange timeTextRange = [text rangeOfString:time];
//            [attributedText setAttributes:@{NSForegroundColorAttributeName:grayColor}
//                                    range:timeTextRange];
//            
//            self.lblContent.attributedText = attributedText;
//        } else { // If attributed text is NOT supported (iOS5-)
            self.lblContent.text = text;
//        }
    } else { // NEWS_FOLLOWING
        PFObject *feed = object[PARSE_NEWS_FEED];
        [ParseUtils setParsePictureOf:self.postImageView file:feed[PARSE_FEED_SMALL_PHOTO] default:nil];
        
        NSString *username = poster.username;
        NSString *content = @"started following you.";
        NSString *time = [NSDate stringFromDate:object.createdAt format:@"yyyy-MM-dd"];
        
        NSString *text = [NSString stringWithFormat:@"%@ %@ %@",
                          username, content, time];
        CGFloat fontSize = self.lblContent.font.pointSize;
        
        // If attributed text is supported (iOS6+)
//        if ([self.lblContent respondsToSelector:@selector(setAttributedText:)]) {
//            NSDictionary *attribs = @{
//                                      NSForegroundColorAttributeName: COLOR_BLUE,
//                                      NSFontAttributeName: self.lblContent.font
//                                      };
//            NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString:text attributes:attribs];
//            
//            // Bold text attributes
//            NSRange usernameTextRange = [text rangeOfString:username];
////            [attributedText setAttributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:fontSize]}
////                                    range:usernameTextRange];
//            
//            // Gray text attributes
//            UIColor *grayColor = [UIColor colorWithRed:128/255.0 green:138/255.0 blue:156/255.0 alpha:1.0];
//            NSRange timeTextRange = [text rangeOfString:time];
//            [attributedText setAttributes:@{NSForegroundColorAttributeName:grayColor}
//                                    range:timeTextRange];
//            
//            self.lblContent.attributedText = attributedText;
//        } else { // If attributed text is NOT supported (iOS5-)
            self.lblContent.text = text;
        //        }
    }
}

- (IBAction)tapAvatar:(id)sender {
    if (self.delegate) {
        [self.delegate onSeeNews:self];
    }
}

@end
