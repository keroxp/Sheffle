//
//  SFShelfRowView.m
//  Sheffle
//
//  Created by 桜井雄介 on 2012/07/28.
//  Copyright (c) 2012年 Kaeru Lab. All rights reserved.
//

#import "SFShelfRowView.h"

@interface SFShelfRowView ()
{
    UIImageView *_checkmarkImageView;
}

@end

@implementation SFShelfRowView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        _backgroundImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 120)];
        [_backgroundImageView setImage:[UIImage imageNamed:@"shelfbg.png"]];
        [self addSubview:_backgroundImageView];    
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
