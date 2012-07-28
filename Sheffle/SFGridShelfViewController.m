//
//  SFGridShelfViewController.m
//  Sheffle
//
//  Created by 桜井雄介 on 2012/07/28.
//  Copyright (c) 2012年 Kaeru Lab. All rights reserved.
//

#import "SFGridShelfViewController.h"

#define ROW_HEIGHT 140.0f

@interface SFGridShelfViewController ()
{

    NSMutableArray *_bookArray;
    NSMutableArray *_bookStatus;
    
    NSMutableIndexSet *_booksIndexsToBeRemoved;
    
    BOOL _editMode;
    
    UIBarButtonItem *_editBarButton;
    UIBarButtonItem *_cancleBarButton;
    UIBarButtonItem *_trashBarButton;
    UIBarButtonItem *_addBarButton;
}

@end

@implementation SFGridShelfViewController

@synthesize managedObjectContext = __managedObjectContext;
@synthesize fetchedResultsController = __fetchedResultsController;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

/*
 // Implementing the above methods to update the table view in response to individual changes may have performance implications if a large number of changes are made simultaneously. If this proves to be an issue, you can instead just implement controllerDidChangeContent: which notifies the delegate that all section and object changes have been processed.
 
 - (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
 {
 // In the simplest, most efficient, case, reload the table view.
 [self.tableView reloadData];
 }
 */

#pragma mark - View lifecycle

- (void)testScrollToRow {
    [_bookShelfView scrollToRow:34 animate:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self initBarButtons];
    [self switchToNormalMode];
	[self initBooks];
    
    [self.bookShelfView setContentOffset:CGPointMake(0, 120)];
    
    _bookShelfView = [[GSBookShelfView alloc] initWithFrame:CGRectMake(0, 0, 320, 460 - 88)];
    [_bookShelfView setDataSource:self];
    //[_bookShelfView setShelfViewDelegate:self];
    
    [self.view addSubview:_bookShelfView];
    
    //[self performSelector:@selector(testScrollToRow) withObject:self afterDelay:3];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return YES;
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    if (UIDeviceOrientationIsLandscape(toInterfaceOrientation)) {
        [_bookShelfView setFrame:CGRectMake(0, 0, 480, 320 - 44)];
    }
    else {
        [_bookShelfView setFrame:CGRectMake(0, 0, 320, 460 - 44)];
    }
    [_bookShelfView reloadData];
}

- (void)initBooks {
    NSInteger numberOfBooks = 100;
    _bookArray = [[NSMutableArray alloc] initWithCapacity:numberOfBooks];
    _bookStatus = [[NSMutableArray alloc] initWithCapacity:numberOfBooks];
    for (int i = 0; i < numberOfBooks; i++) {
        NSNumber *number = [NSNumber numberWithInt:i % 4 + 1];
        [_bookArray addObject:number];
        [_bookStatus addObject:[NSNumber numberWithInt:BOOK_UNSELECTED]];
    }
    
    _booksIndexsToBeRemoved = [NSMutableIndexSet indexSet];
}

- (void)initBarButtons {
    _editBarButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(editButtonClicked:)];
    _cancleBarButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancleButtonClicked:)];
    
    _trashBarButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(trashButtonClicked:)];
    _addBarButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addButtonClicked:)];
}

- (void)switchToNormalMode {
    _editMode = NO;
    
    [self.navigationItem setLeftBarButtonItem:_editBarButton];
    [self.navigationItem setRightBarButtonItem:_addBarButton];
}

- (void)switchToEditMode {
    _editMode = YES;
    [_booksIndexsToBeRemoved removeAllIndexes];
    [self.navigationItem setLeftBarButtonItem:_cancleBarButton];
    [self.navigationItem setRightBarButtonItem:_trashBarButton];
    
    for (int i = 0; i < [_bookArray count]; i++) {
        [_bookStatus addObject:[NSNumber numberWithInt:BOOK_UNSELECTED]];
    }
    
    for (SFShelfBookView *bookView in [_bookShelfView visibleBookViews]) {
        [bookView setSelected:NO];
    }
}

#pragma mark GSBookShelfViewDataSource

- (NSInteger)numberOfBooksInBookShelfView:(GSBookShelfView *)bookShelfView {
    return [_bookArray count];
}

- (NSInteger)numberOFBooksInCellOfBookShelfView:(GSBookShelfView *)bookShelfView {
    UIDeviceOrientation orientation = [UIDevice currentDevice].orientation;
    if (UIDeviceOrientationIsLandscape(orientation)) {
        return 4;
    }
    else {
        return 3;
    }
}

- (UIView *)bookShelfView:(GSBookShelfView *)bookShelfView bookViewAtIndex:(NSInteger)index {
    static NSString *identifier = @"bookView";
    SFShelfBookView *bookView = (SFShelfBookView*)[bookShelfView dequeueReuseableBookViewWithIdentifier:identifier];
    if (bookView == nil) {
        bookView = [[SFShelfBookView alloc] initWithFrame:CGRectZero];
        bookView.reuseIdentifier = identifier;
        [bookView addTarget:self action:@selector(bookViewClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    [bookView setIndex:index];
    [bookView setSelected:[(NSNumber *)[_bookStatus objectAtIndex:index] intValue]];
    [bookView setBackgroundImage:[UIImage imageNamed:@"book.png"] forState:UIControlStateNormal];
    return bookView;
}

- (UIView *)bookShelfView:(GSBookShelfView *)bookShelfView cellForRow:(NSInteger)row {
    static NSString *identifier = @"GridShelfCell";
    SFShelfRowView *rowView = (SFShelfRowView*)[bookShelfView dequeueReuseableCellViewWithIdentifier:identifier];
    if (rowView == nil) {
        rowView = [[SFShelfRowView alloc] initWithFrame:CGRectZero];
        rowView.reuseIdentifier = identifier;
    }
    return rowView;
}

- (UIView *)aboveTopViewOfBookShelfView:(GSBookShelfView *)bookShelfView {
    UIView *atv = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 120*2)];
    SFShelfRowView *srv1 = [[SFShelfRowView alloc] initWithFrame:CGRectMake(0, 0, 320, 120)];
    SFShelfRowView *srv2 = [[SFShelfRowView alloc] initWithFrame:CGRectMake(0, 120, 320, 120)];
    [atv addSubview:srv1];
    [atv addSubview:srv2];
    return atv;
}

- (UIView *)belowBottomViewOfBookShelfView:(GSBookShelfView *)bookShelfView {
    UIView *bbv = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 120*2)];
    SFShelfRowView *srv1 = [[SFShelfRowView alloc] initWithFrame:CGRectMake(0, 0, 320, 120)];
    SFShelfRowView *srv2 = [[SFShelfRowView alloc] initWithFrame:CGRectMake(0, 120, 320, 120)];
    [bbv addSubview:srv1];
    [bbv addSubview:srv2];
    return bbv;
}

- (UIView *)headerViewOfBookShelfView:(GSBookShelfView *)bookShelfView {
    
    SFShelfRowView *srv = [[SFShelfRowView alloc] initWithFrame:CGRectMake(0, 0, 320, 120)];
    return srv;
    
    UIDeviceOrientation orientation = [UIDevice currentDevice].orientation;
    if (UIDeviceOrientationIsLandscape(orientation)) {
//        [_searchBar setFrame:CGRectMake(0, 0, 480, 44)];
    }
    else {
//        [_searchBar setFrame:CGRectMake(0, 0, 320, 44)];
    }
    
    return nil;
}

- (CGFloat)cellHeightOfBookShelfView:(GSBookShelfView *)bookShelfView {
//    return 125.0f;
    return 120.0f;
}

- (CGFloat)cellMarginOfBookShelfView:(GSBookShelfView *)bookShelfView {
    return 25.0f;
}

- (CGFloat)bookViewHeightOfBookShelfView:(GSBookShelfView *)bookShelfView {
    return 100.0f;
}

- (CGFloat)bookViewWidthOfBookShelfView:(GSBookShelfView *)bookShelfView {
    return 69.0f;
}

- (CGFloat)bookViewBottomOffsetOfBookShelfView:(GSBookShelfView *)bookShelfView {
    return 120.0f - 9.0f;
}

- (CGFloat)cellShadowHeightOfBookShelfView:(GSBookShelfView *)bookShelfView {
    return 0.0f;
}

- (void)bookShelfView:(GSBookShelfView *)bookShelfView moveBookFromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex {
    if ([(NSNumber *)[_bookStatus objectAtIndex:fromIndex] intValue] == BOOK_SELECTED) {
        [_booksIndexsToBeRemoved removeIndex:fromIndex];
        [_booksIndexsToBeRemoved addIndex:toIndex];
    }
    
    [_bookArray moveObjectFromIndex:fromIndex toIndex:toIndex];
    [_bookStatus moveObjectFromIndex:fromIndex toIndex:toIndex];
    
    // the bookview is recognized by index in the demo, so change all the indexes of affected bookViews here
    // This is just a example, not a good one.In your code, you'd better use a key to recognize the bookView.
    // and you won't need to do the following

    SFShelfBookView *bookView = (SFShelfBookView *)[_bookShelfView bookViewAtIndex:toIndex];
    [bookView setIndex:toIndex];
    if (fromIndex <= toIndex) {
        for (int i = fromIndex; i < toIndex; i++) {
            bookView = (SFShelfBookView*)[_bookShelfView bookViewAtIndex:i];
            [bookView setIndex:bookView.index - 1];
        }
    }
    else {
        for (int i = toIndex + 1; i <= fromIndex; i++) {
            bookView = (SFShelfBookView*)[_bookShelfView bookViewAtIndex:i];
            [bookView setIndex:bookView.index + 1];
        }
    }
}

#pragma mark - BarButtonListener

- (void)editButtonClicked:(id)sender {
    [self switchToEditMode];
}

- (void)cancleButtonClicked:(id)sender {
    [self switchToNormalMode];
}

- (void)trashButtonClicked:(id)sender {
    [_bookArray removeObjectsAtIndexes:_booksIndexsToBeRemoved];
    [_bookStatus removeObjectsAtIndexes:_booksIndexsToBeRemoved];
    [_bookShelfView removeBookViewsAtIndexs:_booksIndexsToBeRemoved animate:YES];
    [self switchToNormalMode];
}

- (void)addButtonClicked:(id)sender {
    int a[6] = {1, 2, 5, 7, 9, 22};
    NSMutableIndexSet *indexSet = [NSMutableIndexSet indexSet];
    NSMutableArray *arr = [NSMutableArray array];
    NSMutableArray *stat = [NSMutableArray array];
    for (int i = 0; i < 6; i++) {
        [indexSet addIndex:a[i]];
        [arr addObject:[NSNumber numberWithInt:1]];
        [stat addObject:[NSNumber numberWithInt:BOOK_UNSELECTED]];
    }
    [_bookArray insertObjects:arr atIndexes:indexSet];
    [_bookStatus insertObjects:stat atIndexes:indexSet];
    [_bookShelfView insertBookViewsAtIndexs:indexSet animate:YES];
}

#pragma mark - BookView Listener

- (void)bookViewClicked:(UIButton *)button {
    SFShelfBookView *bookView = (SFShelfBookView*)button;
    
    if (_editMode) {
        NSNumber *status = [NSNumber numberWithInt:bookView.selected];
        [_bookStatus replaceObjectAtIndex:bookView.index withObject:status];
        
        if (bookView.selected) {
            [_booksIndexsToBeRemoved addIndex:bookView.index];
        }
        else {
            [_booksIndexsToBeRemoved removeIndex:bookView.index];
        }
    }
    else {
        [bookView setSelected:NO];
    }
}

#pragma mark - Core Data

- (NSManagedObjectContext *)managedObjectContext
{
    if (!__managedObjectContext) {
        __managedObjectContext = [[SFCoreDataManager sharedManager] managedObjectContext];
    }
    return __managedObjectContext;
}

- (NSFetchedResultsController *)fetchedResultsController
{
    if (__fetchedResultsController != nil) {
        return __fetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Book" inManagedObjectContext:__managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    
    // Edit the sort key as appropriate.
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"title" ascending:NO];
    NSArray *sortDescriptors = [NSArray arrayWithObjects:sortDescriptor, nil];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:__managedObjectContext sectionNameKeyPath:nil cacheName:@"Master"];
    [aFetchedResultsController setDelegate:self];
    __fetchedResultsController = aFetchedResultsController;
    
	NSError *error = nil;
	if (![self.fetchedResultsController performFetch:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
	    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
	    abort();
	}
    
    return __fetchedResultsController;
    
}


@end
