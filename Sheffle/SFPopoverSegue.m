//
//  SFPopoverSegue.m
//  Sheffle
//
//  Created by 桜井雄介 on 2012/11/16.
//  Copyright (c) 2012年 Kaeru Lab. All rights reserved.
//

#import "SFPopoverSegue.h"
#import "SFPopoverViewController.h"

@implementation SFPopoverSegue

- (void)perform
{
    SFPopoverViewController *pop = [[SFPopoverViewController alloc] initWithViewContentViewController:self.destinationViewController];
    [pop showInView:self.sourceViewController animated:YES];
}

@end
