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

@protocol SFTableShelfViewDelegate;

@interface SFTableShelfViewController : UITableViewController
<UISearchBarDelegate
,UISearchDisplayDelegate
,NSFetchedResultsControllerDelegate
>

// Core Data
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;

// Delegation
@property (weak, nonatomic) id<SFTableShelfViewDelegate> delegate;

@end

@protocol SFTableShelfViewDelegate

- (void)shelfViewModeWillChange:(NSUInteger)mode;

@end