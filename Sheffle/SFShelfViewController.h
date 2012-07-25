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
#import "SFTableShelfViewController.h"
#import "SFGridShelfViewController.h"

typedef enum{
    SFShelfViewModeTable = 0,
    SFShelfViewModeGrid
}SFShelfViewMode;

@interface SFShelfViewController : UIViewController 
<ZBarReaderViewDelegate
,SFImageDownloaderDelegate>

// Core Data
@property (weak, nonatomic) NSManagedObjectContext *managedObjectContext;

// View Controllers
@property (strong, nonatomic) SFGridShelfViewController *gridShelfViewController;
@property (strong, nonatomic) SFTableShelfViewController *tableShelfViewController; 

// UI
@property (strong, nonatomic) UIView *readerView;
@property (strong, nonatomic) UIView *shelfView;

@end
