//
//  SFNavigationBar.m
//  Sheffle
//
//  Created by 桜井雄介 on 2012/11/17.
//  Copyright (c) 2012年 Kaeru Lab. All rights reserved.
//

#import "SFNavigationBar.h"
#import "SFAppDelegate.h"

@implementation SFNavigationBar

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
    if (__IPHONE_OS_VERSION_MIN_REQUIRED >= __IPHONE_5_0) {
        [self setBackgroundImage:[UIImage imageNamed:@"barbg.png"] forBarMetrics:UIBarMetricsDefault];
    }
    if (__IPHONE_OS_VERSION_MIN_REQUIRED >= __IPHONE_6_0) {
        [self setShadowImage:[UIImage imageNamed:@"navbarshadow.png"]];
    }

}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
//- (void)drawRect:(CGRect)rect
//{
    // Drawing code
//}


@end
