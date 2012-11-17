//
//  SFBarButtonItem.m
//  Sheffle
//
//  Created by 桜井雄介 on 2012/11/17.
//  Copyright (c) 2012年 Kaeru Lab. All rights reserved.
//

#import "SFBarButtonItem.h"
#define kBarTintColor [UIColor colorWithRed:214.0f/255.0f green:168.0f/255.0f blue:91.0f/255.0f alpha:1.0f]

@implementation SFBarButtonItem

- (id)initWithBarButtonSystemItem:(UIBarButtonSystemItem)systemItem target:(id)target action:(SEL)action
{
    self = [super initWithBarButtonSystemItem:systemItem target:target action:action];
    if (self) {
        self.tintColor = kBarTintColor;
    }
    return self;
}

@end
