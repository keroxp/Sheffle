//
//  SFGridShelfViewController.h
//  Sheffle
//
//  Created by  on 12/07/24.
//  Copyright (c) 2012年 Kaeru Lab. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GSBookShelfView.h"

@interface SFGridShelfViewController : UIViewController
<GSBookShelfViewDelegate
,GSBookShelfViewDataSource>

@property (weak, nonatomic) IBOutlet GSBookShelfView *bookShelfView;

@end
