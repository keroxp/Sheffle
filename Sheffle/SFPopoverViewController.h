//
//  SFPopoverViewController.h
//  Sheffle
//
//  Created by 桜井雄介 on 2012/11/15.
//  Copyright (c) 2012年 Kaeru Lab. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SFPopoverViewController : UIViewController <UITableViewDelegate,UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UIImageView *aboveView;
@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UIImageView *belowView;
@property (weak, nonatomic) IBOutlet UIView *containerView;

@property (strong, nonatomic) UIView *headerView;
@property (strong, nonatomic) UIView *footerView;

@property (strong, nonatomic, readonly) UIViewController *contentViewController;

- (id)initWithViewContentViewController:(UIViewController*)controller;

- (void)showInView:(UIView*)view animated:(BOOL)animated;
- (void)dismisWithAnimated:(BOOL)animated;

@end
