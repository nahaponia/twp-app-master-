//
//  ShareViewController.m
//  SportWorldPassport
//
//  Created by star on 12/2/15.
//  Copyright (c) 2015 UWP. All rights reserved.
//

#import "ShareViewController.h"
#import "MainViewController.h"
#import "UIImage+Convenience.h"
#import "HPGrowingTextView.h"
#import "STTwitter.h"

@interface ShareViewController () <HPGrowingTextViewDelegate, FBSDKSharingDelegate>
{
    IBOutlet UIImageView *imgPost;
    IBOutlet NormalButton *btnShare;
    IBOutlet UITextField *txtTitle;
    IBOutlet UITextField *txtDescription;
    IBOutlet UITextField *txtHashTags;
    IBOutlet UITextField *txtLocation;
    IBOutlet NSLayoutConstraint *descriptHeight;
    IBOutlet NSLayoutConstraint *inputviewHeight;
    IBOutlet UIView *containerView;
    IBOutlet UITableView *tableView;
    IBOutlet UISwitch *switchFacebook;
    IBOutlet UISwitch *switchTwitter;
    IBOutlet UISwitch *switchInstagram;
    
    UIImage *image;
    NSData *videoData;
    NSString *tagString;
}

- (IBAction)onBack:(id)sender;
- (IBAction)onShare:(id)sender;
- (IBAction)onChangedTextField:(id)sender;

@end

@implementation ShareViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (image) {
        [imgPost setImage:image];
//        NSLog(@"image size : %.2f,%.2f, cropmode : %d", image.size.width, image.size.height, [MainViewController getInstance].cropRate);
    }
    
//    txtDescription.minNumberOfLines = 1;
//    txtDescription.maxNumberOfLines = 10;
    txtDescription.textColor = COLOR_BLUE;
    txtDescription.placeholder = @"Description";
//    txtDescription.placeholderColor = [UIColor colorWithRed:167/255.0 green:172/255.0 blue:183/255.0 alpha:1.0];
//    txtDescription.delegate = self;
//    txtDescription.font = [UIFont systemFontOfSize:14.0f];
//    txtDescription.contentInset = UIEdgeInsetsMake(0, -5, -2, -5);
//    txtDescription.internalTextView.scrollIndicatorInsets = UIEdgeInsetsMake(0, 0, 0, 10);
    txtDescription.backgroundColor = [UIColor clearColor];
    
//    CGRect frame = containerView.frame;
//    frame.size.height = SCREEN_WIDTH * 41 / 80 + inputviewHeight.constant + 260;  //each pair = 50
//    [containerView setFrame:frame];
//    [containerView setNeedsLayout];
//    [self.view setNeedsLayout];
    
    tableView.contentSize = containerView.frame.size;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshView:) name:@"refreshView" object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [txtLocation setText:[AppConfig getLocalization]];
}

- (void)setDetailImage:(UIImage *)img {
    image = img;
    [imgPost setImage:image];
}

- (void)setDetailVideoData:(NSData *)data {
    videoData = data;
}

- (IBAction)onBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)onShare:(id)sender {
    UIImage *newImage = [image getCroppedImage:IMAGE_SIZE_NORMAL height:IMAGE_SIZE_NORMAL * image.size.height / image.size.width];
    
    // share image to Facebook, Twitter, Instagram
    if (switchFacebook.isOn){
        [CommonUtils shareImagetoFacebook:image sender:self withView:self.view andDescription:txtDescription.text];
        if (TEST_MODE){
            return;
        }
    }
    if (switchTwitter.isOn){
        [self shareImageToTwitter:image];
        if (TEST_MODE){
            return;
        }
    }
    if (switchInstagram.isOn){
        [CommonUtils shareImagetoInstagram:image sender:self];
        if (TEST_MODE){
            return;
        }
    }
    
    PFObject *object = [PFObject objectWithClassName:PARSE_TABLE_FEED];
    object[PARSE_FIELD_USER]        = [PFUser currentUser];
    object[PARSE_FEED_TITLE]        = txtTitle.text;
    object[PARSE_FEED_DESCRIPT]     = txtDescription.text;
    object[PARSE_FEED_TAGS]         = txtHashTags.text;
    object[PARSE_FEED_NORMAL_PHOTO] = [PFFile fileWithData:UIImagePNGRepresentation(image)];
    object[PARSE_FEED_SMALL_PHOTO]  = [PFFile fileWithData:UIImagePNGRepresentation(newImage)];
    object[PARSE_FEED_CROP_RATE]    = [NSNumber numberWithInt:[MainViewController getInstance].cropRate];
    object[PARSE_FEED_LIKES]        = @[];
    object[PARSE_FEED_COMMENTS]     = @[];
    object[PARSE_FEED_LOCATION]     = txtLocation.text;
    if (videoData != nil){
        object[PARSE_FEED_VIDEO] = [PFFile fileWithName:@"video.mov" data:videoData];
    }
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [object saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        if (succeeded) {
            PFUser *curUser = [PFUser currentUser];
            int postCount = [curUser[PARSE_USER_POST_COUNT] intValue] + 1;
            curUser[PARSE_USER_POST_COUNT] = [NSNumber numberWithInt:postCount];
            [curUser saveInBackground];
            
            [self saveHashTagsInTable];
            
            // send push notifications to followers
            [self sendPush:object];
            
            if (videoData){
                [self.navigationController popViewControllerAnimated:YES];
            } else {
                [self.navigationController dismissViewControllerAnimated:YES completion:^{
                }];
            }
            
        } else {
            NSString *errorString = [error userInfo][@"error"];
            [CommonUtils showAlertView:TITLE_ERROR message:errorString delegate:nil tag:TAG_ERROR];
        }
    }];
    
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
                 oauthCallback:@"travelworldpassport://twitter_access_tokens/"
                    errorBlock:^(NSError *error) {
                        NSLog(@"-- error: %@", error);
                        
                    }];
    
}

- (void) shareImageToTwitter:(UIImage *) img
{
    if (!_twitter){
        NSString *strTwitterToken = [AppConfig getStringValueForKey:@"TwitterToken"];
        NSString * strTwitterTokenSecret = [AppConfig getStringValueForKey:@"TwitterTokenSecret"];
        self.twitter = [STTwitterAPI twitterAPIWithOAuthConsumerKey:TWITTER_CONSUMER_KEY consumerSecret:TWITTER_SECRET_KEY oauthToken:strTwitterToken oauthTokenSecret:strTwitterTokenSecret];
    }
    
    [_twitter postMediaUploadData:UIImagePNGRepresentation(img) fileName:@"Moment" uploadProgressBlock:^(int64_t bytesWritten, int64_t totalBytesWritten, int64_t totoalBytesExpectedToWrite){
        NSLog(@"Posting");
    }successBlock:^(NSDictionary *imageDictionary, NSString *mediaID, NSInteger size){
        NSLog(@"Succeed. MediaId: %@", mediaID);
        [self postTotheTwitterWithMediaId:mediaID];
    }errorBlock:^(NSError *error){
        NSLog(@"Failed: error:%@", error.description);
    }];
}

- (void) postTotheTwitterWithMediaId: (NSString *) mediaID
{
    NSString *msg = [NSString stringWithFormat:@"TravelWorldPassport"];
    [_twitter postStatusesUpdate:msg inReplyToStatusID:nil mediaIDs:[NSArray arrayWithObjects:mediaID, nil] latitude:nil longitude:nil placeID:nil displayCoordinates:nil trimUser:nil autoPopulateReplyMetadata:nil excludeReplyUserIDsStrings:nil attachmentURLString:nil useExtendedTweetMode:nil successBlock:^(NSDictionary *status){
        NSLog(@"-- %@", status);
    } errorBlock:^(NSError *error){
        NSLog(@"-- %@", [error localizedDescription]);
    }];
}

- (void)twitterAPI:(STTwitterAPI *)twitterAPI accountWasInvalidated:(ACAccount *)invalidatedAccount {
    if(twitterAPI != _twitter) return;
    NSLog(@"-- account was invalidated: %@ | %@", invalidatedAccount, invalidatedAccount.username);
}

- (void) refreshView:(NSNotification *) notification
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
        /*
         At this point, the user can use the API and you can read his access tokens with:
         
         _twitter.oauthAccessToken;
         _twitter.oauthAccessTokenSecret;
         
         You can store these tokens (in user default, or in keychain) so that the user doesn't need to authenticate again on next launches.
         
         Next time, just instanciate STTwitter with the class method:
         
         +[STTwitterAPI twitterAPIWithOAuthConsumerKey:consumerSecret:oauthToken:oauthTokenSecret:]
         
         Don't forget to call the -[STTwitter verifyCredentialsWithSuccessBlock:errorBlock:] after that.
         */
        [AppConfig setStringValueForKey:@"TwitterToken" value:self.twitter.oauthAccessToken];
        [AppConfig setStringValueForKey:@"TwitterTokenSecret" value:self.twitter.oauthAccessTokenSecret];
        
        [self onValueChangeTwitter:nil];
        
    } errorBlock:^(NSError *error) {
        NSLog(@"-- %@", [error localizedDescription]);
    }];
}

- (IBAction)onPressFacebook:(id)sender {
    [switchFacebook setOn:!switchFacebook.isOn];
    if (videoData){
        [switchFacebook setOn:NO];
    }
}
- (IBAction)onPressTwtter:(id)sender {
    [switchTwitter setOn:!switchTwitter.isOn];
    if (videoData){
        [switchFacebook setOn:NO];
    }
}
- (IBAction)onPressInstagram:(id)sender {
    [switchInstagram setOn:!switchInstagram.isOn];
}

- (void)sendPush:(PFObject *)post {
    PFQuery *followQuery = [PFQuery queryWithClassName:PARSE_TABLE_FOLLOW];
    [followQuery whereKey:PARSE_FOLLOW_USER equalTo:[PFUser currentUser]];
    [followQuery includeKey:PARSE_FOLLOW_FOLLOWING];
    [followQuery setLimit:QUERY_MAX_LIMIT];
    [followQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error && objects.count > 0) {
            NSMutableArray *followers = [NSMutableArray new];
            for (int i = 0; i < objects.count; i++) {
                PFObject *obj = (PFObject *) objects[i];
                PFUser *follower = obj[PARSE_FOLLOW_FOLLOWING];
                [followers addObject:follower.objectId];
            }
            
//            PFQuery *pushQuery = [PFInstallation query];
//            [pushQuery whereKey:PARSE_FIELD_USER containedIn:followers];
            
            // Send push notification to query
            NSString *alert = [NSString stringWithFormat:@"%@ post new experience: '%@'", [PFUser currentUser].username, post[PARSE_FEED_TITLE]];
            NSDictionary *data = @{
                                   @"alert" : alert,
                                   @"badge" : @"Increment",
                                   @"sounds" : @"cheering.caf",
                                   @"type"  : @"feed",
                                   @"idlist" : followers
                                   };
//            PFPush *push = [[PFPush alloc] init];
//            [push setQuery:pushQuery];
//            [push setData:data];
//            [push sendPushInBackground];
            [PFCloud callFunctionInBackground:@"SendPush" withParameters:data block:^(NSString* result, NSError *error){
                if (error){
                    NSLog(@"%@", error);
                }
            }];
        }
    }];
}

- (IBAction)onChangedTextField:(id)sender {
    // hash tag parse
    if (sender == txtHashTags) {
        txtHashTags.text = [self parseHashTags:txtHashTags.text];
    }
    
    // check enable/disable share button
    NSString *errMsg = [self checkInputValidation];
    
    if ([errMsg isEqualToString:@""]) {
        [btnShare setEnabled:YES];
    } else {
        [btnShare setEnabled:NO];
    }
}

- (void)saveHashTagsInTable {
    NSMutableArray *hashTags = [[NSMutableArray alloc] initWithArray:[txtHashTags.text componentsSeparatedByString:@" "]];
    [hashTags removeObject:@"#"];
    
    for (int i = 0; i < hashTags.count; i++) {
        PFQuery *query = [PFQuery queryWithClassName:PARSE_TABLE_HASHTAG];
        [query whereKey:PARSE_HASHTAG_TAG equalTo:hashTags[i]];
        [query getFirstObjectInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
            if (error && !object) {
                PFObject *object = [PFObject objectWithClassName:PARSE_TABLE_HASHTAG];
                object[PARSE_HASHTAG_TAG] = hashTags[i];
                [object saveInBackground];
            }
        }];
    }
}

#pragma GrowingText view delegate
- (void)growingTextView:(HPGrowingTextView *)growingTextView didChangeHeight:(float)height {
//    NSLog(@"text view height changed: %.1f", height);
   
    descriptHeight.constant = height;
    inputviewHeight.constant = 94 + height;
    
    CGRect frame = containerView.frame;
    frame.size.height = SCREEN_WIDTH * 41 / 80 + inputviewHeight.constant + 260;
    [containerView setFrame:frame];
    [containerView setNeedsLayout];
    [self.view setNeedsLayout];
    
    tableView.contentSize = containerView.frame.size;
    
}

- (void)growingTextViewDidChange:(HPGrowingTextView *)growingTextView {
    NSString *errMsg = [self checkInputValidation];
    
    if ([errMsg isEqualToString:@""]) {
        [btnShare setEnabled:YES];
    } else {
        [btnShare setEnabled:NO];
    }
}

#pragma hash tag parse
- (NSString *)parseHashTags:(NSString *)str {
    if ([str isEqualToString:@""]) {
        return @"";
    }

    // check if backspace pressed and string was " #", then remove last 2 chars
    if (tagString.length == str.length + 1) {
        if ([tagString hasSuffix:@" #"]) {
            str = [str substringToIndex:str.length-1];
        }
    }
    
    BOOL isStartNewTag = NO;
    if ([str hasSuffix:@" "] || [str hasSuffix:@"#"]) {
        isStartNewTag = YES;
    }
    
    NSString *pStr = [str stringByReplacingOccurrencesOfString:@"," withString:@" "];
    pStr = [str stringByReplacingOccurrencesOfString:@"#" withString:@""];
    
    NSMutableArray *tagItems = [[NSMutableArray alloc] initWithArray:[pStr componentsSeparatedByString:@" "]];
    [tagItems removeObject:@""];
    
    NSString *retStr = @"";
    for (int i = 0; i < tagItems.count; i++) {
        if (![retStr isEqualToString:@""]) {
            retStr = [retStr stringByAppendingString:@" "];
        }
        retStr = [retStr stringByAppendingString:@"#"];
        retStr = [retStr stringByAppendingString:tagItems[i]];
    }
    
    if (isStartNewTag) {
        retStr = [retStr stringByAppendingString:@" #"];
    }
    
    tagString = retStr;
    return retStr;
}

#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
}

- (NSString *)checkInputValidation {
    NSString *errMsg = @"";
    NSString *title = txtTitle.text;
    NSString *description = txtDescription.text;
    NSString *tags = txtHashTags.text;
    
    if ([title isEqualToString:@""]) {
        errMsg = [errMsg stringByAppendingString:@"Please input title"];
    }
//    else if ([description isEqualToString:@""]) {
//        errMsg = [errMsg stringByAppendingString:@"%@ Please input password."];
//    }
    else if ([tags isEqualToString:@""]) {
        errMsg = [errMsg stringByAppendingString:@"%@ Please input hashtags."];
    }
    
    return errMsg;
    
}

#pragma mark - Swith Delegate

- (IBAction)onValueChangeFacebook:(id)sender {
    if (videoData){
        [switchFacebook setOn:NO];
        return;
    }
        if (![FBSDKAccessToken currentAccessToken] && switchFacebook.isOn){
            FBSDKLoginManager *loginManager = [[FBSDKLoginManager alloc] init];
            [loginManager logInWithPublishPermissions:@[@"publish_actions"] fromViewController:self handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
                if (error){
                    NSLog(@"%@@", error.description);
                    [CommonUtils showAlertView:@"Facebook Login Failed!" message:error.description delegate:self tag:TAG_ERROR];
                    [switchFacebook setOn:NO];
                } else
                    if (result.isCancelled){
                    [CommonUtils showAlertView:@"" message:@"Facebook Login Cancelled!" delegate:self tag:TAG_ERROR];
                    [switchFacebook setOn:NO];
                } else {
                    NSLog(@"Facebook login success!");
                }
            }];
        }
}
- (IBAction)onValueChangeInstagram:(id)sender {
}
- (IBAction)onValueChangeTwitter:(id)sender {
    if (videoData){
        [switchTwitter setOn:NO];
        return;
    }
    if (!switchTwitter.isOn || [AppConfig getBoolValueForKey:TWITTER_LOGGED_IN]){
        return;
    }
    NSString *strTwitterToken = [AppConfig getStringValueForKey:@"TwitterToken"];
    NSString * strTwitterTokenSecret = [AppConfig getStringValueForKey:@"TwitterTokenSecret"];
    if (![strTwitterToken isEqualToString:@""] && ![strTwitterTokenSecret isEqualToString:@""]){
        self.twitter = [STTwitterAPI twitterAPIWithOAuthConsumerKey:TWITTER_CONSUMER_KEY consumerSecret:TWITTER_SECRET_KEY oauthToken:strTwitterToken oauthTokenSecret:strTwitterTokenSecret];
        [self.twitter verifyCredentialsWithUserSuccessBlock:^(NSString *username, NSString* userId){
            NSLog(@"username: %@", username);
            [AppConfig setBoolValueForKey:TWITTER_LOGGED_IN value:YES];
        } errorBlock:^(NSError* error){
            NSLog(@"result: %@", error.description);
            [CommonUtils showAlertView:@"witter Login Failed!" message:error.description delegate:self tag:TAG_ERROR];
            [switchTwitter setOn:NO];
        }];
    } else {
        [self safariLoginTwitter];
    }
}


#pragma facebook sharing delegate
- (void)sharer:(id<FBSDKSharing>)sharer didCompleteWithResults:(NSDictionary *)results
{
    [CommonUtils showAlertView:@"Sucess" message:@"Moment has been posted to Facebook" delegate:self tag:TAG_SUCCESS];
}

- (void)sharer:(id<FBSDKSharing>)sharer didFailWithError:(NSError *)error
{
    [CommonUtils showAlertView:@"Failed sharing to Facebook" message:error.description delegate:self tag:TAG_ERROR];
}

- (void)sharerDidCancel:(id<FBSDKSharing>)sharer
{
    NSLog(@"Cancelled Share");
}
@end
