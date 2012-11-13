//
//  SFShelvesViewController.h
//  Sheffle
//
//  Created by 桜井 雄介 on 2012/08/05.
//  Copyright (c) 2012年 Kaeru Lab. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SFCoreDataManager.h"
#import "TDBadgedCell.h"

@interface SFShelvesViewController : UITableViewController
<NSFetchedResultsControllerDelegate
,UITextFieldDelegate
,UISearchDisplayDelegate
,UIAlertViewDelegate>

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;

@end
