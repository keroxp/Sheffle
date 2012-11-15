//
//  SFPopoverViewController.m
//  Sheffle
//
//  Created by 桜井雄介 on 2012/11/15.
//  Copyright (c) 2012年 Kaeru Lab. All rights reserved.
//

#import "SFPopoverViewController.h"

#define kAboveHeight 28
#define kTopHeihgt 2
#define kBottomHeight 2
#define kBelogHeight 6

@interface SFPopoverViewController ()
{
    UIImageView *_top;
    UIImageView *_bottom;
    UIView *_overlay;
}

@end

@implementation SFPopoverViewController

@synthesize headerView = _headerView, footerView = _footerView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
    }
    return self;
}

- (id)initWithViewContentViewController:(UIViewController *)controller
{
    self = [super initWithNibName:@"SFPopoverViewController" bundle:nil];
    
    if (self) {
        [[NSBundle mainBundle] loadNibNamed:@"SFPopoverViewController" owner:self options:nil];
        if ([controller isKindOfClass:[UINavigationController class]]) {
            UINavigationController *nc = (UINavigationController*)controller;
            [nc.navigationBar setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"popoverbarbg.png"]]];
            [nc.toolbar setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"popoverbarbg.png"]]];
        }
        [self addChildViewController:controller];
        [controller didMoveToParentViewController:self];
        _contentViewController = controller;
        
        [self.contentViewController.view setFrame:self.contentView.frame];
        UIImageView *top = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"popovertop.png"]];
        UIImageView *bottom = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"popoverbottom.png"]];
        _top = top;
        _bottom = bottom;
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)showInView:(UIView *)view animated:(BOOL)animated
{
    
    if (!_overlay) {
        _overlay = [[UIView alloc] initWithFrame:view.frame];
        _overlay.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
    }
    
    // Configure View
    
    self.view.frame = view.frame;
    [view addSubview:_overlay];

    // Configure Content View
    
    CGRect contentView = self.contentView.bounds;
    contentView.size.height =  CGRectGetHeight(self.contentViewController.view.frame) - kBelogHeight- kAboveHeight;
    self.contentView.frame = contentView;
    [self.contentView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"popoverbg.png"]]];
    
    CGFloat w = CGRectGetWidth(self.contentView.bounds);
    CGFloat h = CGRectGetHeight(self.contentView.bounds);

    CGRect contentViewController = self.contentView.frame;
    contentViewController.size.width = w - 15;
    contentViewController.origin.x = 8;
    self.contentViewController.view.frame = contentViewController;
    
    [self.contentView addSubview:self.contentViewController.view];
//    [self.contentViewController.view setAlpha:0];
    
    //Configure Below Point
    CGRect below = CGRectZero;
    below.size = CGSizeMake(w, kBelogHeight);
    below.origin.y = h - kBelogHeight;
    self.belowView.frame = below;
    
    // Top Overkay
    CGRect top = CGRectZero;
    top.size = CGSizeMake(w, kTopHeihgt);
    _top.frame = top;
    [self.contentView addSubview:_top];
    
    // Bottom Overlay
    CGRect bottom = CGRectZero;
    bottom.size = CGSizeMake(w, kBottomHeight);
    bottom.origin.y = h - kBottomHeight;
    _bottom.frame = bottom;
    [self.contentView addSubview:_bottom];
    
    if (animated) {
        _overlay.alpha = 0.0f;
        self.view.alpha = 0.0f;
        [view addSubview:self.view];
        [UIView animateWithDuration:0.4 animations:^(){
            self.view.alpha = 1.0f;
            _overlay.alpha = 1.0f;
        }];
    }else{
        self.view.alpha = 1.0f;
        _overlay.alpha = 1.0f;
        [view addSubview:self.view];
    }
}

- (void)dismisWithAnimated:(BOOL)animated
{
    [_overlay.superview setUserInteractionEnabled:YES];
    
    if (animated) {
        [UIView animateWithDuration:0.4 animations:^(){
            self.view.alpha = 0;
            _overlay.alpha = 0;
        } completion:^(BOOL finished){
            [self.view removeFromSuperview];
            [_overlay removeFromSuperview];
        }];
    }else{
        [_overlay removeFromSuperview];
        [self.view removeFromSuperview];
    }
}

#pragma mark - Getter / Setter

- (void)setHeaderView:(UIView *)headerView
{
    
}

- (void)setFooterView:(UIView *)footerView
{
    
}

@end
