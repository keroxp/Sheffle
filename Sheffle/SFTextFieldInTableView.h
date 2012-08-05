//
//  SFTextFieldInTableView.h
//  Sheffle
//
//  Created by 桜井 雄介 on 2012/08/06.
//  Copyright (c) 2012年 Kaeru Lab. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SFTextFieldInTableView : UITextField

@property (strong, nonatomic) NSIndexPath *indexPath;

- (id)initWithFrame:(CGRect)frame indexPath:(NSIndexPath*)indexPath;

@end
