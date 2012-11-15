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

@protocol SFShelvesViewDelegate;

@interface SFShelvesViewController : UITableViewController
<NSFetchedResultsControllerDelegate
,UITextFieldDelegate
,UISearchDisplayDelegate
,UIAlertViewDelegate
>

@property (weak, nonatomic) id<SFShelvesViewDelegate> delegate;
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;

@end

@protocol SFShelvesViewDelegate <NSObject>

- (void)shelvesViewController:(SFShelvesViewController*)controller didSelectShelf:(SFShelf*)shelf;

@end