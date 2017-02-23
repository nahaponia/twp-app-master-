//
//  CreateOneStampViewController.h
//  SportWorldPassport
//
//  Created by User 10 on 7/17/16.
//  Copyright © 2016 UWP. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CreateOneStampViewController : UIViewController <UIPickerViewDelegate, UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *titleField;
@property (weak, nonatomic) IBOutlet UILabel *lblLocalization;

@property (nonatomic, strong) PFObject *feedObject;

@end
