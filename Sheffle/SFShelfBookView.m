//
//  SFShelfBookView.m
//  Sheffle
//
//  Created by 桜井雄介 on 2012/07/28.
//  Copyright (c) 2012年 Kaeru Lab. All rights reserved.
//

#import "SFShelfBookView.h"

@interface SFShelfBookView ()
{
    UIImageView *_checkmarkImageView;
}

- (void)buttonClicked:(id)sender;

@end

@implementation SFShelfBookView

@synthesize selected = _selected;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        _checkmarkImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"checkmark.png"]];
        [_checkmarkImageView setHidden:YES];
        [self addSubview:_checkmarkImageView];
        [self addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
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

- (void)setSelected:(BOOL)selected {
    _selected = selected;
    if (_selected) {
        [_checkmarkImageView setHidden:NO];
    }
    else {
        [_checkmarkImageView setHidden:YES];
    }
}

- (BOOL)selected{
    return  _selected;
}

- (void)buttonClicked:(id)sender {
    [self setSelected:_selected ? NO : YES];
}


@end
