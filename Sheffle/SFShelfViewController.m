//
//  SFShelfViewController.m
//  Sheffle
//
//  Created by 桜井 雄介 on 12/07/22.
//  Copyright (c) 2012年 Kaeru Lab. All rights reserved.
//

#import "SFShelfViewController.h"
#import "SFAppDelegate.h"
#import "UIViewController+AddBook.h"
#import "SFPopoverViewController.h"

#define kDefaultShelfViewFrame CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)
#define kDefaultReaderViewFrame CGRectMake(0, 0, self.view.frame.size.width, 0)
#define kScanModeShelfViewFrame CGRectMake(0, 100.0f, self.view.frame.size.width, self.view.frame.size.height - 100.0f)
#define kScanModeReaderViewFrame CGRectMake(0, 0, self.view.frame.size.width, 100.0f)

@interface SFShelfViewController ()
{
    UIBarButtonItem *_shelvesButton;
    UIBarButtonItem *_editButton;
    UIBarButtonItem *_donebutton;
    UIBarButtonItem *_addButton;
    UISegmentedControl *_displayControl;
    UIBarButtonItem *_displayControlItem;
    UISegmentedControl *_sortControl;
    UIBarButtonItem *_sortControlItem;
    SFShelf *_currentShelf;
    ZBarReaderView *_readerView;
    NSString *_previousBarcode;
    NSInteger _currentSortIndex;
    SFPopoverViewController *_popoverController;
    BOOL _popoverIsVisible;
}

@property (strong,nonatomic) NSArray *rightBarItems;
@property (strong,nonatomic) NSArray *normalToolbarItems;
@property (strong,nonatomic) NSArray *editToolbarItems;

/* Action Handlers */
- (void)shelvesButtonDidTap:(id)sender;
- (void)editButtonDidTap:(id)sender;
- (void)doneButtonDidTap:(id)sender;
- (void)addButtonDidTap:(id)sender;
- (void)sortControlDidChange:(UISegmentedControl*)sender;
- (void)displayControlDidChange:(UISegmentedControl*)sender;
- (void)trashButtonDidTap:(id)sender;
- (void)moveButtonDidTap:(id)sender;
- (void)staredButtonDidTap:(id)sender;
// Private Methods
- (void)insertNewObject:(NSDictionary*)book image:(UIImage*)image;
- (NSSet*)booksToBeHandled;
- (UIImage*)resizeImage:(UIImage*)image;
// Method for DEBUG
- (NSDictionary*)getFixture;

@end

@implementation SFShelfViewController

@synthesize shelfViewMode = _shelfViewMode, fetchedResultsController = _fetchedResultsController;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // ボタンを初期化
    [self initButtons];
    
    // NavigationBarを初期化
    self.navigationItem.titleView = _displayControl;
    self.navigationItem.leftBarButtonItem = _shelvesButton;
    self.navigationItem.rightBarButtonItems = self.rightBarItems;

    // Toolbarを初期化    
    self.toolbarItems = self.normalToolbarItems;
    
    // Viewの初期化
    
    // Reader Viewの初期化
    ZBarImageScanner *scanner = [[ZBarImageScanner alloc] init];
    [scanner setSymbology: ZBAR_I25 config: ZBAR_CFG_ENABLE to: 0];
    _readerView = [[ZBarReaderView alloc] initWithImageScanner:scanner];
    _readerView.frame = kDefaultReaderViewFrame;
    _readerView.readerDelegate = self;
    [self.view addSubview:_readerView];
    
    // Shelf Viewの初期化
    CGFloat nh = self.navigationController.navigationBar.frame.size.height;
    CGFloat th = self.tabBarController.tabBar.frame.size.height;
    self.shelfView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - nh - th)];
    [self.view addSubview:self.shelfView];
    
    // ２種類のShelfViewControllerを構築

    self.tableShelfViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"TableShlefView"];
    self.gridShelfViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"GridShelfView"];
    
    self.tableShelfViewController.fetchedResultsController = self.fetchedResultsController;
    self.gridShelfViewController.fetchedResultsController = self.fetchedResultsController;   
    
    CGRect f;
    f.origin = CGPointMake(0, 0);
    f.size.width = CGRectGetWidth(self.view.bounds);
    f.size.height = CGRectGetHeight(self.view.bounds) - CGRectGetHeight(self.navigationController.toolbar.bounds) - CGRectGetHeight(self.navigationController.navigationBar.bounds);
    self.tableShelfViewController.view.frame = f;
    self.gridShelfViewController.view.frame = f;
    
    [self addChildViewController:_tableShelfViewController];
    [self addChildViewController:_gridShelfViewController];
    [self.tableShelfViewController didMoveToParentViewController:self];
    [self.gridShelfViewController didMoveToParentViewController:self];
    
    [self.shelfView addSubview:self.tableShelfViewController.view];
    [self.shelfView addSubview:self.gridShelfViewController.view];

    _shelfViewMode = SFShelfViewModeGrid;
//    _shelfViewMode = SFShelfViewModeTable;
    
    // PullToRefreshの追加

}

- (void)viewDidUnload
{
    [self setReaderView:nil];
    [self setShelfView:nil];
    _readerView = nil;
    _editButton = nil;
    _donebutton = nil;
    _sortControl = nil;
    _sortControlItem = nil;
    _displayControl = nil;
    _displayControlItem = nil;
    _addButton = nil;
    _trashButton = nil;
    _moveButton = nil;
    _staredButton = nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (void)setEditing:(BOOL)editing
{
    [super setEditing:editing];
    if (!editing) {
        // done
        [self.navigationItem setRightBarButtonItems:[self rightBarItems] animated:YES];
        [self setToolbarItems:[self normalToolbarItems] animated:YES];
        [self.tableShelfViewController setEditing:editing animated:YES];
        [self.gridShelfViewController switchToNormalMode];
    }else{
        // edit
        [self.navigationItem setRightBarButtonItem:_donebutton animated:YES];
        [self setToolbarItems:[self editToolbarItems] animated:YES];
        [self.tableShelfViewController setEditing:editing animated:YES];
        [self.gridShelfViewController switchToEditMode];
    }
}

#pragma mark - Private

- (void)insertNewObject:(NSDictionary *)book image:(UIImage *)image
{
    SFBook *newBook = [[SFCoreDataManager sharedManager] insertNewBook];
    
    if ([newBook identifier]) {   
        // 楽天の情報をセット
        [newBook setDataWithJSON:book];
        KXPDownload *d = [[KXPDownload alloc] initWithContentsOfURL:[NSURL URLWithString:newBook.largeImageUrl] withOptions:nil];
        d.completionHandler = ^(NSData*d,id opts){
            if (d) {
                [newBook setImage:d];
                [[SFCoreDataManager sharedManager] saveContext];
            }
        };
        [d startDownload];
        [self.shelf addBooks:[NSSet setWithObject:newBook]];        
    }    
    [[SFCoreDataManager sharedManager] saveContext];
}

- (UIImage *)resizeImage:(UIImage *)image
{
    // サムネイル用の処理
    CGSize resized = CGSizeMake(image.size.width/2, image.size.height);
    UIGraphicsBeginImageContextWithOptions(resized, NO, 0.0);
    CGRect itemRect = CGRectMake(0.0, 0.0, resized.width, resized.height);
    [image drawInRect:itemRect];
    UIImage *resizedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return resizedImage;
}

#pragma mark - Segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    static NSString *segueIDForBook = @"showBook";
    static NSString *segueIDForList = @"showShlefList";
    
    if ([[segue identifier] isEqualToString:segueIDForBook]) {
        SFBookViewController *bvc = (SFBookViewController*)[segue destinationViewController];
        SFBook *book = nil;
        if ([sender isKindOfClass:[SFBook class]]) {
            book = (SFBook*)sender;
        }
        bvc.book = book;
    }
//    else if ([segue.identifier isEqualToString:segueIDForList]) {
//        SFShelfListViewController *slvc = (SFShelfListViewController*)segue.destinationViewController;
//        slvc.shelves = [[SFCoreDataManager sharedManager] shelves];
//        slvc.currentShelf = self.shelf;
//        NSSet *booksToBeMoved;
//        switch (self.shelfViewMode) {
//            case SFShelfViewModeGrid: {
//                NSIndexSet *is = self.gridShelfViewController.booksIndexsToBeRemoved;
//                booksToBeMoved = [NSSet setWithArray:[self.fetchedResultsController.fetchedObjects objectsAtIndexes:is]];
//
//            }
//                break;
//            case SFShelfViewModeTable:{
//                NSArray *ips = [self.tableShelfViewController.tableView indexPathsForSelectedRows];
//                NSMutableArray *ma = [NSMutableArray arrayWithCapacity:ips.count];
//                for (int i = 0; i < ips.count; i++) {
//                    [ma addObject:[self.fetchedResultsController.fetchedObjects objectAtIndex:[ips objectAtIndex:i]]];
//                }
//            }
//                break;
//            default:
//                break;
//        }
//        slvc.booksToBeMoved = booksToBeMoved;
//    }
}


#pragma mark - ZBarReaderView

- (void)readerView:(ZBarReaderView *)readerView didReadSymbols:(ZBarSymbolSet *)symbols fromImage:(UIImage *)image
{

    [_readerView stop];
    
    for(ZBarSymbol *symbol in symbols) {
        
        NSString *resultText = [symbol data];
        
        // 同じ商品を連続で認識しても登録しない
        if ([resultText isEqualToString:_previousBarcode]) {
            [SVProgressHUD showErrorWithStatus:@"Same Product" duration:1.5f];
            return;
        }
        
        // 楽天ブックス総合検索APIのURL
        
        NSMutableString *apiURIString = [NSMutableString stringWithString:@"http://api.rakuten.co.jp/rws/3.0/json?"];
        [apiURIString appendFormat:@"developerId=%@&",kRakutenAPPID];
        //　2012/07/30 総合検索から書籍検索へ切り替えた
        [apiURIString appendString:@"operation=BooksBookSearch&"];
        [apiURIString appendString:@"version=2011-12-01&"];
        [apiURIString appendFormat:@"isbn=%@",resultText];
        
        // HTTPRequestを構築
        R9HTTPRequest *req = [[R9HTTPRequest alloc] initWithURL:[NSURL URLWithString:[apiURIString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
        
        // ぐるぐるを表示
        [SVProgressHUD showWithStatus:@"Loading"];
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        [[self view] setUserInteractionEnabled:NO];
        for (UIBarButtonItem*b in self.navigationItem.rightBarButtonItems) {
            [b setEnabled:NO];
        }
        
        // 成功時および失敗時のハンドラをセット
        [req setCompletionHandler:^(NSHTTPURLResponse *responseHeader, NSString *responseString){
            //        $(@"Reponse is : %@",responseHeader);
            //        $(@"body is %@",responseString);
            NSDictionary *JSON = [responseString JSONValue];
            if ([JSON objectForKey:@"Body"] != nil && [JSON objectForKey:@"Body"] != [NSNull null]) {
                // 成功時
                JSON = [[[[[JSON objectForKey:@"Body"] objectForKey:@"BooksBookSearch"] objectForKey:@"Items"] objectForKey:@"Item"] objectAtIndex:0];
                NSString *productURL = [JSON objectForKey:@"largeImageUrl"];
                NSError *error = nil;
                NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:productURL] options:NSDataReadingUncached error: &error];
                UIImage *cover = [UIImage imageWithData:data];
                if (error) {
                    $(@"Error : %@", error);
                }
                [self insertNewObject:JSON image:cover];
                [SVProgressHUD dismissWithSuccess:[JSON objectForKey:@"title"] afterDelay:1.5f];
            }else{
                // 失敗時
                $(@"data might not be found");
                [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
                [SVProgressHUD dismissWithError:@"Product not found" afterDelay:2.0f];
            }
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
            [[self view] setUserInteractionEnabled:YES];
            for (UIBarButtonItem*b in self.navigationItem.rightBarButtonItems) {
                [b setEnabled:YES];
            }
            [_readerView start];
        }];
        [req setFailedHandler:^(NSError *error){
            [SVProgressHUD dismissWithError:@"Error happed" afterDelay:2.0f];
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
            $(@"error happend : %@",error);
            [_readerView start];
        }];
        
        // リクエストをスタート
        [req startRequest];
        
        // 登録
        _previousBarcode = resultText;
    }
}

#pragma mark - Shelves View Delegate

- (void)shelvesViewController:(SFShelvesViewController *)controller didSelectShelf:(SFShelf *)shelf
{
    if (shelf) {
        self.shelf = shelf;
        NSSortDescriptor *title = [[NSSortDescriptor alloc] initWithKey:@"titleKana" ascending:YES];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"shelf == %@",self.shelf];        
        self.fetchedResultsController = [[SFCoreDataManager sharedManager] fetchedResultsControllerWithEntityName:@"Book" sortDescriptors:@[title] sectionNameKeyPath:@"titleInitial" cacheName:[NSString stringWithFormat:@"BooksOf%@",shelf.title] predicate:predicate];
        [_popoverController dismisWithAnimated:YES];
        _popoverIsVisible = NO;
    }
}

#pragma mark - Action Handlers

- (void)shelvesButtonDidTap:(id)sender
{
    if (_popoverIsVisible) {
        [_popoverController dismisWithAnimated:YES];
        _popoverIsVisible = NO;
    }else{
        if (!_popoverController) {
            SFShelvesViewController *sv = [self.storyboard instantiateViewControllerWithIdentifier:@"ShelvesView"];
            sv.delegate = self;
            _popoverController = [[SFPopoverViewController alloc] initWithViewContentViewController:sv];
        }
        [_popoverController showInView:self.view animated:YES];
        _popoverIsVisible = YES;
    }
}

- (void)editButtonDidTap:(id)sender
{
    self.editing = YES;
}

- (void)doneButtonDidTap:(id)sender
{
    if (self.isEditing) {
        self.editing = NO;
    }else{
        _previousBarcode = nil;
        [_readerView stop];
        [UIView animateWithDuration:0.25f delay:0.0 options:(UIViewAnimationCurveEaseIn <<  16) animations:^(void){
            _readerView.frame = kDefaultReaderViewFrame;
            _shelfView.frame = kDefaultShelfViewFrame;
        }completion:^(BOOL finished){
            [self.navigationItem setRightBarButtonItems:self.rightBarItems animated:YES];
            [self setTitle:@"Shelf"];
        }];
    }
}

- (void)addButtonDidTap:(id)sender {
    $(@"add button did tap");
    [self startAddBookMode];
//    [_readerView start];
//    switch (_shelfViewMode) {
//        case SFShelfViewModeTable:
//            [[_tableShelfViewController tableView] setContentOffset:CGPointZero];
//            break;
//        case SFShelfViewModeGrid:
//            [[_gridShelfViewController bookShelfView] setContentOffset:CGPointZero];
//        default:
//            break;
//    }
//    [UIView animateWithDuration:0.25f delay:0.0 options:(UIViewAnimationCurveEaseIn <<  16) animations:^(void){
//        _readerView.frame = kScanModeReaderViewFrame;
//        _shelfView.frame = kScanModeShelfViewFrame;
//    }completion:^(BOOL finished){
//        [self.navigationItem setRightBarButtonItem:_donebutton];
//        [self setTitle:@"Scan Barcode"];
//    }];
}

- (void)sortControlDidChange:(UISegmentedControl *)sender
{
    $(@"%i",[_sortControl selectedSegmentIndex]);
    if (sender.selectedSegmentIndex != _currentSortIndex) {
        
        NSSortDescriptor *title = [[NSSortDescriptor alloc] initWithKey:@"titleKana" ascending:YES];
        NSSortDescriptor *author = [[NSSortDescriptor alloc] initWithKey:@"author" ascending:YES];
        NSSortDescriptor *publisher = [[NSSortDescriptor alloc] initWithKey:@"publisherName" ascending:YES];
        
        switch (sender.selectedSegmentIndex) {
            case 0: {
                _fetchedResultsController = [[SFCoreDataManager sharedManager] fetchedResultsControllerWithEntityName:@"Book" sortDescriptors:@[title,author,publisher] sectionNameKeyPath:@"titleInitial" cacheName:@"BookWithTitle" predicate:nil];
                self.sortType = SFBookSortTypeTitle;
            }
                break;
            case 1: {
                _fetchedResultsController = [[SFCoreDataManager sharedManager] fetchedResultsControllerWithEntityName:@"Book" sortDescriptors:@[author,title,publisher] sectionNameKeyPath:@"author" cacheName:@"BookWithAuthor" predicate:nil];
                self.sortType = SFBookSortTypeAuthor;
            }
                break;
            case 2: {
                _fetchedResultsController = [[SFCoreDataManager sharedManager] fetchedResultsControllerWithEntityName:@"Book" sortDescriptors:@[publisher,title,author] sectionNameKeyPath:@"publisherName" cacheName:@"BookWithPublisher" predicate:nil];
                self.sortType = SFBookSortTypePublisher;
            }
                break;
            default:
                break;
        }
        [self.gridShelfViewController.bookShelfView reloadData];
        [self.tableShelfViewController.tableView reloadData];
        _currentSortIndex = sender.selectedSegmentIndex;
    }
}

- (void)displayControlDidChange:(UISegmentedControl *)sender
{
    $(@"display change");
    switch (sender.selectedSegmentIndex) {
        case 0: {
            // Gridへ
            [self transitionFromViewController:self.tableShelfViewController toViewController:self.gridShelfViewController duration:0.0 options:UIViewAnimationOptionTransitionNone animations:nil completion:nil];
            _shelfViewMode = SFShelfViewModeGrid;
            [self.gridShelfViewController.bookShelfView reloadData];
        }
            break;
        case 1: {
            // Tableへ
            [self transitionFromViewController:self.gridShelfViewController toViewController:self.tableShelfViewController duration:0.0 options:UIViewAnimationOptionTransitionNone animations:nil completion:nil];
            _shelfViewMode = SFShelfViewModeTable;
            [self.tableShelfViewController.tableView reloadData];
        }
            break;
        default:
            break;
    }
}

#pragma mark - Toolbar Action Handler (in edit mode)

- (NSSet*)booksToBeHandled
{
    if (self.gridShelfViewController.booksIndexsToBeRemoved.count > 0 ||
        self.tableShelfViewController.tableView.indexPathForSelectedRow.length > 0) {
        switch (self.shelfViewMode) {
            case SFShelfViewModeGrid: {
                NSIndexSet *is = self.gridShelfViewController.booksIndexsToBeRemoved;
                NSArray *books = [self.fetchedResultsController.fetchedObjects objectsAtIndexes:is];
                NSSet *set = [NSSet setWithArray:books];
                return set;
            }
                break;
            case SFShelfViewModeTable: {
                NSArray *selected = [self.tableShelfViewController.tableView indexPathsForSelectedRows];
                NSMutableArray *toBeHandled = [NSMutableArray array];
                for (NSIndexPath *ip in selected) {
                    [toBeHandled addObject:[self.fetchedResultsController objectAtIndexPath:ip]];
                }
                NSSet *set = [NSSet setWithArray:toBeHandled];
                return set;
            }
                break;
            default:
                break;
        }
    }
    return nil;
}

- (void)trashButtonDidTap:(id)sender
{
    $(@"trash");
    if (self.gridShelfViewController.booksIndexsToBeRemoved.count > 0 ||
        self.tableShelfViewController.tableView.indexPathForSelectedRow.length > 0) {
        switch (self.shelfViewMode) {
            case SFShelfViewModeGrid: {
                NSIndexSet *is = self.gridShelfViewController.booksIndexsToBeRemoved;
                [self.gridShelfViewController.bookStatus removeObjectsAtIndexes:is];
                NSArray *books = [self.fetchedResultsController.fetchedObjects objectsAtIndexes:is];
                NSSet *set = [NSSet setWithArray:books];
                [self.shelf removeBooks:set];
                [[SFCoreDataManager sharedManager] saveContext];
            }
                break;
            case SFShelfViewModeTable: {
                NSArray *selected = [self.tableShelfViewController.tableView indexPathsForSelectedRows];
                NSMutableArray *toBeDeleted = [NSMutableArray array];
                for (NSIndexPath *ip in selected) {
                    [toBeDeleted addObject:[self.fetchedResultsController objectAtIndexPath:ip]];
                }
                NSSet *set = [NSSet setWithArray:toBeDeleted];
                [self.shelf removeBooks:set];
                [[SFCoreDataManager sharedManager] saveContext];
            }
                break;
            default:
                break;
        }
        [self.gridShelfViewController initBooks];
        [self editButtonDidTap:nil];
    }
}

- (void)moveButtonDidTap:(id)sender
{
    $(@"move");
    if (self.gridShelfViewController.booksIndexsToBeRemoved.count > 0 ||
        self.tableShelfViewController.tableView.indexPathForSelectedRow.length > 0) {
        switch (self.shelfViewMode) {
            case SFShelfViewModeGrid: {
                NSIndexSet *is = self.gridShelfViewController.booksIndexsToBeRemoved;
                [self.gridShelfViewController.bookStatus removeObjectsAtIndexes:is];
                NSArray *books = [self.fetchedResultsController.fetchedObjects objectsAtIndexes:is];
                NSSet *set = [NSSet setWithArray:books];
                [self.shelf removeBooks:set];
                [[SFCoreDataManager sharedManager] saveContext];
            }
                break;
            case SFShelfViewModeTable: {
                NSArray *selected = [self.tableShelfViewController.tableView indexPathsForSelectedRows];
                NSMutableArray *toBeDeleted = [NSMutableArray array];
                for (NSIndexPath *ip in selected) {
                    [toBeDeleted addObject:[self.fetchedResultsController objectAtIndexPath:ip]];
                }
                NSSet *set = [NSSet setWithArray:toBeDeleted];
                [self.shelf removeBooks:set];
                [[SFCoreDataManager sharedManager] saveContext];
            }
                break;
            default:
                break;
        }
        [self.gridShelfViewController initBooks];
        [self editButtonDidTap:nil];
        [self performSegueWithIdentifier:@"showShelfList" sender:self];
    }
}

- (void)staredButtonDidTap:(id)sender
{
    $(@"star");;
}

#pragma mark - Toolbar Items

- (void)initButtons
{
    // 本棚
    _shelvesButton = [[UIBarButtonItem alloc] initWithTitle:@"Shelves" style:UIBarButtonItemStyleBordered target:self action:@selector(shelvesButtonDidTap:)];
    
    // 編集
    _editButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(editButtonDidTap:)];
    _editButton.tintColor = kBarTintColor;
    
    // 追加
    _addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addButtonDidTap:)];
    _addButton.style = UIBarButtonItemStyleBordered;
    _addButton.tintColor = kBarTintColor;
    
    // 完了
    _donebutton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneButtonDidTap:)];
    
    // 消去
    _trashButton = [[UIBarButtonItem alloc] initWithTitle:@"Delete" style:UIBarButtonItemStyleBordered target:self action:@selector(trashButtonDidTap:)];
    _trashButton.tintColor = [UIColor redColor];
    
    // 移動
    _moveButton = [[UIBarButtonItem alloc] initWithTitle:@"Move" style:UIBarButtonItemStyleBordered target:self action:@selector(moveButtonDidTap:)];
    _moveButton.tintColor = kBarTintColor;
    
    // ふぁぼ
    _staredButton = [[UIBarButtonItem alloc] initWithTitle:@"Favorite" style:UIBarButtonItemStyleBordered target:self action:@selector(staredButtonDidTap:)];
    _staredButton.tintColor = kBarTintColor;
    
    CGFloat w = 96;
    
    _trashButton.width = _moveButton.width = _staredButton.width = w;
    
    
    // 切り替え
    _displayControl = [[UISegmentedControl alloc] initWithItems:@[@"Grid",@"Table"]];
    _displayControl.selectedSegmentIndex = 0;
    _displayControl.segmentedControlStyle = UISegmentedControlStyleBar;
    CGRect f = _displayControl.frame;
    f.size.width = 150;
    _displayControl.frame = f;
    [_displayControl addTarget:self action:@selector(displayControlDidChange:) forControlEvents:UIControlEventValueChanged];
    _displayControlItem = [[UIBarButtonItem alloc] initWithCustomView:_displayControl];
    
    // ソート
    _sortControl = [[UISegmentedControl alloc] initWithItems:@[@"Title",@"Author",@"Date"]];
    _sortControl.selectedSegmentIndex = 0;
    _sortControl.segmentedControlStyle = UISegmentedControlStyleBar;
    [_sortControl addTarget:self action:@selector(sortControlDidChange:) forControlEvents:UIControlEventValueChanged];
    _sortControlItem = [[UIBarButtonItem alloc] initWithCustomView:_sortControl];
    _sortControlItem.width = 265;
}

- (NSArray *)rightBarItems
{
    if (!_rightBarItems) {
//        _rightBarItems = @[_addButton,_editButton];
        _rightBarItems = @[_editButton];
    }
    return _rightBarItems;
}

- (NSArray *)editToolbarItems
{
    if (!_editToolbarItems) {
        UIBarButtonItem *sp1 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
        _editToolbarItems = @[_trashButton,sp1, _moveButton,sp1, _staredButton];
    }
    return _editToolbarItems;
}

- (NSArray *)normalToolbarItems
{
    if (!_normalToolbarItems) {
        UIBarButtonItem *spacor = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
        _normalToolbarItems = @[_sortControlItem,spacor,_addButton];
    }
    return _normalToolbarItems;
}

#pragma mark - Fetched Results Controller Delegate

- (void)setFetchedResultsController:(NSFetchedResultsController *)fetchedResultsController
{
    if (_fetchedResultsController != fetchedResultsController) {
        _fetchedResultsController = fetchedResultsController;
        self.gridShelfViewController.fetchedResultsController = fetchedResultsController;
        self.tableShelfViewController.fetchedResultsController = fetchedResultsController;
        [self.gridShelfViewController initBooks];
        [self.gridShelfViewController.bookShelfView reloadData];
        [self.tableShelfViewController.tableView reloadData];
    }
}

- (NSFetchedResultsController *)fetchedResultsController
{
    if (_fetchedResultsController) {
        return _fetchedResultsController;
    }
        
    _fetchedResultsController = [[SFCoreDataManager sharedManager] fetchedBooksController];
    _fetchedResultsController.delegate = self;
    return _fetchedResultsController;
}

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableShelfViewController.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{    
    switch(type) {
        case NSFetchedResultsChangeInsert: {
            // TableShelfViewを更新
            [self.tableShelfViewController.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
        }
            break;
        case NSFetchedResultsChangeDelete:
            [self.tableShelfViewController.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{    
    switch(type) {
        case NSFetchedResultsChangeInsert: {
            // Table Shelf View
            [self.tableShelfViewController.tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            // Grid Shelf View
            NSInteger i = [self.fetchedResultsController.fetchedObjects indexOfObject:anObject];            
            NSIndexSet *is = [NSIndexSet indexSetWithIndex:i];
            [self.gridShelfViewController.bookShelfView insertBookViewsAtIndexs:is animate:YES];
            [self.gridShelfViewController initBooks];
        }
            break;
        case NSFetchedResultsChangeDelete: {
            // Table Shelf View
            [self.tableShelfViewController.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            // Grid Shelf View
            NSUInteger i = [self.gridShelfViewController.bookArray indexOfObject:anObject];
            NSIndexSet *is = [NSIndexSet indexSetWithIndex:i];
            [self.gridShelfViewController.bookShelfView removeBookViewsAtIndexs:is animate:YES];
        }
            break;
        case NSFetchedResultsChangeUpdate:
            [self.tableShelfViewController.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
        case NSFetchedResultsChangeMove:
            [self.tableShelfViewController.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [self.tableShelfViewController.tableView insertRowsAtIndexPaths:@[newIndexPath]withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableShelfViewController.tableView endUpdates];
}

@end
