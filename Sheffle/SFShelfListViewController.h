//
//  SFShelfListViewController.h
//  Sheffle
//
//  Created by 桜井 雄介 on 2012/08/28.
//  Copyright (c) 2012年 Kaeru Lab. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SFCoreDataManager.h"

@interface SFShelfListViewController : UITableViewController

@property(strong,nonatomic) NSArray *shelves;
@property(strong,nonatomic) SFShelf *currentShelf;
@property(strong,nonatomic) NSSet *booksToBeMoved;

@end
