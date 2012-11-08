//
//  SFTabBarViewController.m
//  Sheffle
//
//  Created by 桜井雄介 on 2012/11/08.
//  Copyright (c) 2012年 Kaeru Lab. All rights reserved.
//

#import "SFTabBarViewController.h"

@interface SFTabBarViewController ()

@end

@implementation SFTabBarViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
//    NSDictionary *attrs = @{
//    UITextAttributeFont : [UIFont systemFontOfSize:12.0f],
//    UITextAttributeTextColor : [UIColor darkGrayColor],
//    UITextAttributeTextShadowColor : [NSValue valueWithUIOffset:UIOffsetMake(0, 1)],
//    UITextAttributeTextShadowOffset : [NSValue valueWithUIOffset:UIOffsetZero]};
    
//    self.tabBar.selectionIndicatorImage = [UIImage imageNamed:@"checkmark.png"];
//    self.tabBar.selectedImageTintColor = [UIColor blueColor];
//    
//    for (UITabBarItem *t in self.tabBar.items) {
//        [t setTitleTextAttributes:attrs forState:UIControlStateNormal];
//    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
