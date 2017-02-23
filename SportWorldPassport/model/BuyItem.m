//
//  BuyItem.m
//  FANster
//
//  Created by star on 7/9/15.
//  Copyright (c) 2015 com.zapporoo. All rights reserved.
//

#import "BuyItem.h"

@implementation BuyItem

+ (id)ItemWithPrice:(CGFloat)price name:(NSString *)name title:(NSString *)title {
    BuyItem *item = [[BuyItem alloc] init];
    item.price = price;
    item.name = name;
    item.title = title;
    
    return item;
}

@end
