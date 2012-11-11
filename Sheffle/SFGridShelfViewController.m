//
//  SFGridShelfViewController.m
//  Sheffle
//
//  Created by 桜井雄介 on 2012/07/28.
//  Copyright (c) 2012年 Kaeru Lab. All rights reserved.
//

#import "SFGridShelfViewController.h"
#import "SFShelfViewController.h"

#define ROW_HEIGHT 140.0f
#define kNavigationBarHeight self.parentViewController.navigationController.navigationBar.frame.size.height
#define kToolbarHeight self.parentViewController.navigationController.toolbar.frame.size.height
#define kTabBarHeight self.parentViewController.tabBarController.tabBar.frame.size.height

@interface SFGridShelfViewController ()
{    
}

@end

@implementation SFGridShelfViewController

@synthesize fetchedResultsController = __fetchedResultsController;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

#pragma mark - View lifecycle

- (void)testScrollToRow {
    [_bookShelfView scrollToRow:34 animate:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self switchToNormalMode];
    [self initBooks];
    
    _booksIndexsToBeRemoved = [NSMutableIndexSet indexSet];
        
    [self.bookShelfView setContentOffset:CGPointMake(0, 120)];
    
    CGRect f = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - kNavigationBarHeight - kTabBarHeight);// kToolbarHeight);
    self.bookShelfView = [[GSBookShelfView alloc] initWithFrame:f];
    self.bookShelfView.dataSource = self;
    
    [self.view addSubview:self.bookShelfView];
//    self.navigationController.toolbarHidden = YES;
//    [self performSelector:@selector(testScrollToRow) withObject:self afterDelay:3];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.bookShelfView reloadData];
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

- (void)initBooks
{
    // 本の初期化
//    _bookArray = [NSMutableArray arrayWithArray:self.fetchedResultsController.fetchedObjects];
    self.bookArray = self.fetchedResultsController.fetchedObjects;
    self.bookStatus = [NSMutableArray arrayWithCapacity:self.bookArray.count];
    for (int i = 0 , max = [self.bookArray count]; i < max; i++) {
        [self.bookStatus addObject:@(BOOK_UNSELECTED)];
    }
}


- (void)switchToNormalMode {
    $(@"Switch to normal mode");
    _editMode = NO;
    for (int i = 0; i < [self.bookArray count]; i++) {
        [self.bookStatus addObject:@(BOOK_UNSELECTED)];
    }
    for (SFShelfBookView *bookView in [_bookShelfView visibleBookViews]) {
        [bookView setSelected:NO];
    }
}

- (void)switchToEditMode {
    $(@"Switch to edit mode");
    _editMode = YES;
    [_booksIndexsToBeRemoved removeAllIndexes];
//    for (int i = 0; i < [_bookArray count]; i++) {
//        [_bookStatus addObject:@(BOOK_UNSELECTED)];
//    }
//    
//    for (SFShelfBookView *bookView in [_bookShelfView visibleBookViews]) {
//        [bookView setSelected:NO];
//    }
}

#pragma mark GSBookShelfViewDataSource

- (NSInteger)numberOfBooksInBookShelfView:(GSBookShelfView *)bookShelfView {
    return [self.bookArray count];
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
    SFBook *book = [self.bookArray objectAtIndex:index];
    
    if (bookView == nil) {
        bookView = [[SFShelfBookView alloc] initWithFrame:CGRectZero];
        bookView.reuseIdentifier = identifier;
        [bookView addTarget:self action:@selector(bookViewClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    [bookView setIndex:index];
#warning 空配列への参照でエラーが出る
    [bookView setSelected:[(NSNumber *)[self.bookStatus objectAtIndex:index] intValue]];
    [bookView setBackgroundImage:[UIImage imageWithData:book.image] forState:UIControlStateNormal];
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
    
//    SFShelfRowView *srv = [[SFShelfRowView alloc] initWithFrame:CGRectMake(0, 0, 320, 120)];
//    return srv;
    
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
    
    if ([(NSNumber *)[self.bookStatus objectAtIndex:fromIndex] intValue] == BOOK_SELECTED) {
        [_booksIndexsToBeRemoved removeIndex:fromIndex];
        [_booksIndexsToBeRemoved addIndex:toIndex];
    }
    //TODO: 入れ替えの処理を入れるならここでCoreDataをいじる
//    [_bookArray moveObjectFromIndex:fromIndex toIndex:toIndex];
    [self.bookStatus moveObjectFromIndex:fromIndex toIndex:toIndex];
    
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

//- (void)editButtonClicked:(id)sender {
//    [self switchToEditMode];
//}
//
//- (void)cancleButtonClicked:(id)sender {
//    [self switchToNormalMode];
//}
//
//- (void)trashButtonClicked:(id)sender {
//    [_bookArray removeObjectsAtIndexes:_booksIndexsToBeRemoved];
//    [_bookStatus removeObjectsAtIndexes:_booksIndexsToBeRemoved];
//    [_bookShelfView removeBookViewsAtIndexs:_booksIndexsToBeRemoved animate:YES];
//    [self switchToNormalMode];
//}
//
//- (void)addButtonClicked:(id)sender {
//    int a[6] = {1, 2, 5, 7, 9, 22};
//    NSMutableIndexSet *indexSet = [NSMutableIndexSet indexSet];
//    NSMutableArray *arr = [NSMutableArray array];
//    NSMutableArray *stat = [NSMutableArray array];
//    for (int i = 0; i < 6; i++) {
//        [indexSet addIndex:a[i]];
//        [arr addObject:@1];
//        [stat addObject:@(BOOK_UNSELECTED)];
//    }
//    [_bookArray insertObjects:arr atIndexes:indexSet];
//    [_bookStatus insertObjects:stat atIndexes:indexSet];
//    [_bookShelfView insertBookViewsAtIndexs:indexSet animate:YES];
//}

#pragma mark - BookView Listener

- (void)bookViewClicked:(UIButton *)button {
    SFShelfBookView *bookView = (SFShelfBookView*)button;
    
    if (_editMode) {
        NSNumber *status = [NSNumber numberWithInt:bookView.selected];
        
        [self.bookStatus replaceObjectAtIndex:bookView.index withObject:status];
        
        if (bookView.selected) {
            [_booksIndexsToBeRemoved addIndex:bookView.index];
        }
        else {
            [_booksIndexsToBeRemoved removeIndex:bookView.index];
        }
        int nob = _booksIndexsToBeRemoved.count;
        NSString *deleteButtonTitle = [NSString stringWithFormat:@"Delete (%i)", nob];
        NSString *moveButtonTitle = [NSString stringWithFormat:@"Move (%i)", nob];
        NSString *staredButtonTitle = [NSString stringWithFormat:@"Stared (%i)", nob];
        
        if (_booksIndexsToBeRemoved.count == self.fetchedResultsController.fetchedObjects.count){
            deleteButtonTitle = @"Delete all";
            moveButtonTitle = @"Move all";
            staredButtonTitle = @"Stared all";
        }
        
        SFShelfViewController *svc = (SFShelfViewController*)self.parentViewController;
        svc.trashButton.title = deleteButtonTitle;
        svc.moveButton.title = moveButtonTitle;
        svc.staredButton.title = staredButtonTitle;
    } else {
        [bookView setSelected:NO];
        SFBook *book = [self.bookArray objectAtIndex:bookView.index];
        [self.parentViewController performSegueWithIdentifier:@"showBook" sender:book];
    }
}

#pragma mark - Accessor for Books data source

//- (void)insertBook:(SFBook *)book atIndex:(NSInteger)index
//{
//    [self.bookArray insertObject:book atIndex:index];
//    [self.bookShelfView reloadData];
//}
//
//- (void)removeBookAtIndex:(NSInteger)index
//{
//    [self.bookArray removeObjectAtIndex:index];
//    [self.bookShelfView reloadData];
//}

#pragma mark - Setter / Getter

//-(void)setBookArray:(NSMutableArray *)bookArray
//{
//    if (bookArray != _bookArray) {
//        _bookArray = bookArray;
//    }    
////    [self.bookShelfView reloadData];
//}

@end
