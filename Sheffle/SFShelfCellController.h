//
//  SFShelfCellController.h
//  Sheffle
//
//  Created by 桜井雄介 on 2012/11/08.
//  Copyright (c) 2012年 Kaeru Lab. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SFShelfCell : UITableViewCell

@end

@interface SFShelfCellController : UIViewController

@property (weak,nonatomic) IBOutlet SFShelfCell *cell;

@end
