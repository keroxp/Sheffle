//
//  SFGridShelfViewController.h
//  Sheffle
//
//  Created by 桜井雄介 on 2012/07/28.
//  Copyright (c) 2012年 Kaeru Lab. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

#import "SFCoreDataManager.h"

#import "GSBookShelfView.h"
#import "R9HTTPRequest/R9HTTPRequest.h"

#import "SFShelfBookView.h"
#import "SFShelfRowView.h"

typedef enum {
    BOOK_UNSELECTED,
    BOOK_SELECTED
}BookStatus;

@interface SFGridShelfViewController : UIViewController
<NSFetchedResultsControllerDelegate
,GSBookShelfViewDelegate
,GSBookShelfViewDataSource>

@property (weak, nonatomic) SFShelf *currentShelf;
@property (strong, nonatomic) GSBookShelfView *bookShelfView;
@property (readonly) NSFetchedResultsController *fetchedResultsController;
@property (readonly) NSManagedObjectContext *managedObjectContext;

@end
