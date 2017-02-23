//
//  EditPostViewController.h
//  SportWorldPassport
//
//  Created by star on 1/26/16.
//  Copyright © 2016 UWP. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol EditPostDelegate <NSObject>
- (void)didChangedPost:(PFObject *)object;
@end

@interface EditPostViewController : UIViewController

@property (nonatomic, strong) PFObject *postObject;
@property (nonatomic, strong) id<EditPostDelegate> delegate;

@end
