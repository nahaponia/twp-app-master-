//
//  StampViewController.h
//  SportWorldPassport
//
//  Created by developer on 06/07/16.
//  Copyright © 2016 UWP. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface StampViewController : UIViewController<UICollectionViewDelegate, UIGestureRecognizerDelegate> {
    
    NSMutableArray *stampArray;
}
@property (weak, nonatomic) IBOutlet UICollectionView *mGalleryView;
- (void) onEditOrDeselectAll;
//- (void) onPrint;
- (void) onPreView;
- (BOOL) isNewSelected: (int)rowNum;
- (void) showPrintView;
- (void) initialize;
- (void) gotoEditViewController;
- (void) gotoPrintViewController;

@property (weak, nonatomic) IBOutlet UILabel *mLblSelected;
@property (weak, nonatomic) IBOutlet UILabel *mLblTheme;
@property (weak, nonatomic) IBOutlet UILabel *mLblSufix;
@property (weak, nonatomic) IBOutlet UIButton *mBtnEdit;
@property (weak, nonatomic) IBOutlet UIButton *mBtnPay;

@property (strong, nonatomic) NSIndexPath *currentIndexPath;
@end
