//
//  SFGridShelfViewController.m
//  Sheffle
//
//  Created by  on 12/07/24.
//  Copyright (c) 2012年 Kaeru Lab. All rights reserved.
//

#import "SFGridShelfViewController.h"

@implementation SFGridShelfViewController
@synthesize bookShelfView;

- (void)viewDidUnload {
    [self setBookShelfView:nil];
    [super viewDidUnload];
}
@end
