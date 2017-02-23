//
//  FeedDetailViewController.m
//  SportWorldPassport
//
//  Created by star on 12/2/15.
//  Copyright (c) 2015 UWP. All rights reserved.
//

#import "FeedDetailViewController.h"
#import "ParseUtils.h"
#import "AAPullToRefresh.h"
#import "CommentCell.h"
#import "MomentOperatViewController.h"
#import "UIImage+Convenience.h"
#import "AppConfig.h"
#import <FBSDKShareKit/FBSDKShareKit.h>
#import <AVFoundation/AVFoundation.h>
#import <Photos/Photos.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "ProfileViewController.h"

@interface FeedDetailViewController()<UITextViewDelegate, FBSDKSharingDelegate, CommentCellDelegate>
{
    NSMutableArray *commentArray;
    PFUser *poster;
    
    IBOutlet UIImageView *feedImageView;
    IBOutlet UIView *videoView;
    IBOutlet NSLayoutConstraint *feedImageHeight;
    IBOutlet CircleImageView *avatarImageView;
    IBOutlet UILabel *lblUsername;
    IBOutlet UILabel *lblFullName;
    IBOutlet UILabel *lblLikedCount;
    IBOutlet UILabel *lblCommentCount;
    IBOutlet UIButton *btnDescription;
    IBOutlet UIButton *btnComment;
    IBOutlet UIView *descriptView;
    IBOutlet UILabel *lblFeedTitle;
    IBOutlet UITextView *lblDescription;
    IBOutlet NSLayoutConstraint *descriptHeight;
    IBOutlet UILabel *lblUserNameInDescript;
    IBOutlet NSLayoutConstraint *privateShareHeight;
    IBOutlet UITextView *lblTags;
    IBOutlet NSLayoutConstraint *tagsHeight;
    IBOutlet UIView *commentView;
    IBOutlet UITableView *commentTableView;
    IBOutlet UITextField *txtComment;
    
    IBOutlet UIView *contentView;
    IBOutlet UITableView *contentTableView;
    IBOutlet UIButton *btnMute;
    
    BOOL mCommentInitialized;
    AAPullToRefresh *topRefreshView;
    NSString *placeholder;
    
    AVPlayer *avplayer;
    IBOutlet UIButton *btnGoogle;
    IBOutlet UIImageView *imgLike;
    IBOutlet UIButton *btnLike;
    
    CMTime currentTime;
}

- (IBAction)onBack:(id)sender;
- (IBAction)shareWithFacebook:(id)sender;
- (IBAction)shareWithTwitter:(id)sender;
- (IBAction)shareWithGoogle:(id)sender;
- (IBAction)onSelectDescription:(id)sender;
- (IBAction)onSelectComment:(id)sender;
- (IBAction)onSubmitComment:(id)sender;

@end

@implementation FeedDetailViewController

@synthesize feedObject, index;

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    txtComment.delegate = self;
    placeholder = @"Add Comment";
    
    commentArray = [[NSMutableArray alloc] init];
    
    [self onSelectDescription:nil];
    
    __weak typeof(self) weakSelf = self;
    topRefreshView = [commentTableView addPullToRefreshPosition:AAPullToRefreshPositionTop ActionHandler:^(AAPullToRefresh *v){
        [weakSelf refreshItems];
    }];
    
    if (feedObject) {
        poster = feedObject[PARSE_FIELD_USER];
        
        PFFile *smallImage = feedObject[PARSE_FEED_SMALL_PHOTO];
        PFFile *normalImage = feedObject[PARSE_FEED_NORMAL_PHOTO];
        
        // video view
        if (feedObject[PARSE_FEED_VIDEO]){
            feedImageView.hidden = YES;
            videoView.hidden = NO;
            btnMute.hidden = NO;
            if (avplayer){
                [avplayer play];
            } else {
                [self showVideoMoment:feedObject[PARSE_FEED_VIDEO]];
            }
        } else {
            videoView.hidden = YES;
            feedImageView.hidden = NO;
            btnMute.hidden = YES;
        }
        
        // set small image at first
        [smallImage getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
            [feedImageView setImage:[UIImage imageWithData:data]];
            
            // set large image next time
            [normalImage getDataInBackgroundWithBlock:^(NSData *data1, NSError *error) {
                if (!error) {
                    [feedImageView setImage:[UIImage imageWithData:data1]];
                }
            }];
        }];
        
        [ParseUtils setParsePictureOf:avatarImageView file:poster[PARSE_USER_AVATAR] default:nil];
        lblUsername.text = poster.username;
        lblFullName.text = [NSString stringWithFormat:@"%@ %@", poster[PARSE_USER_FIRSTNAME], poster[PARSE_USER_LASTNAME]];
        lblFeedTitle.text = feedObject[PARSE_FEED_TITLE];
        lblDescription.text = feedObject[PARSE_FEED_DESCRIPT];
        lblUserNameInDescript.text = @"";
        lblTags.text = feedObject[PARSE_FEED_TAGS];
        lblLikedCount.text = [NSString stringWithFormat:@"%d", [feedObject[PARSE_FEED_LIKE_COUNT] intValue]];
        lblCommentCount.text = [NSString stringWithFormat:@"%d", [feedObject[PARSE_FEED_COMMENT_COUNT] intValue]];
        
        // set Post image height
        int cropRate = [feedObject[PARSE_FEED_CROP_RATE] intValue];
        CGFloat imageRate = (cropRate == CROP_3_4) ? 1.33 : (cropRate == CROP_4_3 ? 0.75 : 1.0);
        CGFloat imageHeight = SCREEN_WIDTH * imageRate;
        feedImageHeight.constant = imageHeight;
        
        // set description Height
        float contentWidth = SCREEN_WIDTH - 24;
        NSDictionary *attributes = @{NSFontAttributeName: [UIFont systemFontOfSize:14]};
        CGRect rect = [feedObject[PARSE_FEED_DESCRIPT] boundingRectWithSize:CGSizeMake(contentWidth, CGFLOAT_MAX)
                                                                    options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading
                                                                 attributes:attributes context:nil];
        
        descriptHeight.constant = rect.size.height + 12;
        
        // set tags Height
        attributes = @{NSFontAttributeName: [UIFont boldSystemFontOfSize:14.0]};
        rect = [feedObject[PARSE_FEED_TAGS] boundingRectWithSize:CGSizeMake(contentWidth, CGFLOAT_MAX)
                                                                    options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading
                                                                 attributes:attributes context:nil];
        
        tagsHeight.constant = rect.size.height + 12;
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshViewTwitter:) name:@"refreshViewTwitter" object:nil];
    
    _tmpLiked = _isLiked;
    if (_isLiked){
        [imgLike setImage:[UIImage imageNamed:@"ic_like_bg"]];
    } else {
        [imgLike setImage:[UIImage imageNamed:@"ic_unlike_bg"]];
    }
    
    // background mode
    if (!videoView.isHidden){
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appEnteredForeground) name:UIApplicationWillEnterForegroundNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appEnteredBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];
    }
}

-(void) appEnteredForeground {
//    AVPlayerLayer *player = (AVPlayerLayer *)[videoView layer];
//    [player setPlayer:NULL];
//    [player setPlayer:avplayer];
    [self playAt:currentTime];
}

-(void) appEnteredBackground {
    [avplayer pause];
    currentTime = [avplayer currentTime];
}

-(void)playAt: (CMTime)time {
    if(avplayer.status == AVPlayerStatusReadyToPlay && avplayer.currentItem.status == AVPlayerItemStatusReadyToPlay) {
        [avplayer seekToTime:time toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero completionHandler:^(BOOL finished) {
            [avplayer play];
        }];
    } else {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self playAt:time];
        });
    }
}

- (void) viewDidUnload
{
    [super viewDidUnload];
    if (avplayer){
        [avplayer pause];
        avplayer = nil;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self refreshTableViewContent];
    // default setting of refresh view
    topRefreshView.showPullToRefresh = YES;
    
    NSURL *instagramURL = [NSURL URLWithString:@"instagram://app"];
    if(![[UIApplication sharedApplication] canOpenURL:instagramURL]){
        btnGoogle.hidden = YES;
    } else {
        btnGoogle.hidden = NO;
    }
    
    if (avplayer != nil){
        [avplayer setMuted:NO];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    // default setting of refresh view
    topRefreshView.showPullToRefresh = NO;
    
    if (avplayer != nil){
        [avplayer setMuted:YES];
    }
    
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    [dic setValue:lblLikedCount.text forKey:@"likedCount"];
    [NSNotificationCenter.defaultCenter postNotificationName:NOTIFICATION_DETAIL_LIKE object:nil userInfo:dic];
}

- (void) showVideoMoment:(PFFile *)file
{
    NSString *docPath = [self getDocumentDirectoryPath];
    NSString *filePath = [NSString stringWithFormat:@"%@/%@", docPath, file.name];
    BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:filePath];
    if (fileExists){
        //play video
        [self playVideo:filePath];
    } else {
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        [file getDataInBackgroundWithBlock:^(NSData *data, NSError *error){
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            if (error){
                NSLog(@"Error get Video Data from Server");
            } else {
                //save to file
                [data writeToFile:filePath atomically:YES];
                //play video
                [self playVideo:filePath];
            }
        }];
    }
}

- (void) playVideo:(NSString *)filePath{
    NSURL *url = [NSURL fileURLWithPath:filePath];
    avplayer = [AVPlayer playerWithURL:url];
    avplayer.actionAtItemEnd = AVPlayerActionAtItemEndNone;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerItemDidReachEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:[avplayer currentItem]];
    AVPlayerLayer *videoLayer = [AVPlayerLayer playerLayerWithPlayer:avplayer];
    videoLayer.frame = CGRectMake(0, 0, self.view.bounds.size.width, 320);
    videoLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    [videoView.layer addSublayer:videoLayer];
    [self playAt:kCMTimeZero];
//    [avplayer play];
}


- (NSString *) getDocumentDirectoryPath
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDirectory = [paths objectAtIndex:0];
    return documentDirectory;
}

- (void)playerItemDidReachEnd:(NSNotification *) notification // video end notificaton
{
    AVPlayerItem *process = [notification object];
    [process seekToTime:kCMTimeZero];
}

- (void)refreshItems {
    if (btnComment.isSelected) { // followed tap selected
        mCommentInitialized = YES;
        
        PFQuery *query = [PFQuery queryWithClassName:PARSE_TABLE_COMMENT];
        [query whereKey:PARSE_COMMENT_FEED equalTo:feedObject];
        [query includeKey:PARSE_FOLLOW_USER];
        [query setLimit:QUERY_MAX_LIMIT];
        [query orderByDescending:PARSE_FIELD_CREATED_AT];
        
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            [commentArray removeAllObjects];
        
            int count = objects.count;
            if (!error && objects && count > 0) {
                for (int i = 0; i < count; i++) {
                    [commentArray addObject:objects[count - i - 1]];
                }
            }
            
            [topRefreshView performSelector:@selector(stopIndicatorAnimation) withObject:nil afterDelay:0.1f];
            [commentTableView reloadData];
            if (count > 0) {
                [commentTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:count - 1] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
            }
            
            if (btnComment.isSelected) {
                
            }
        }];
    }
}
- (IBAction)onTapAvatar:(id)sender {
    PFQuery *query = [PFQuery queryWithClassName:PARSE_TABLE_FOLLOW];
    [query whereKey:PARSE_FOLLOW_USER equalTo:poster];
    [query whereKey:PARSE_FOLLOW_FOLLOWING equalTo:[PFUser currentUser]];
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [query getFirstObjectInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        BOOL isFollowed = NO;
        if (!error && object) {
            isFollowed = YES;
        }
        ProfileViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"ProfileViewController"];
        vc.user = poster;
        vc.isFollowed = isFollowed;
        [self.navigationController pushViewController:vc animated:YES];
    }];
}
- (IBAction)onTapLike:(id)sender {
    int likeCount = [lblLikedCount.text intValue];
    if (_tmpLiked){
        [imgLike setImage:[UIImage imageNamed:@"ic_unlike_bg"]];
        [lblLikedCount setText:[NSString stringWithFormat:@"%d", likeCount - 1]];
    } else {
        [imgLike setImage:[UIImage imageNamed:@"ic_like_bg"]];
        [lblLikedCount setText:[NSString stringWithFormat:@"%d", likeCount + 1]];
    }
    _tmpLiked = !_tmpLiked;
    
    [ParseUtils likeFeed:feedObject like:_tmpLiked withView:self.view];
}

- (void)refreshTableViewContent {
    if ([btnDescription isSelected]) {
        CGFloat contentHeight = feedImageHeight.constant + descriptHeight.constant + tagsHeight.constant + 300;
        CGRect rect = contentView.frame;
        rect.size.height = contentHeight;
        [contentView setFrame:rect];
        [contentTableView setContentSize:CGSizeMake(SCREEN_WIDTH, contentHeight)];
    } else {
        if (!mCommentInitialized) {
            [topRefreshView manuallyTriggered];
        }
    }
}


#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return commentArray.count;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CommentCell *cell = [tableView dequeueReusableCellWithIdentifier:@"commentCell"];
    if (index == indexPath.row){
        cell.boldIndex = 100;
    } else {
        cell.boldIndex = -1;
    }
    [cell setdata:commentArray[indexPath.row]];
    cell.delegate = self;
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    PFObject *object = commentArray[indexPath.row];
    NSString *comment = object[PARSE_COMMENT_TEXT];
    
    // set description Height
    float commentWidth = SCREEN_WIDTH - 80;
    NSDictionary *attributes = @{NSFontAttributeName: [UIFont systemFontOfSize:14]};
    CGRect rect = [comment boundingRectWithSize:CGSizeMake(commentWidth, CGFLOAT_MAX)
                                        options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading
                                     attributes:attributes context:nil];
    
    return rect.size.height + 110.0;
}

- (IBAction)onBack:(id)sender {
    index = -1;
    if (avplayer){
        [avplayer pause];
        avplayer = nil;
    }
    [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)onOperation:(id)sender {
    MomentOperatViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"MomentOperatViewController"];
    vc.bgImage = [UIImage imageWithView:self.view];
    vc.feedObject = feedObject;
//    [self.navigationController pushViewController:vc animated:NO];
    [self presentViewController:vc animated:YES completion:nil];
}

- (IBAction)shareWithFacebook:(id)sender {
    [CommonUtils shareImagetoFacebook:feedImageView.image sender:self withView:self.view andDescription:lblDescription.text];
}

- (IBAction)shareWithTwitter:(id)sender {
    if (![AppConfig getBoolValueForKey:TWITTER_LOGGED_IN]){
        [self safariLoginTwitter];
    } else {
        [self shareImageToTwitter:feedImageView.image];
    }
}
- (void) safariLoginTwitter
{
    self.twitter = [STTwitterAPI twitterAPIWithOAuthConsumerKey:TWITTER_CONSUMER_KEY
                                                 consumerSecret:TWITTER_SECRET_KEY];
    [_twitter postTokenRequest:^(NSURL *url, NSString *oauthToken) {
        NSLog(@"-- url: %@", url);
        NSLog(@"-- oauthToken: %@", oauthToken);
        [[UIApplication sharedApplication] openURL:url];
    } authenticateInsteadOfAuthorize:YES
                    forceLogin:@(NO)
                    screenName:nil
                 oauthCallback:@"travelworldpassports://twitter_access_tokens/"
                    errorBlock:^(NSError *error) {
                        NSLog(@"-- error: %@", error);
                        
                    }];
    
}

- (STTwitterAPI *) getTwitter
{
    if (!self.twitter){
        self.twitter = [STTwitterAPI twitterAPIWithOAuthConsumerKey:TWITTER_CONSUMER_KEY
                                                     consumerSecret:TWITTER_SECRET_KEY];
    }
    return self.twitter;
}

- (void) refreshViewTwitter:(NSNotification *) notification
{
    NSDictionary *d = [notification userInfo];
    NSString *token = d[@"oauth_token"];
    NSString *verifier = d[@"oauth_verifier"];
    [self setOAuthToken:token oauthVerifier:verifier];
}

- (void)setOAuthToken:(NSString *)token oauthVerifier:(NSString *)verifier {
    
    // in case the user has just authenticated through WebViewVC
    [_twitter postAccessTokenRequestWithPIN:verifier successBlock:^(NSString *oauthToken, NSString *oauthTokenSecret, NSString *userID, NSString *screenName) {
        NSLog(@"-- screenName: %@", screenName);
        [AppConfig setStringValueForKey:@"TwitterToken" value:self.twitter.oauthAccessToken];
        [AppConfig setStringValueForKey:@"TwitterTokenSecret" value:self.twitter.oauthAccessTokenSecret];
        NSString *strTwitterToken = [AppConfig getStringValueForKey:@"TwitterToken"];
        NSString * strTwitterTokenSecret = [AppConfig getStringValueForKey:@"TwitterTokenSecret"];
        
        if (![strTwitterToken isEqualToString:@""] && ![strTwitterTokenSecret isEqualToString:@""]){
            self.twitter = [STTwitterAPI twitterAPIWithOAuthConsumerKey:TWITTER_CONSUMER_KEY consumerSecret:TWITTER_SECRET_KEY oauthToken:strTwitterToken oauthTokenSecret:strTwitterTokenSecret];
            [self.twitter verifyCredentialsWithUserSuccessBlock:^(NSString *username, NSString* userId){
                NSLog(@"username: %@", username);
                [AppConfig setBoolValueForKey:TWITTER_LOGGED_IN value:YES];
                [self shareImageToTwitter:feedImageView.image];
            } errorBlock:^(NSError* error){
                NSLog(@"result: %@", error.description);
                [CommonUtils showAlertView:@"witter Login Failed!" message:error.description delegate:self tag:TAG_ERROR];
            }];
        }
    } errorBlock:^(NSError *error) {
        NSLog(@"-- %@", [error localizedDescription]);
    }];
}
- (void) shareImageToTwitter:(UIImage *) img
{
    if (!_twitter){
        NSString *strTwitterToken = [AppConfig getStringValueForKey:@"TwitterToken"];
        NSString * strTwitterTokenSecret = [AppConfig getStringValueForKey:@"TwitterTokenSecret"];
        self.twitter = [STTwitterAPI twitterAPIWithOAuthConsumerKey:TWITTER_CONSUMER_KEY consumerSecret:TWITTER_SECRET_KEY oauthToken:strTwitterToken oauthTokenSecret:strTwitterTokenSecret];
    }
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [_twitter postMediaUploadData:UIImagePNGRepresentation(img) fileName:@"Moment" uploadProgressBlock:^(int64_t bytesWritten, int64_t totalBytesWritten, int64_t totoalBytesExpectedToWrite){
        NSLog(@"Posting");
    }successBlock:^(NSDictionary *imageDictionary, NSString *mediaID, NSInteger size){
        NSLog(@"Succeed. MediaId: %@", mediaID);
        [self postTotheTwitterWithMediaId:mediaID];
    }errorBlock:^(NSError *error){
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        NSLog(@"Failed: error:%@", error.description);
    }];
    
}

- (void) postTotheTwitterWithMediaId: (NSString *) mediaID
{
    NSString *msg = [NSString stringWithFormat:@"TravelWorldPassport"];
    [_twitter postStatusesUpdate:msg inReplyToStatusID:nil mediaIDs:[NSArray arrayWithObjects:mediaID, nil] latitude:nil longitude:nil placeID:nil displayCoordinates:nil trimUser:nil autoPopulateReplyMetadata:nil excludeReplyUserIDsStrings:nil attachmentURLString:nil useExtendedTweetMode:nil successBlock:^(NSDictionary *status){
        NSLog(@"-- %@", status);
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        [CommonUtils showAlertView:@"Success" message:@"Moment tweeted successfully" delegate:self tag:TAG_SUCCESS];
    } errorBlock:^(NSError *error){
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        [CommonUtils showAlertView:@"Error" message:[error localizedDescription] delegate:self tag:TAG_ERROR];
        NSLog(@"-- %@", [error localizedDescription]);
    }];
}

- (IBAction)onMuteChange:(id)sender {
    if (avplayer.isMuted){
        [btnMute setImage:[UIImage imageNamed:@"ic_muted"] forState:UIControlStateNormal];
        [avplayer setMuted:false];
    } else {
        [btnMute setImage:[UIImage imageNamed:@"ic_nomuted"] forState:UIControlStateNormal];
        [avplayer setMuted:true];
    }
}

- (IBAction)shareWithGoogle:(id)sender {
//    [self shareWithInstagram];    // old
    [self shareInstagram];
}

- (void) shareInstagram
{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    UIImageWriteToSavedPhotosAlbum(feedImageView.image, self, @selector(image:didFinishSavingWithError:contextInfo:), (void*)CFBridgingRetain(@{@"caption" : @"SportsWoldPassport"}));
}

- (void) image: (UIImage *) image didFinishSavingWithError: (NSError *) error
   contextInfo: (void *) contextInfoPtr {
    PHAsset *asset = nil;
    PHFetchOptions *fetchOptions = [[PHFetchOptions alloc] init];
    fetchOptions.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:YES]];
    PHFetchResult *fetchResult = [PHAsset fetchAssetsWithMediaType:PHAssetMediaTypeImage options:fetchOptions];
    asset = [fetchResult lastObject];
    NSString *localID = asset.localIdentifier;
    NSString *url = [NSString stringWithFormat:@"instagram://library?LocalIdentifier=%@",localID];
    NSURL *instagramUrl = [NSURL URLWithString:url];
    [[UIApplication sharedApplication] openURL:instagramUrl];
    [MBProgressHUD hideHUDForView:self.view animated:YES];
}

- (void) shareWithInstagram {
    ////////////////  Instagram  ////////////
    UIImage *imgShare = feedImageView.image;
    NSURL *instagramURL = [NSURL URLWithString:@"instagram://app"];
    //    if([[UIApplication sharedApplication] canOpenURL:instagramURL]) //check for App is install or not
    {
        //get image URL
        UIImage *imageToUse = imgShare;
        NSString *documentDirectory=[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
        NSString *saveImagePath=[documentDirectory stringByAppendingPathComponent:@"Image.igo"];
        NSData *imageData=UIImagePNGRepresentation(imageToUse);
        [imageData writeToFile:saveImagePath atomically:YES];
        NSURL *imageURL=[NSURL fileURLWithPath:saveImagePath];
        
        self.dic=[[UIDocumentInteractionController alloc]init];
        self.dic = [UIDocumentInteractionController interactionControllerWithURL:imageURL];
        self.dic.delegate = self;
        self.dic.annotation = [NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"Share Experience"], @"InstagramCaption", nil];
        self.dic.UTI = @"com.instagram.exclusivegram";
        UIViewController *vc = [UIApplication sharedApplication].keyWindow.rootViewController;
        [self.dic presentOpenInMenuFromRect:CGRectMake(1, 1, 1, 1) inView:vc.view animated:YES];
    }
}

- (IBAction)onSelectDescription:(id)sender {
    [btnDescription setSelected:YES];
    [btnComment setSelected:NO];
    
    [descriptView setHidden:NO];
    [commentView setHidden:YES];
}

- (IBAction)onSelectComment:(id)sender {
    [btnDescription setSelected:NO];
    [btnComment setSelected:YES];
    
    [descriptView setHidden:YES];
    [commentView setHidden:NO];
    
    if (!mCommentInitialized) {
        [topRefreshView manuallyTriggered];
    }
}

- (IBAction)onSubmitComment:(id)sender {
    if ([txtComment.text isEqualToString:@""]){
        return;
    }
    PFObject *object = [PFObject objectWithClassName:PARSE_TABLE_COMMENT];
    object[PARSE_COMMENT_FEED] = feedObject;
    object[PARSE_COMMENT_TEXT] = txtComment.text;
    object[PARSE_FIELD_USER] = [PFUser currentUser];
    object[PARSE_COMMENT_LIKES] = @[];
    object[PARSE_COMMENT_DISLIKES] = @[];
    [object saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        if (succeeded) {
            txtComment.text = @"";
            [commentArray addObject:object];
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:commentArray.count - 1 inSection:0];
            [commentTableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            [commentTableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
            
            // increase comment count
            lblCommentCount.text = [NSString stringWithFormat:@"%d", [feedObject[PARSE_FEED_COMMENT_COUNT] intValue] + 1];
            [feedObject fetch];
            NSMutableArray *comments = [[NSMutableArray alloc] initWithArray:feedObject[PARSE_FEED_COMMENTS]];
            [comments addObject:object.objectId];
            feedObject[PARSE_FEED_COMMENTS] = comments;
            [feedObject saveInBackground];
            
            // add comment news history
            PFUser *poster = feedObject[PARSE_FIELD_USER];
            if (![poster.objectId isEqualToString:[PFUser currentUser].objectId]){
                PFObject *news = [PFObject objectWithClassName:PARSE_TABLE_NEWS];
                news[PARSE_NEWS_FEED] = feedObject;
                news[PARSE_NEWS_USER] = feedObject[PARSE_FIELD_USER];
                news[PARSE_NEWS_POSTER] = [PFUser currentUser];
                news[PARSE_NEWS_TYPE] = [NSNumber numberWithInt:NEWS_COMMENT];
                
                [news saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    if (error) {
                        NSLog(@"error %@", error.description);
                    }
                }];
                
                NSString *alert = [NSString stringWithFormat:@"%@ add new comment to your post: '%@'", [PFUser currentUser].username, feedObject[PARSE_FEED_TITLE]];
                PFUser *user = (PFUser *) feedObject[PARSE_FIELD_USER];
                NSDictionary *data = @{
                                       @"alert" : alert,
                                       @"badge" : @"Increment",
                                       @"sounds" : @"cheering.caf",
                                       @"type"  : @"feed",
                                       @"idlist" : [NSArray arrayWithObject:user.objectId]
                                       };
                [PFCloud callFunctionInBackground:@"SendPush" withParameters:data block:^(NSString* result, NSError *error){
                    if (error){
                        NSLog(@"%@", error);
                    }
                }];
            }
            
            // send push
//            PFQuery *pushQuery = [PFInstallation query];
//            [pushQuery whereKey:PARSE_FIELD_USER containedIn:@[feedObject[PARSE_FIELD_USER]]];
//            
//            // Send push notification to query
//            NSString *alert = [NSString stringWithFormat:@"%@ add new comment to your post '%@'", [PFUser currentUser].username, feedObject[PARSE_FEED_TITLE]];
//            NSDictionary *data = @{
//                                   @"alert" : alert,
//                                   @"badge" : @"Increment",
//                                   @"sounds" : @"cheering.caf",
//                                   @"type"  : @"comment"
//                                   };
//            PFPush *push = [[PFPush alloc] init];
//            [push setQuery:pushQuery];
//            [push setData:data];
//            [push sendPushInBackground];
            
            
        }
    }];
}

- (IBAction)onTextChanged:(id)sender {
    NSString *string = [txtComment text];
    if ([string length] > 255){
        NSRange needleRange = NSMakeRange(0, 254);
        string = [string substringWithRange:needleRange];
    }
    
    [txtComment setText:string];
}

- (void) resetTextField {
    txtComment.textColor = (__bridge UIColor * _Nullable)([UIColor grayColor].CGColor);
    txtComment.text = placeholder;
}

// textView delegate
- (void)textViewDidEndEditing:(UITextView *)textView;
{
    if (![txtComment.text isEqualToString:@""]){
        [self onSubmitComment:nil];
    }
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    [self onTextChanged:nil];
    return YES;
}

- (void)sharer:(id<FBSDKSharing>)sharer didCompleteWithResults:(NSDictionary *)results
{
    [CommonUtils showAlertView:@"Success" message:@"Moment has been posted to Facebook" delegate:self tag:TAG_SUCCESS];
}

- (void)sharer:(id<FBSDKSharing>)sharer didFailWithError:(NSError *)error
{
    [CommonUtils showAlertView:@"Failed sharing to Facebook" message:error.description delegate:self tag:TAG_ERROR];
}

- (void)sharerDidCancel:(id<FBSDKSharing>)sharer
{
    NSLog(@"Cancelled Share");
}

#pragma CommentCell delegate
- (void) onSeeUser:(CommentCell *)cell
{
    PFQuery *query = [PFQuery queryWithClassName:PARSE_TABLE_FOLLOW];
    [query whereKey:PARSE_FOLLOW_USER equalTo:cell.poster];
    [query whereKey:PARSE_FOLLOW_FOLLOWING equalTo:[PFUser currentUser]];
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [query getFirstObjectInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        BOOL isFollowed = NO;
        if (!error && object) {
            isFollowed = YES;
        }
        ProfileViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"ProfileViewController"];
        vc.user = cell.poster;
        vc.isFollowed = isFollowed;
        [self.navigationController pushViewController:vc animated:YES];
    }];
}

@end
