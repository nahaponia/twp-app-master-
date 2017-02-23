//
//  CreateOneStampViewController.m
//  SportWorldPassport
//
//  Created by User 10 on 7/17/16.
//  Copyright © 2016 UWP. All rights reserved.
//

#import "CreateOneStampViewController.h"
#import "DTColorPickerImageView.h"
#import "StampViewController.h"
#import "UIImage+Convenience.h"
#import "GPUImage.h"
#import "CommonUtils.h"

@interface CreateOneStampViewController () <DTColorPickerImageViewDelegate>
{
    IBOutlet UIImageView *bgImageView;
    IBOutlet UIImageView *stampImageView;
    
    UIPickerView * pickerFonttype;
    DTColorPickerImageView * pickerColor;
    
    NSMutableArray *pickerviewArray;
    NSString *selectedPickerVal;
    
    IBOutlet UISwitch *switchLocation;
    UIButton *keyboardBtn;
    UIButton *fonttypeBtn;
    UIButton *colorBtn;
    IBOutlet UIImageView *icon;
    
    IBOutlet UIView *viewStamp;
}

@end

@implementation CreateOneStampViewController

@synthesize feedObject;
@synthesize titleField, lblLocalization;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIView *clearView = [[UIView alloc] initWithFrame:titleField.frame];
    [clearView setTag:501];
    [viewStamp addSubview:clearView];
    
    if (feedObject) {
        // add the blur effect view to the image view
        GPUImageGaussianBlurFilter *blurFilter = [[GPUImageGaussianBlurFilter alloc] init];
        blurFilter.blurRadiusInPixels = 15.0;

        PFFile *smallImage = feedObject[PARSE_FEED_SMALL_PHOTO];
        PFFile *normalImage = feedObject[PARSE_FEED_NORMAL_PHOTO];
        lblLocalization.text = feedObject[PARSE_FEED_LOCATION];
        // set small image at first
        [smallImage getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
            bgImageView.image = [blurFilter imageByFilteringImage: [UIImage imageWithData:data]];
            [stampImageView setImage:[UIImage imageWithData:data]];
            
            // set large image next time
            [normalImage getDataInBackgroundWithBlock:^(NSData *data1, NSError *error) {
                if (!error) {
                    bgImageView.image = [blurFilter imageByFilteringImage: [UIImage imageWithData:data1]];
                    [stampImageView setImage:[UIImage imageWithData:data1]];
                }
            }];
        }];
    }
    
    pickerviewArray = [[NSMutableArray alloc] init];
    for (NSString *familyName in [UIFont familyNames]){
        NSLog(@"Family name: %@", familyName);
        for (NSString *fontName in [UIFont fontNamesForFamilyName:familyName]) {
            NSLog(@"--Font name: %@", fontName);
            [pickerviewArray addObject:fontName];
        }
    }
    
    UIColor *color = [UIColor whiteColor];
    titleField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Text here"
                                attributes:@{NSForegroundColorAttributeName: color}];
    
    // sort by font name
    NSArray *fonts = [pickerviewArray copy];
    fonts = [fonts sortedArrayUsingComparator:^NSComparisonResult(NSString *str1, NSString *str2) {
        return [str1 localizedCaseInsensitiveCompare:str2];
    }];
    pickerviewArray = [NSMutableArray arrayWithArray:fonts];
    
    selectedPickerVal = [pickerviewArray objectAtIndex:0];
    
    UIToolbar * toolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 47)];
//    [toolBar setBackgroundImage:[UIImage imageNamed:@"ic_frame_buttons"] forToolbarPosition:UIToolbarPositionAny barMetrics:UIBarMetricsDefault];
    NSMutableArray * toolBarItems = [NSMutableArray new];
    double w_value = self.view.frame.size.width / 3;
    
    keyboardBtn = [[UIButton alloc] initWithFrame:CGRectMake(0.0, 0.0, w_value, 47.0)];
    [keyboardBtn setBackgroundColor:[UIColor clearColor]];
    [keyboardBtn setTitleColor:[UIColor colorWithRed:128/255.0 green:138/255.0 blue:156/255.0 alpha:1.0] forState:UIControlStateNormal];
    [keyboardBtn setTitleColor:[UIColor colorWithRed:16/255.0 green:151/255.0 blue:255/255.0 alpha:1.0] forState:UIControlStateSelected];
    [keyboardBtn setTitle:@"KEYBOARD" forState:UIControlStateNormal];
    keyboardBtn.titleLabel.font = [UIFont systemFontOfSize:10.0];
    [keyboardBtn addTarget:self action:@selector(onSetTextPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *keyboardBtnItem = [[UIBarButtonItem alloc] initWithCustomView:keyboardBtn];
    [toolBarItems addObject:keyboardBtnItem];
    
    fonttypeBtn = [[UIButton alloc] initWithFrame:CGRectMake(1.0, 0.0, w_value, 47.0)];
    UIView *sideBorder = [[UIView alloc] initWithFrame:CGRectMake(1, 0, 1, fonttypeBtn.frame.size.height)];
    sideBorder.backgroundColor = [UIColor grayColor];
    [fonttypeBtn addSubview:sideBorder];
    [fonttypeBtn setBackgroundColor:[UIColor clearColor]];
    [fonttypeBtn setTitleColor:[UIColor colorWithRed:128/255.0 green:138/255.0 blue:156/255.0 alpha:1.0] forState:UIControlStateNormal];
    [fonttypeBtn setTitleColor:[UIColor colorWithRed:16/255.0 green:151/255.0 blue:255/255.0 alpha:1.0] forState:UIControlStateSelected];
    [fonttypeBtn setTitle:@"FONT TYPE" forState:UIControlStateNormal];
    fonttypeBtn.titleLabel.font = [UIFont systemFontOfSize:10.0];
    [fonttypeBtn addTarget:self action:@selector(onSetFonttypePressed:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *fonttypeBtnItem = [[UIBarButtonItem alloc] initWithCustomView:fonttypeBtn];
    [toolBarItems addObject:fonttypeBtnItem];

    colorBtn = [[UIButton alloc] initWithFrame:CGRectMake(0.0, 0.0, w_value, 47.0)];
    UIView *leftBorder = [[UIView alloc] initWithFrame:CGRectMake(1, 0, 1, colorBtn.frame.size.height)];
    leftBorder.backgroundColor = [UIColor grayColor];
    [colorBtn addSubview:leftBorder];
    [colorBtn setBackgroundColor:[UIColor clearColor]];
    [colorBtn setTitleColor:[UIColor colorWithRed:128/255.0 green:138/255.0 blue:156/255.0 alpha:1.0] forState:UIControlStateNormal];
    [colorBtn setTitleColor:[UIColor colorWithRed:16/255.0 green:151/255.0 blue:255/255.0 alpha:1.0] forState:UIControlStateSelected];
    [colorBtn setTitle:@"COLOR" forState:UIControlStateNormal];
    colorBtn.titleLabel.font = [UIFont systemFontOfSize:10.0];
    [colorBtn addTarget:self action:@selector(onSetColorPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *colorBtnItem = [[UIBarButtonItem alloc] initWithCustomView:colorBtn];
    [toolBarItems addObject:colorBtnItem];
    
    UIBarButtonItem *spacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace  target:nil action:nil];
    toolBarItems = [[NSMutableArray alloc] initWithObjects:spacer, keyboardBtnItem, spacer, fonttypeBtnItem,spacer, colorBtnItem, spacer, nil];
    //UIBarButtonItem * barButton = [[UIBarButtonItem alloc] initWithTitle:@"KEYBOARD" style:UIBarButtonItemStyleDone target:self action:@selector(closeDatePicker:)];
    //UIBarButtonItem * barButton1 = [[UIBarButtonItem alloc] initWithTitle:@"FONTTYPE" style:UIBarButtonItemStyleDone target:self action:@selector(closeDatePicker:)];
//    UIBarButtonItem * barButton2 = [[UIBarButtonItem alloc] initWithTitle:@"COLOR" style:UIBarButtonItemStyleDone target:self action:@selector(closeDatePicker:)];
    //[toolBarItems addObject:barButton1];
//    [toolBarItems addObject:barButton2];
    toolBar.items = toolBarItems;
    keyboardBtn.selected = false;
    fonttypeBtn.selected = false;
    colorBtn.selected = false;
    
//    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
//    [toolBar setItems:[NSArray arrayWithObjects:keyboardBtnItem, fonttypeBtnItem, colorBtnItem, nil]];
    
    titleField.inputAccessoryView = toolBar;
}

- (void) touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [[event allTouches] anyObject];
    if ([[touch view] tag] ==501 && [touch tapCount] == 2){
        [titleField becomeFirstResponder];
    }
}

- (void) touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [[event allTouches] anyObject];
    CGPoint location = [touch locationInView:stampImageView];
    float x = location.x;
    float y = location.y;
    float w = titleField.frame.size.width;
    float h = titleField.frame.size.height;
    float h_b = stampImageView.frame.size.height;
    float w_b = stampImageView.frame.size.width;
    
    CGSize textSize = [[titleField text] sizeWithAttributes:@{NSFontAttributeName:[titleField font]}];
    CGFloat ww = textSize.width;
    if (ww == 0){
        textSize = [[NSString stringWithFormat:@"Text here"] sizeWithAttributes:@{NSFontAttributeName:[titleField font]}];
        ww = textSize.width;
    }
    
    if ( y<10 || y>h_b-h-5 || x<ww/2 || x>w_b - ww/2){
        return;
    }
    
    if ([[touch view] tag] == 501){
        titleField.center = location;
        NSLog(@"%f",location.x);
        [[touch view] setCenter:location];
    }
}

//- (void)closeDatePicker:(UIBarButtonItem *)sender {
//    [cardDateField resignFirstResponder];
//    cardDateField.text = [NSString stringWithFormat:@"%02d / %d", selectedMonth, selectedYear];
//    [self validateForm];
//}
- (IBAction)onChangeSwitch:(id)sender {
    icon.hidden = !switchLocation.on;
    lblLocalization.hidden = !switchLocation.on;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)goToChooseStamps {
    
    for (int i=0; i < self.navigationController.viewControllers.count; i++) {
        if([[self.navigationController.viewControllers objectAtIndex:i] isKindOfClass:[StampViewController class]]) {
            [self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:i] animated:YES];
            return;
        }
    }
}

- (IBAction)onCancelPressd:(id)sender {
    [self goToChooseStamps];
}

- (IBAction)onSavePressed:(id)sender {
    
    if ([titleField.text isEqualToString:@"Text here"] || [titleField.text isEqualToString:@""]){
        titleField.hidden = YES;
        [titleField setText:@""];
    }
    //create stamp
    UIGraphicsBeginImageContextWithOptions(viewStamp.bounds.size, viewStamp.opaque, 0.0);
    [viewStamp.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage * img = UIGraphicsGetImageFromCurrentImageContext();
//    UIImageWriteToSavedPhotosAlbum(img, nil, nil, nil); //save to camera roll
    UIGraphicsEndImageContext();
    
    //send email to manager
    NSData *template = UIImagePNGRepresentation(img);
    UIImage *newImage = [img getCroppedImage:IMAGE_SIZE_LARGE height:IMAGE_SIZE_LARGE * img.size.height / img.size.width];
    
    PFObject *object = [PFObject objectWithClassName:PARSE_TABLE_STAMP];
    object[PARSE_STAMP_USER]        = [PFUser currentUser];
    object[PARSE_STAMP_FEED]        = feedObject;
    object[PARSE_STAMP_TEXT]        = titleField.text;
    object[PARSE_STAMP_FONTTYPE]    = titleField.font.fontName;
    object[PARSE_STAMP_FONTCOLOR]   = [CommonUtils hexStringFromColor:titleField.textColor];
    if (switchLocation.on){
        object[PARSE_STAMP_LOCATION] = lblLocalization.text;
    } else {
        icon.hidden = YES;
    }
    object[PARSE_STAMP_FILE] = [PFFile fileWithData:UIImagePNGRepresentation(newImage)];
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [object saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        if (succeeded) {
            // send push
//            PFQuery *pushQuery = [PFInstallation query];
//            [pushQuery whereKey:PARSE_FIELD_USER containedIn:@[feedObject[PARSE_FIELD_USER]]];
//            
//            // Send push notification to query
//            NSString *alert = [NSString stringWithFormat:@"%@ add new stamp '%@'", [PFUser currentUser].username, object[PARSE_STAMP_TEXT]];
//            NSDictionary *data = @{
//                                   @"alert" : alert,
//                                   @"badge" : @"Increment",
//                                   @"sounds" : @"cheering.caf",
//                                   @"type"  : @"stamp"
//                                   };
//            PFPush *push = [[PFPush alloc] init];
//            [push setQuery:pushQuery];
//            [push setData:data];
//            [push sendPushInBackground];
            [self goToChooseStamps];
        } else {
            NSString *errorString = [error userInfo][@"error"];
            [CommonUtils showAlertView:TITLE_ERROR message:errorString delegate:nil tag:TAG_ERROR];
        }
    }];
}

- (IBAction)onSetTextPressed:(id)sender {
    
    [titleField resignFirstResponder];
    
    keyboardBtn.selected = true;
    fonttypeBtn.selected = false;
    colorBtn.selected = false;
    
    titleField.keyboardType = UIKeyboardTypeEmailAddress;
    titleField.inputView = nil;
    
    [titleField becomeFirstResponder];
}

- (IBAction)onSetFonttypePressed:(id)sender {

    [titleField resignFirstResponder];

    keyboardBtn.selected = false;
    fonttypeBtn.selected = true;
    colorBtn.selected = false;

    pickerFonttype = [[UIPickerView alloc] init];
    pickerFonttype.delegate = (id<UIPickerViewDelegate>)self;
    pickerFonttype.dataSource = (id<UIPickerViewDataSource>)self;
    pickerFonttype.showsSelectionIndicator = NO;
    //pickerFonttype.tag = 1;
    pickerFonttype.backgroundColor = [UIColor whiteColor];
    
    titleField.inputView = pickerFonttype;
    
    [titleField becomeFirstResponder];
}
- (IBAction)onSetColorPressed:(id)sender {

    [titleField resignFirstResponder];

    keyboardBtn.selected = false;
    fonttypeBtn.selected = false;
    colorBtn.selected = true;
    
    if ([UIScreen mainScreen].bounds.size.height == 568) {
        pickerColor = [[DTColorPickerImageView alloc] initWithFrame:CGRectMake(0, 352, 320, 216)];
    }else{
        pickerColor = [[DTColorPickerImageView alloc] initWithFrame:CGRectMake(0, 264, 320, 216)];
    }
    
    [pickerColor setImage:[UIImage imageNamed:@"img_fontcolor_bar"]];
    pickerColor.delegate = (id<DTColorPickerImageViewDelegate>)self;
    
    titleField.inputView = pickerColor;
    
    [titleField becomeFirstResponder];
}

#pragma mark - pickerview delegate
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    
    return pickerviewArray.count;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    return [pickerviewArray objectAtIndex:row];
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view{
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(5, 0, pickerView.frame.size.width-7, 44)];
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor blackColor];
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont fontWithName:[pickerviewArray objectAtIndex:row] size:18];
    label.text = [NSString stringWithFormat:@"%@", [pickerviewArray objectAtIndex:row]];
    return label;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    
    selectedPickerVal = [pickerviewArray objectAtIndex:row];
    
    [titleField setFont:[UIFont fontWithName:selectedPickerVal size:titleField.font.pointSize]];
}

- (void)imageView:(DTColorPickerImageView *)imageView didPickColorWithColor:(nonnull UIColor *)color
{
    [titleField setTextColor:color];
    
    CGFloat red, green, blue;
    [color getRed:&red green:&green blue:&blue alpha:NULL];
    
    NSLog(@"Picked Color Components: %.0f, %.0f, %.0f", red * 255.0f, green * 255.0f, blue * 255.0f);
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
