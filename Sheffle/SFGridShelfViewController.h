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

#import "SFShelfViewController.h"
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

//@property (weak, nonatomic) SFShelf *shelf;
@property (strong, nonatomic) GSBookShelfView *bookShelfView;
@property (weak,nonatomic) NSFetchedResultsController *fetchedResultsController;

@property (strong, nonatomic) NSMutableArray *bookStatus;
@property (strong, nonatomic) NSMutableIndexSet *booksIndexsToBeRemoved;
@property (nonatomic) BOOL editMode;
//@property (assign, nonatomic) SFShelfType shelfType;

- (void)initBooks;
- (void)insertBookViewsAtIndexPath:(NSIndexPath *)indexPath animated:(BOOL)animated;
- (void)removeBookViewsAtIndexPath:(NSIndexPath *)indexPath animated:(BOOL)animated;

- (void)switchToNormalMode;
- (void)switchToEditMode;

@end


