//
//  SFTextFieldInTableView.m
//  Sheffle
//
//  Created by 桜井 雄介 on 2012/08/06.
//  Copyright (c) 2012年 Kaeru Lab. All rights reserved.
//

#import "SFTextFieldInTableView.h"

@implementation SFTextFieldInTableView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame indexPath:(NSIndexPath *)indexPath
{
    self = [super initWithFrame:frame];
    if (self) {
        _indexPath = indexPath;
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
