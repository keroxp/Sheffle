//
//  SFTableShelfViewController.h
//  Sheffle
//
//  Created by  on 12/07/24.
//  Copyright (c) 2012年 Kaeru Lab. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "SFCoreDataManager.h"
#import "SFBookViewController.h"
#import "SFShelfViewController.h"

@interface SFTableShelfViewController : UITableViewController
<UISearchBarDelegate
,UISearchDisplayDelegate
,NSFetchedResultsControllerDelegate
>

// Core Data
@property (weak, nonatomic) NSFetchedResultsController *fetchedResultsController;
//@property (assign, nonatomic) SFShelfType shelfType;

@end