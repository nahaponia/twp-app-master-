//
//  CategoryInputCell.m
//  SportWorldPassport
//
//  Created by star on 1/25/16.
//  Copyright © 2016 UWP. All rights reserved.
//

#import "CategoryInputCell.h"

@implementation CategoryInputCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)onDelete:(id)sender {
    self.txtTitle.text = @"";
}

@end
