//
//  SFShelfViewController.h
//  Sheffle
//
//  Created by 桜井 雄介 on 12/07/22.
//  Copyright (c) 2012年 Kaeru Lab. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "R9HTTPRequest.h"
#import "ZBarSDK.h"
#import "SBJson.h"
#import "SVProgressHUD.h"
#import "SFBookViewController.h"
#import "SFImageDownloader.h"


@interface SFShelfViewController : UITableViewController <NSFetchedResultsControllerDelegate,ZBarReaderViewDelegate,SFImageDownloaderDelegate>

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

@end
