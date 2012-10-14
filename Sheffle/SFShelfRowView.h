//
//  SFShelfRowView.h
//  Sheffle
//
//  Created by 桜井雄介 on 2012/07/28.
//  Copyright (c) 2012年 Kaeru Lab. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GSBookShelfCell.h"

@interface SFShelfRowView : UIView
<GSBookShelfCell>

@property(strong,nonatomic) UIImageView *backgroundImageView;
@property(strong,nonatomic) NSString *reuseIdentifier;

@end
