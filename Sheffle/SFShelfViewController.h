//
//  SFShelfViewController.h
//  Sheffle
//
//  Created by 桜井 雄介 on 12/07/22.
//  Copyright (c) 2012年 Kaeru Lab. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import <QuartzCore/QuartzCore.h>
#import <SBJson/SBJson.h>

#import "ZBarSDK.h"
#import "SVProgressHUD.h"
#import "SVPullToRefresh.h"

#import "SFBookViewController.h"
#import "SFShelvesViewController.h"

typedef enum{
    SFShelfViewModeGrid = 0,
    SFShelfViewModeTable
}SFShelfViewMode;

typedef enum{
    SFShelfTypeNormal = 0,
    SFShelfTypeAll,
    SFShelfTypeFavorite
}SFShelfType;

typedef enum{
    SFBookSortTypeTitle = 0,
    SFBookSortTypeAuthor,
    SFBookSortTypePublisher
}SFBookSortType;

@class SFShelvesViewController, SFGridShelfViewController, SFTableShelfViewController, GSBookShelfView;

@interface SFShelfViewController : UIViewController 
<ZBarReaderViewDelegate
,SFShelvesViewDelegate
,NSFetchedResultsControllerDelegate>

// View Controllers
@property (strong, nonatomic) SFShelvesViewController *shelvesViewController;
@property (strong, nonatomic) SFGridShelfViewController *gridShelfViewController;
@property (strong, nonatomic) SFTableShelfViewController *tableShelfViewController;
// View Mode
@property (readonly) SFShelfViewMode shelfViewMode;
@property (assign, nonatomic) SFBookSortType sortType;
@property (assign, nonatomic, readonly) SFShelfType shelfType;
// Core Data
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic, readonly) SFShelf *shelf;
// UI
@property (strong, nonatomic) UIView *readerView;
@property (strong, nonatomic) UIView *shelfView;
// Accecor
@property (readonly) UITableView *tableView;
@property (readonly) GSBookShelfView* bookShelfView;

// Buttons
@property (strong, nonatomic) UIBarButtonItem *trashButton;
@property (strong, nonatomic) UIBarButtonItem *moveButton;
@property (strong, nonatomic) UIBarButtonItem *staredButton;

- (void)setShelf:(SFShelf *)shelf forShelfType:(SFShelfType)shelfType;

@end

