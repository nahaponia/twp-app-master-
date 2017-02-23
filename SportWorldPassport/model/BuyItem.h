//
//  BuyItem.h
//  FANster
//
//  Created by star on 7/9/15.
//  Copyright (c) 2015 com.zapporoo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BuyItem : NSObject

@property (nonatomic, assign) CGFloat price;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *title;

+ (id)ItemWithPrice:(CGFloat)price name:(NSString *)name title:(NSString *)title;

@end
