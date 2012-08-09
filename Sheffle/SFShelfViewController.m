//
//  SFShelfViewController.m
//  Sheffle
//
//  Created by 桜井 雄介 on 12/07/22.
//  Copyright (c) 2012年 Kaeru Lab. All rights reserved.
//

#import "SFShelfViewController.h"

#define kRakutenAPPID @"1058212220451425377"
#define kDefaultShelfViewFrame CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)
#define kDefaultReaderViewFrame CGRectMake(0, 0, self.view.frame.size.width, 0)
#define kScanModeShelfViewFrame CGRectMake(0, 100.0f, self.view.frame.size.width, self.view.frame.size.height - 100.0f)
#define kScanModeReaderViewFrame CGRectMake(0, 0, self.view.frame.size.width, 100.0f)

@interface SFShelfViewController ()
{
    UIBarButtonItem *_shelvesButton;
    UIBarButtonItem *_editButton;
    UIBarButtonItem *_donebutton;
    UIBarButtonItem *_scanButton;
    UIBarButtonItem *_addButton;
    UISegmentedControl *_displayControl;
    UIBarButtonItem *_displayControlItem;
    UIBarButtonItem *_trashButton;
    UIBarButtonItem *_moveButton;
    UIBarButtonItem *_staredButton;
    UISegmentedControl *_sortControl;
    UIBarButtonItem *_sortControlItem;
    SFShelf *_currentShelf;
    ZBarReaderView *_readerView;
    id _contentsBeforeChange;
}

@property (strong,nonatomic) NSArray *rightBarItems;
@property (strong,nonatomic) NSArray *normalToolbarItems;
@property (strong,nonatomic) NSArray *editToolbarItems;

// Action Handlers
- (void)shelvesButtonDidTap:(id)sender;
- (void)editButtonDidTap:(id)sender;
- (void)scanButtonDidTap:(id)sender;
- (void)doneButtonDidTap:(id)sender;
- (void)addButtonDidTap:(id)sender;
- (void)sortControlDidChange:(UISegmentedControl*)sender;
- (void)displayControlDidChange:(UISegmentedControl*)sender;
- (void)trashButtonDidTap:(id)sender;
- (void)moveButtonDidTap:(id)sender;
- (void)staredButtonDidTap:(id)sender;
// Private Methods
- (void)insertNewObject:(NSDictionary*)book image:(UIImage*)image;
- (UIImage*)resizeImage:(UIImage*)image;

@end

@implementation SFShelfViewController

@synthesize shelfViewMode = _shelfViewMode;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // インスタンス変数の初期化
    
    _shelvesButton = [[UIBarButtonItem alloc] initWithTitle:@"Shelves" style:UIBarButtonItemStyleBordered target:self action:@selector(shelvesButtonDidTap:)];
    // 編集
    _editButton = [[UIBarButtonItem alloc] initWithTitle:@"Edit" style:UIBarButtonItemStyleBordered target:self action:@selector(editButtonDidTap:)];
    // スキャン
    _scanButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCamera target:self action:@selector(scanButtonDidTap:)];
    // 完了
    _donebutton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneButtonDidTap:)];
    // ソート
    _sortControl = [[UISegmentedControl alloc] initWithItems:@[@"Title",@"Author",@"Date"]];
    _sortControl.selectedSegmentIndex = 0;
    _sortControl.segmentedControlStyle = UISegmentedControlStyleBar;
    [_sortControl addTarget:self action:@selector(sortControlDidChange:) forControlEvents:UIControlEventValueChanged];
    _sortControlItem = [[UIBarButtonItem alloc] initWithCustomView:_sortControl];
    
    // 切り替え
    _displayControl = [[UISegmentedControl alloc] initWithItems:@[@"Grid",@"Table"]];
    _displayControl.selectedSegmentIndex = 0;
    _displayControl.segmentedControlStyle = UISegmentedControlStyleBar;
    [_displayControl addTarget:self action:@selector(displayControlDidChange:) forControlEvents:UIControlEventValueChanged];
    _displayControlItem = [[UIBarButtonItem alloc] initWithCustomView:_displayControl];

    
    // 追加ボタン
    _addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addButtonDidTap:)];
    // 消去ボタン
    _trashButton = [[UIBarButtonItem alloc] initWithTitle:@"Delete" style:UIBarButtonItemStyleBordered target:self action:@selector(trashButtonDidTap:)];
    // 移動ボタン
    _moveButton = [[UIBarButtonItem alloc] initWithTitle:@"Move" style:UIBarButtonItemStyleBordered target:self action:@selector(moveButtonDidTap:)];
    // ふぁぼボタン
    _staredButton = [[UIBarButtonItem alloc] initWithTitle:@"Favorite" style:UIBarButtonItemStyleBordered target:self action:@selector(staredButtonDidTap:)];
    
    // NavigationBarを初期化
    
    self.title =  self.shelf.title;
    self.navigationItem.rightBarButtonItems = self.rightBarItems;

    // Toolbarを初期化
    
    self.toolbarItems = self.normalToolbarItems;
    
    // Viewの初期化
    CALayer *topShadowLayer = [CALayer layer];
    topShadowLayer.frame = self.view.bounds;
    [self.view.layer addSublayer:topShadowLayer];
    topShadowLayer.masksToBounds = YES;
    CGRect shadowFrame = CGRectMake(-10.0, -10.0, topShadowLayer.bounds.size.width+10.0, 10.0);
    UIBezierPath *path = [UIBezierPath bezierPathWithRect:shadowFrame];                          
    topShadowLayer.shadowOffset = CGSizeMake(0, 2.5); 
    topShadowLayer.shadowColor = [[UIColor blackColor] CGColor];
    topShadowLayer.shadowOpacity = 0.5;
    topShadowLayer.shadowPath = [path CGPath];
    
    CALayer *bottomShadowLayer = [CALayer layer];
//    [bottomShadowLayer setFrame:self.view.bounds];
    bottomShadowLayer.frame = self.navigationController.toolbar.frame;
//    [self.view.layer addSublayer:bottomShadowLayer];
    [self.navigationController.toolbar.layer addSublayer:bottomShadowLayer];
    [bottomShadowLayer setMasksToBounds:YES];
//    CGRect dpsFrame = CGRectMake(-10.0,10,0, bottomShadowLayer.bounds.size.width+10.0,10.0);
    CGRect dpsFrame = CGRectMake(-10.0, -10.0, self.view.frame.size.width + 10.0, 10.0);
    UIBezierPath *dpsPath = [UIBezierPath bezierPathWithRect:dpsFrame];
    [bottomShadowLayer setShadowOffset:CGSizeMake(0, 2.5)];
    [bottomShadowLayer setShadowColor:[[UIColor blackColor] CGColor]];
    [bottomShadowLayer setShadowOpacity:0.75];
    [bottomShadowLayer setShadowPath:[dpsPath CGPath]];
    
    // Reader Viewの初期化
    ZBarImageScanner *scanner = [[ZBarImageScanner alloc] init];
    [scanner setSymbology: ZBAR_I25 config: ZBAR_CFG_ENABLE to: 0];
    _readerView = [[ZBarReaderView alloc] initWithImageScanner:scanner];
    _readerView.frame = kDefaultReaderViewFrame;
    _readerView.readerDelegate = self;
    [self.view addSubview:_readerView];
    
    // Shelf Viewの初期化
    
    self.shelfView = [[UIView alloc] initWithFrame:kDefaultShelfViewFrame];
    [self.view addSubview:self.shelfView];
    
    // ２種類のShelfViewControllerを構築
    self.tableShelfViewController = [[SFTableShelfViewController alloc] initWithStyle:UITableViewStylePlain];
    self.gridShelfViewController = [[SFGridShelfViewController alloc] init];
    
    self.tableShelfViewController.fetchedResultsController = self.fetchedresultsController;
    self.gridShelfViewController.fetchedResultsController = self.fetchedresultsController;
    
    self.tableShelfViewController.view.frame = kDefaultShelfViewFrame;
    self.gridShelfViewController.view.frame = kDefaultShelfViewFrame;
    
    [self addChildViewController:_tableShelfViewController];
    [self addChildViewController:_gridShelfViewController];
    [self.tableShelfViewController didMoveToParentViewController:self];
    [self.gridShelfViewController didMoveToParentViewController:self];
    
    [self.shelfView addSubview:self.tableShelfViewController.view];
    [self.shelfView addSubview:self.gridShelfViewController.view];
    
//    _shelfView = self.tableShelfViewController.view;
//    _shelfView = [_gridShelfViewController view];
    
    _shelfViewMode = SFShelfViewModeTable;


}

- (void)viewDidUnload
{
    [self setReaderView:nil];
    [self setShelfView:nil];
    _readerView = nil;
    _editButton = nil;
    _scanButton = nil;
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

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)insertNewObject:(NSDictionary *)book image:(UIImage *)image
{
    SFBook *newBook = [[SFCoreDataManager sharedManager] insertNewBook];
    
    if ([newBook identifier]) {
        // 内部情報をセット
        [newBook setImage2x:UIImagePNGRepresentation(image)];
        [newBook setImage:UIImagePNGRepresentation([self resizeImage:image])];
        
        // 楽天の情報をセット
        [newBook setAuthor:[book objectForKey:@"author"]];
        [newBook setAuthorKana:[book objectForKey:@"authorKana"]];
        [newBook setTitle:[book objectForKey:@"title"]];
        [newBook setTitleKana:[book objectForKey:@"titleKana"]];
        [newBook setSeriesName:[book objectForKey:@"seriesName"]];
        [newBook setSeriesNameKana:[book objectForKey:@"seriesNameKana"]];
        [newBook setIsbn:[book objectForKey:@"isbn"]];
        [newBook setItemCaption:[book objectForKey:@"itemCaption"]];
        [newBook setItemPrice:[[book objectForKey:@"itemPrice"] intValue]];
        [newBook setItemUrl:[book objectForKey:@"itemUrl"]];
        
        NSDateFormatter *dfm = [[NSDateFormatter alloc] init];
        [dfm setDateFormat:@"yyyy年MM月"];
        [newBook setSalesDate:[dfm dateFromString:[book objectForKey:@"salesDate"]]];
        [newBook setBookSize:[book objectForKey:@"size"]];
        
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


#pragma mark - ZBarReaderView

- (void)readerView:(ZBarReaderView *)readerView didReadSymbols:(ZBarSymbolSet *)symbols fromImage:(UIImage *)image
{

    [_readerView stop];
    
    for(ZBarSymbol *symbol in symbols) {
        
        NSString *resultText = [symbol data];
        
        // 楽天ブックス総合検索APIのURL
        
        NSMutableString *apiURIString = [NSMutableString stringWithString:@"http://api.rakuten.co.jp/rws/3.0/json?"];
        [apiURIString appendFormat:@"developerId=%@&",kRakutenAPPID];
        //　2012/07/30 総合検索から書籍検索へ切り替えた
        [apiURIString appendString:@"operation=BooksBookSearch&"];
        [apiURIString appendString:@"version=2011-12-01&"];
        [apiURIString appendFormat:@"isbn=%@",resultText];
//        NSLog(@"url is %@",apiURIString);
        
        // HTTPRequestを構築
        R9HTTPRequest *req = [[R9HTTPRequest alloc] initWithURL:[NSURL URLWithString:[apiURIString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
        
        // ぐるぐるを表示
        [SVProgressHUD showWithStatus:@"Loading"];
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        [[self view] setUserInteractionEnabled:NO];
        
        // 成功時および失敗時のハンドラをセット
        [req setCompletionHandler:^(NSHTTPURLResponse *responseHeader, NSString *responseString){
            //        NSLog(@"Reponse is : %@",responseHeader);
            //        NSLog(@"body is %@",responseString);
            NSDictionary *JSON = @{};
            @try {
                JSON = [[[[[[responseString JSONValue] objectForKey:@"Body"] objectForKey:@"BooksBookSearch"] objectForKey:@"Items"] objectForKey:@"Item"] objectAtIndex:0];
                NSError *error = nil;
                NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:[JSON objectForKey:@"largeImageUrl"]] options:NSDataReadingUncached error: &error];
                UIImage *cover = [UIImage imageWithData:data];
                if (error) {
                    NSLog(@"Error : %@", error);
                }
                [self insertNewObject:JSON image:cover];
                [SVProgressHUD dismissWithSuccess:[JSON objectForKey:@"title"] afterDelay:1.5f];
            }
            @catch (NSException *exception) {
                NSLog(@"exception:%@",exception);
                NSLog(@"data not found : %@",responseString);
                [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
                [SVProgressHUD dismissWithError:@"Product not found" afterDelay:2.0f];
            }
            @finally {
                [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
                [[self view] setUserInteractionEnabled:YES];
                [_readerView start];
            }                      
        }];
        [req setFailedHandler:^(NSError *error){
            [SVProgressHUD dismissWithError:@"Error happed" afterDelay:2.0f];
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
            NSLog(@"error happend : %@",error);
            [_readerView start];
        }];
        
        // リクエストをスタート
        [req startRequest];
    }
}

#pragma mark - Action Handlers

- (void)shelvesButtonDidTap:(id)sender
{
    [self performSegueWithIdentifier:@"showShelves" sender:self];
}

- (void)editButtonDidTap:(id)sender
{
    switch (self.shelfViewMode) {
        case SFShelfViewModeTable: {
            if (self.tableShelfViewController.isEditing) {
                // 編集終了処理
                _editButton.style = UIBarButtonItemStyleBordered;
                _editButton.title = @"Edit";
                [self.navigationItem setRightBarButtonItems:self.rightBarItems animated:YES];
                [self setToolbarItems:[self normalToolbarItems] animated:YES];
                [self.tableShelfViewController setEditing:NO animated:YES];
            }else{
                // 編集開始処理
                _editButton.style = UIBarButtonItemStyleDone;
                _editButton.title = @"Done";
                [self.navigationItem setRightBarButtonItem:_editButton animated:YES];
                [self setToolbarItems:[self editToolbarItems] animated:YES];
                [self.tableShelfViewController setEditing:YES animated:YES];
            }
        }
            break;
        case SFShelfViewModeGrid: {
            if (self.gridShelfViewController.isEditing) {
                // 編集終了
                [self. gridShelfViewController switchToNormalMode];
                self.gridShelfViewController.editing = NO;
            }else{
                // 編集開始
                [self.gridShelfViewController switchToEditMode];
                self.gridShelfViewController.editing = YES;
            }
        }
            break;
        default:
            break;
    }
}

- (void)scanButtonDidTap:(id)sender 
{
    [_readerView start];
    switch (_shelfViewMode) {
        case SFShelfViewModeTable:
            [[_tableShelfViewController tableView] setContentOffset:CGPointZero];
            break;
        case SFShelfViewModeGrid:
            [[_gridShelfViewController bookShelfView] setContentOffset:CGPointZero];
        default:
            break;
    }
    [UIView animateWithDuration:0.25f delay:0.0 options:(UIViewAnimationCurveEaseIn <<  16) animations:^(void){
        _readerView.frame = kScanModeReaderViewFrame;
        _shelfView.frame = kScanModeShelfViewFrame;
    }completion:^(BOOL finished){
        [self.navigationItem setRightBarButtonItem:_donebutton];
        [self setTitle:@"Scan Barcode"];
    }];

}

- (void)doneButtonDidTap:(id)sender
{
    [_readerView stop];
    [UIView animateWithDuration:0.25f delay:0.0 options:(UIViewAnimationCurveEaseIn <<  16) animations:^(void){
        _readerView.frame = kDefaultReaderViewFrame;
        _shelfView.frame = kDefaultShelfViewFrame;
    }completion:^(BOOL finished){
        [self.navigationItem setRightBarButtonItem:_scanButton];
        [self setTitle:@"Shelf"];
    }];
}

- (void)addButtonDidTap:(id)sender {
    NSLog(@"add button did tap");
    [_readerView start];
    switch (_shelfViewMode) {
        case SFShelfViewModeTable:
            [[_tableShelfViewController tableView] setContentOffset:CGPointZero];
            break;
        case SFShelfViewModeGrid:
            [[_gridShelfViewController bookShelfView] setContentOffset:CGPointZero];
        default:
            break;
    }
    [UIView animateWithDuration:0.25f delay:0.0 options:(UIViewAnimationCurveEaseIn <<  16) animations:^(void){
        _readerView.frame = kScanModeReaderViewFrame;
        _shelfView.frame = kScanModeShelfViewFrame;
    }completion:^(BOOL finished){
        [self.navigationItem setRightBarButtonItem:_donebutton];
        [self setTitle:@"Scan Barcode"];
    }];
}

- (void)sortControlDidChange:(UISegmentedControl *)sender
{
    NSLog(@"segmented control did change index : %i",[_sortControl selectedSegmentIndex]);
    switch (sender.selectedSegmentIndex) {
        case 0:
            // タイトル
            break;
        case 1:
            // 作者
            break;
        case 2:
            // 日付
            break;
        case 3:
            // 種類
            break;
        default:
            break;
    }
}

- (void)displayControlDidChange:(UISegmentedControl *)sender
{
    NSLog(@"display change");
    switch (sender.selectedSegmentIndex) {
        case 0: {
            // Gridへ
            [self transitionFromViewController:self.tableShelfViewController toViewController:self.gridShelfViewController duration:1.0 options:UIViewAnimationOptionTransitionFlipFromRight animations:nil completion:nil];
            _shelfViewMode = SFShelfViewModeGrid;
        }
            break;
        case 1: {
            // Tableへ
            [self transitionFromViewController:self.gridShelfViewController toViewController:self.tableShelfViewController duration:1.0 options:UIViewAnimationOptionTransitionFlipFromRight animations:nil completion:nil];
            _shelfViewMode = SFShelfViewModeTable;
        }
            break;
        default:
            break;
    }
}

- (void)trashButtonDidTap:(id)sender
{
    NSLog(@"trash");
}

- (void)moveButtonDidTap:(id)sender
{
    NSLog(@"move");
}

- (void)staredButtonDidTap:(id)sender
{
    NSLog(@"star");;
}

#pragma mark - Toolbar Items

- (NSArray *)rightBarItems
{
    if (!_rightBarItems) {
        _rightBarItems = @[_scanButton, _editButton ];
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
        _normalToolbarItems = @[_sortControlItem,spacor,_displayControlItem];
    }
    return _normalToolbarItems;
}

#pragma mark - Fetched Results Controller Delegate

- (NSFetchedResultsController *)fetchedresultsController
{
    if (_fetchedresultsController) {
        return _fetchedresultsController;
    }
    NSManagedObjectContext *context = [[SFCoreDataManager sharedManager] managedObjectContext];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];

    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Book" inManagedObjectContext:context];
    
    request.entity = entity;
    
    NSSortDescriptor *title = [[NSSortDescriptor alloc] initWithKey:@"titleKana" ascending:NO];
    NSSortDescriptor *author = [[NSSortDescriptor alloc] initWithKey:@"authorKana" ascending:NO];
    NSSortDescriptor *created = [[NSSortDescriptor alloc] initWithKey:@"created" ascending:NO];
    NSSortDescriptor *size = [[NSSortDescriptor alloc] initWithKey:@"bookSize" ascending:NO];
    
    request.sortDescriptors = @[ title, author, created, size ];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"shelf.identifier == %@",self.shelf.identifier];
    
    request.predicate = predicate;
    
    NSFetchedResultsController *controller = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:context sectionNameKeyPath:nil cacheName:@"Book"];
    controller.delegate = self;
    
    [NSFetchedResultsController deleteCacheWithName:@"Book"];
    
    NSError *error = nil;
    if (![controller performFetch:&error]) {
        NSLog(@"perform failed %@",error);
        return nil;
    }
    _fetchedresultsController = controller;
    return _fetchedresultsController;
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
            NSInteger i = [self.fetchedresultsController.fetchedObjects indexOfObject:anObject];            
            NSIndexSet *is = [NSIndexSet indexSetWithIndex:i];
            [self.gridShelfViewController.bookShelfView insertBookViewsAtIndexs:is animate:YES];
            self.gridShelfViewController.bookArray = [NSMutableArray arrayWithArray:self.fetchedresultsController.fetchedObjects];
        }
            break;
        case NSFetchedResultsChangeDelete: {
            // Table Shelf View
            [self.tableShelfViewController.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            // Grid Shelf View
            NSInteger i = [self.gridShelfViewController.bookArray indexOfObject:anObject];
            NSIndexSet *is = [NSIndexSet indexSetWithIndex:i];
            
            [self.gridShelfViewController.bookShelfView removeBookViewsAtIndexs:is animate:YES];
            self.gridShelfViewController.bookArray = [NSMutableArray arrayWithArray:self.fetchedresultsController.fetchedObjects];
        }
            break;
        case NSFetchedResultsChangeUpdate:
            [self.tableShelfViewController configureCell:[self.tableShelfViewController.tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
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
