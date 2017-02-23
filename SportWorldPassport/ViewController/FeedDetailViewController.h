//
//  FeedDetailViewController.h
//  SportWorldPassport
//
//  Created by star on 12/2/15.
//  Copyright (c) 2015 UWP. All rights reserved.
//

#import "RootViewController.h"
#import "STTwitter.h"

@interface FeedDetailViewController : RootViewController

@property (nonatomic, strong) PFObject *feedObject;
@property (nonatomic) int index;
@property (nonatomic) BOOL isLiked;
@property (nonatomic) BOOL tmpLiked;
@property (nonatomic, retain) UIDocumentInteractionController *dic;
@property (nonatomic, strong) STTwitterAPI *twitter;

@end
