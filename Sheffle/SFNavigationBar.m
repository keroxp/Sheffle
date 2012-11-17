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
    SFAppDelegate *ad = [[UIApplication sharedApplication] delegate];
    if (ad.iOSVersionMajor >= 5) {
        [self setBackgroundImage:[UIImage imageNamed:@"barbg.png"] forBarMetrics:UIBarMetricsDefault];
    }
    if (ad.iOSVersionMajor >= 6) {
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
