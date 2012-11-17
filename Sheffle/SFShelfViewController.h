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
#import "SFTableShelfViewController.h"
#import "SFGridShelfViewController.h"
#import "SFShelvesViewController.h"

typedef enum{
    SFShelfViewModeGrid = 0,
    SFShelfViewModeTable
}SFShelfViewMode;

typedef enum{
    SFBookSortTypeTitle = 0,
    SFBookSortTypeAuthor,
    SFBookSortTypePublisher
}SFBookSortType;

@class SFShelvesViewController, SFGridShelfViewController, SFTableShelfViewController;

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
// Core Data
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) SFShelf *shelf;
// UI
@property (strong, nonatomic) UIView *readerView;
@property (strong, nonatomic) UIView *shelfView;
// Buttons
@property (strong, nonatomic) UIBarButtonItem *trashButton;
@property (strong, nonatomic) UIBarButtonItem *moveButton;
@property (strong, nonatomic) UIBarButtonItem *staredButton;

- (NSFetchedResultsController*)fetchedResultsControllerWithEntityName:(NSString*)entityName;

@end

