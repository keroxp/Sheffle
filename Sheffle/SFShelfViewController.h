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
#import "SFImageDownloader.h"


@interface SFShelfViewController : UIViewController 
<UITableViewDelegate
,UITableViewDataSource
,UISearchBarDelegate
,UISearchDisplayDelegate
,NSFetchedResultsControllerDelegate
,ZBarReaderViewDelegate
,SFImageDownloaderDelegate>

// Core Data
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

// UI
@property (weak, nonatomic) IBOutlet UIView *readerWrapperView;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end
