//
//  PrintStampTreeViewController.h
//  SportWorldPassport
//
//  Created by User 10 on 7/16/16.
//  Copyright © 2016 UWP. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DeliveryAndBillingModel;

@interface PrintStampTreeViewController : UIViewController<UICollectionViewDelegate, UICollectionViewDataSource>
@property (nonatomic, strong) NSMutableArray *stampArray;
@property (strong, nonatomic) IBOutlet UICollectionView *mGalleryView;
@property (weak, nonatomic) IBOutlet UIView *mView;
@property (nonatomic, strong) DeliveryAndBillingModel* model;

@end
