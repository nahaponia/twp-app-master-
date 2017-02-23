//
//  CategoryInputCell.h
//  SportWorldPassport
//
//  Created by star on 1/25/16.
//  Copyright © 2016 UWP. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CategoryInputCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UITextField *txtTitle;

- (IBAction)onDelete:(id)sender;

@end
