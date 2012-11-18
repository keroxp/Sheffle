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

@end

@implementation SFGridShelfViewController

@synthesize fetchedResultsController = _fetchedResultsController;

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
    
    [self initBooks];
    [self switchToNormalMode];
    
    _booksIndexsToBeRemoved = [NSMutableIndexSet indexSet];
        
    [self.bookShelfView setContentOffset:CGPointMake(0, 120)];
    
    CGRect f = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - kNavigationBarHeight - kTabBarHeight);// kToolbarHeight);
    self.bookShelfView = [[GSBookShelfView alloc] initWithFrame:f];
    self.bookShelfView.dataSource = self;
    
    [self.view addSubview:self.bookShelfView];    
    
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
    self.bookStatus = [NSMutableArray arrayWithCapacity:self.fetchedResultsController.fetchedObjects.count];
    for (int i = 0 ; i < self.fetchedResultsController.fetchedObjects.count; i++) {
        [self.bookStatus addObject:@(BOOK_UNSELECTED)];
    }
    for (SFShelfBookView *bookView in [_bookShelfView visibleBookViews]) {
        [bookView setSelected:NO];
    }
}

- (void)switchToNormalMode {
    $(@"Switch to normal mode");
    _editMode = NO;
    [self initBooks];
}

- (void)switchToEditMode {
    $(@"Switch to edit mode");
    _editMode = YES;
    [_booksIndexsToBeRemoved removeAllIndexes];
    [self initBooks];
}

#pragma mark - Book View Configuration

- (void)insertBookViewsAtIndexPath:(NSIndexPath *)indexPath animated:(BOOL)animated
{
    SFBook *book = [self.fetchedResultsController objectAtIndexPath:indexPath];
    NSInteger index = [self.fetchedResultsController.fetchedObjects indexOfObject:book];
    [self.bookShelfView insertBookViewsAtIndexs:[NSIndexSet indexSetWithIndex:index] animate:animated];
}

- (void)removeBookViewsAtIndexPath:(NSIndexPath *)indexPath animated:(BOOL)animated
{
    SFBook *book = [self.fetchedResultsController objectAtIndexPath:indexPath];
    NSInteger index = [self.fetchedResultsController.fetchedObjects indexOfObject:book];
    [self.bookShelfView removeBookViewsAtIndexs:[NSIndexSet indexSetWithIndex:index] animate:animated];
}

#pragma mark GSBookShelfViewDataSource

- (NSInteger)numberOfBooksInBookShelfView:(GSBookShelfView *)bookShelfView {
    return [self.fetchedResultsController.fetchedObjects count];
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

    SFBook *book = nil;
    @try {
        book = [self.fetchedResultsController.fetchedObjects objectAtIndex:index];
    }
    @catch (NSException *exception) {        
        $(@"%@",exception);
    }
    @finally {
        
    }
    
    if (bookView == nil) {
        bookView = [[SFShelfBookView alloc] initWithFrame:CGRectZero];
        bookView.reuseIdentifier = identifier;
        [bookView addTarget:self action:@selector(bookViewClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    [bookView setIndex:index];
    
//        [bookView setSelected:[(NSNumber *)[self.bookStatus objectAtIndex:index] intValue]];
    
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
    
    UIDeviceOrientation orientation = [UIDevice currentDevice].orientation;
    if (UIDeviceOrientationIsLandscape(orientation)) {
        return nil;
    }
    else {
        return nil;
    }
    
    return nil;
}

- (CGFloat)cellHeightOfBookShelfView:(GSBookShelfView *)bookShelfView {
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
        SFBook *book = [self.fetchedResultsController.fetchedObjects objectAtIndex:bookView.index];
        [self.parentViewController performSegueWithIdentifier:@"showBook" sender:book];
    }
}

@end
