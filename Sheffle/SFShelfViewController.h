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

#import "R9HTTPRequest.h"
#import "ZBarSDK.h"
#import "SBJson.h"
#import "SVProgressHUD.h"

#import "SFBookViewController.h"
#import "SFTableShelfViewController.h"
#import "SFGridShelfViewController.h"

typedef enum{
    SFShelfViewModeGrid = 0,
    SFShelfViewModeTable
}SFShelfViewMode;

@interface SFShelfViewController : UIViewController 
<ZBarReaderViewDelegate
,NSFetchedResultsControllerDelegate>

// View Controllers
@property (strong, nonatomic) SFGridShelfViewController *gridShelfViewController;
@property (strong, nonatomic) SFTableShelfViewController *tableShelfViewController;
// View Mode
@property (readonly) SFShelfViewMode shelfViewMode;
// Core Data
@property (strong, nonatomic) NSFetchedResultsController* fetchedresultsController;
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
