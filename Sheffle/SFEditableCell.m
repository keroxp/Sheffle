//
//  SFEditableCell.m
//  Sheffle
//
//  Created by 桜井 雄介 on 2012/08/05.
//  Copyright (c) 2012年 Kaeru Lab. All rights reserved.
//

#import "SFEditableCell.h"

@implementation SFEditableCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (id)initWithText:(NSString *)text indexPath:(NSIndexPath *)indexPath reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    if (self) {
        _textField = [[SFTextFieldInTableView alloc] initWithFrame:CGRectMake(10, 11, 35, 21) indexPath:indexPath];
//        _textField = [[ alloc] initWithFrame:CGRectMake(10, 11, 35, 21)];
        _textField.indexPath = indexPath;
        self.textField.borderStyle = UITextBorderStyleNone;
        self.textField.font = [UIFont boldSystemFontOfSize:18.0];
        self.textField.returnKeyType = UIReturnKeyDone;
        self.textField.clearButtonMode = UITextFieldViewModeWhileEditing;
        self.textField.text = text;
        [self addSubview:self.textField];
    }
    return self;   
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
