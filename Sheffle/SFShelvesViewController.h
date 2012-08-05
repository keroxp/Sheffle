//
//  SFShelvesViewController.h
//  Sheffle
//
//  Created by 桜井 雄介 on 2012/08/05.
//  Copyright (c) 2012年 Kaeru Lab. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SFCoreDataManager.h"
#import "SFEditableCell.h"
#import "UITextField+IndexPath.h"

@interface SFShelvesViewController : UITableViewController
<NSFetchedResultsControllerDelegate
,UITextFieldDelegate
,UISearchDisplayDelegate>

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;

@end
