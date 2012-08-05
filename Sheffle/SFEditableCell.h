//
//  SFEditableCell.h
//  Sheffle
//
//  Created by 桜井 雄介 on 2012/08/05.
//  Copyright (c) 2012年 Kaeru Lab. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SFTextFieldInTableView.h"

@interface SFEditableCell : UITableViewCell

@property (strong,nonatomic) SFTextFieldInTableView *textField;

- (id)initWithText:(NSString*)text indexPath:(NSIndexPath*)indexPath reuseIdentifier:(NSString *)reuseIdentifier;

@end
