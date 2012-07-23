//
//  SFShelfViewController.m
//  Sheffle
//
//  Created by 桜井 雄介 on 12/07/22.
//  Copyright (c) 2012年 Kaeru Lab. All rights reserved.
//

#import "SFShelfViewController.h"
#define kRakutenAPPID @"1058212220451425377"
#define kBarTintColor [UIColor colorWithRed:214.0f/255.0f green:168.0f/255.0f blue:91.0f/255.0f alpha:1.0f]
#define kDefaultTableViewFrame CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - self.navigationController.toolbar.frame.size.height)
#define kDefaultReaderViewFrame CGRectMake(0, 0, self.view.frame.size.width, 0)
#define kScanModeTableViewFrame CGRectMake(0, 100.0f, self.view.frame.size.width, self.view.frame.size.height - self.navigationController.toolbar.frame.size.height - 100.0f)
#define kScanModeReaderViewFrame CGRectMake(0, 0, self.view.frame.size.width, 100.0f)

@interface SFShelfViewController ()
{
    UIBarButtonItem *_titleButton;
    UIBarButtonItem *_donebutton;
    UIBarButtonItem *_scanButton;
    UIBarButtonItem *_addButton;
    UIBarButtonItem *_segmentedControlItem;
    UISegmentedControl *_segmentedControl;
    ZBarReaderView *_readerView;
    NSManagedObjectContext *_currentManagedObjectContext;
    NSManagedObject *_currentManagedObject;
}

- (void)titleDidTap:(id)sender;
- (void)scanButtonDidTap:(id)sender;
- (void)doneButtonDidTap:(id)sender;
- (void)addButtonDidTap:(id)sender;
- (void)segmentedControlDidChange:(UISegmentedControl*)sender;
- (void)insertNewObject:(NSDictionary*)book;

@end

@implementation SFShelfViewController

@synthesize managedObjectContext = __managedObjectContext;
@synthesize readerWrapperView = _readerWrapperView;
@synthesize searchBar = _searchBar;
@synthesize tableView = _tableView;
@synthesize fetchedResultsController = __fetchedResultsController;

- (void)viewDidLoad
{
    [super viewDidLoad];

    
    
    // NavigationBarを初期化
    
    [self setTitle:@"Shelves"];
    _scanButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCamera target:self action:@selector(scanButtonDidTap:)];
    [_scanButton setTintColor:kBarTintColor];
    _donebutton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneButtonDidTap:)];    
    [_donebutton setTintColor:kBarTintColor];
    
    _titleButton = [[UIBarButtonItem alloc] initWithTitle:@"Shelves" style:UIBarButtonItemStyleBordered target:self action:@selector(titleButtonDidTap:)];
    [_titleButton setTintColor:kBarTintColor];

    UITapGestureRecognizer *tgr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(titleDidTap:)];
    [self.navigationItem.titleView addGestureRecognizer:tgr];
    
    [[self editButtonItem] setTintColor:kBarTintColor];
    [[self navigationItem] setLeftBarButtonItem:[self editButtonItem]];
    [[self navigationItem] setRightBarButtonItem:_scanButton];
    
    // Toolbarを初期化
    
    [self.navigationController.toolbar setBackgroundImage:[UIImage imageNamed:@"barbg.png"] forToolbarPosition:UIToolbarPositionBottom barMetrics:UIBarMetricsDefault];
    _segmentedControl = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:@"Title",@"Author",@"Date",@"Stared", nil]];
    [_segmentedControl setSelectedSegmentIndex:0];
    [_segmentedControl setSegmentedControlStyle:UISegmentedControlStyleBar];
    [_segmentedControl setTintColor:kBarTintColor];
    [_segmentedControl addTarget:self action:@selector(segmentedControlDidChange:) forControlEvents:UIControlEventValueChanged];
    _segmentedControlItem = [[UIBarButtonItem alloc] initWithCustomView:_segmentedControl];
    
    _addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addButtonDidTap:)];
    [_addButton setTintColor:kBarTintColor];
    
    [self setToolbarItems:[NSArray arrayWithObjects:_segmentedControlItem,_addButton, nil]];
    
    
    // ZbarImageViewを構築
    [_readerWrapperView setFrame:kDefaultReaderViewFrame];
    ZBarImageScanner *scanner = [[ZBarImageScanner alloc] init];
    // EXAMPLE: disable rarely used I2/5 to improve performance
    [scanner setSymbology: ZBAR_I25 config: ZBAR_CFG_ENABLE to: 0];
    _readerView = [[ZBarReaderView alloc] initWithImageScanner:scanner];
    [_readerView setFrame:_readerWrapperView.frame];
    [_readerView setReaderDelegate:self];
    [_readerWrapperView addSubview:_readerView];
    
    // TableViewを初期化    
    [_tableView setFrame:kDefaultTableViewFrame];
    [_tableView setDelegate:self];
    [_tableView setDataSource:self];
    
    // SearchBarを初期化
    
    [_searchBar setDelegate:self];
    [self.searchDisplayController setDelegate:self];
    
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
    [bottomShadowLayer setFrame:self.view.bounds];
    [self.view.layer addSublayer:bottomShadowLayer];
    [bottomShadowLayer setMasksToBounds:YES];
    CGRect dpsFrame = CGRectMake(-10.0, self.view.bounds.size.height + 10.0, bottomShadowLayer.bounds.size.width+10.0, 10.0);
    UIBezierPath *dpsPath = [UIBezierPath bezierPathWithRect:dpsFrame];
    [bottomShadowLayer setShadowOffset:CGSizeMake(0, 2.5)];
    [bottomShadowLayer setShadowColor:[[UIColor blackColor] CGColor]];
    [bottomShadowLayer setShadowOpacity:0.75];
    [bottomShadowLayer setShadowPath:[dpsPath CGPath]];

}

- (void)viewDidUnload
{
    [self setSearchBar:nil];
    [self setTableView:nil];
    [self setReaderWrapperView:nil];
    _readerView = nil;
    _scanButton = nil;
    _donebutton = nil;
    _segmentedControl = nil;
    _segmentedControlItem = nil;
    _addButton = nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    static NSString *segueIDForBook = @"showDetail";
    if ([[segue identifier] isEqualToString:segueIDForBook]) {
        SFBookViewController *bvc = (SFBookViewController*)[segue destinationViewController];
        [bvc setManagedObjectContext:[self managedObjectContext]];
    }
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [[self.fetchedResultsController sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
    return [sectionInfo numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellID = @"ShelfCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellID];
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
        [context deleteObject:[self.fetchedResultsController objectAtIndexPath:indexPath]];
        
        NSError *error = nil;
        if (![context save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }   
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - Fetched results controller

- (NSFetchedResultsController *)fetchedResultsController
{
    if (__fetchedResultsController != nil) {
        return __fetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Book" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    
    // Edit the sort key as appropriate.
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"title" ascending:NO];
    NSArray *sortDescriptors = [NSArray arrayWithObjects:sortDescriptor, nil];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:@"Master"];
    aFetchedResultsController.delegate = self;
    self.fetchedResultsController = aFetchedResultsController;
    
	NSError *error = nil;
	if (![self.fetchedResultsController performFetch:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
	    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
	    abort();
	}
    
    return __fetchedResultsController;
}    

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
    UITableView *tableView = self.tableView;
    
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self configureCell:[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView endUpdates];
}

/*
 // Implementing the above methods to update the table view in response to individual changes may have performance implications if a large number of changes are made simultaneously. If this proves to be an issue, you can instead just implement controllerDidChangeContent: which notifies the delegate that all section and object changes have been processed. 
 
 - (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
 {
 // In the simplest, most efficient, case, reload the table view.
 [self.tableView reloadData];
 }
 */

#pragma mark - ZBarReaderView

- (void)readerView:(ZBarReaderView *)readerView didReadSymbols:(ZBarSymbolSet *)symbols fromImage:(UIImage *)image
{

    [_readerView stop];
    
    for(ZBarSymbol *symbol in symbols) {
        
        NSString *resultText = [symbol data];
        
        // 楽天ブックス総合検索APIのURL
        
        NSMutableString *apiURIString = [NSMutableString stringWithString:@"http://api.rakuten.co.jp/rws/3.0/json?"];
        [apiURIString appendFormat:@"developerId=%@&",kRakutenAPPID];
        [apiURIString appendString:@"operation=BooksTotalSearch&"];
        [apiURIString appendString:@"version=2011-12-01&"];
        [apiURIString appendFormat:@"isbnjan=%@",resultText];
        //        NSLog(@"url is %@",apiURIString);        
        
        // HTTPRequestを構築
        R9HTTPRequest *req = [[R9HTTPRequest alloc] initWithURL:[NSURL URLWithString:[apiURIString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
        
        // ぐるぐるを表示
        [SVProgressHUD showWithStatus:@"Loading"];
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        
        // 成功時および失敗時のハンドラをセット
        [req setCompletionHandler:^(NSHTTPURLResponse *responseHeader, NSString *responseString){
            //        NSLog(@"Reponse is : %@",responseHeader);
            //        NSLog(@"body is %@",responseString);
            NSDictionary *JSON = [NSDictionary dictionary];
            @try {
                JSON = [[[[[[responseString JSONValue] objectForKey:@"Body"] objectForKey:@"BooksTotalSearch"] objectForKey:@"Items"] objectForKey:@"Item"] objectAtIndex:0];
                [self insertNewObject:JSON];
                [SVProgressHUD dismissWithSuccess:[JSON objectForKey:@"title"] afterDelay:3.0f];
            }
            @catch (NSException *exception) {
                NSLog(@"data not found : %@",responseString);
                [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
                [SVProgressHUD dismissWithError:@"Product not found" afterDelay:3.0f];
            }
            @finally {
                [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
                [_readerView start];
            }                      
        }];
        [req setFailedHandler:^(NSError *error){
            [SVProgressHUD dismissWithError:@"Error happed" afterDelay:3.0f];
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
            NSLog(@"error happend : %@",error);
            [_readerView start];
        }];
        
        // リクエストをスタート
        [req startRequest];
    }
}

#pragma mark - Private Method

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"reload table");
    NSManagedObject *object = [self.fetchedResultsController objectAtIndexPath:indexPath];
    //    cell.textLabel.text = [[object valueForKey:@"timeStamp"] description];
    [cell.textLabel setText:[[object valueForKey:@"title"] description]];
    [cell.detailTextLabel setText:[[object valueForKey:@"author"] description]];
    if ([object valueForKey:@"mediumImage"]) {        
        [cell.imageView setImage:[UIImage imageWithData:[object valueForKey:@"mediumImage"]]];
    }
}

- (void)titleDidTap:(id)sender
{
    NSLog(@"title did tap");
}

- (void)scanButtonDidTap:(id)sender 
{
    [_readerView start];
    [UIView animateWithDuration:0.25f delay:0.0 options:(UIViewAnimationCurveEaseIn <<  16) animations:^(void){
        _readerWrapperView.frame = kScanModeReaderViewFrame;
        _tableView.frame = kScanModeTableViewFrame;
    }completion:^(BOOL finished){
//        [self.tableView setTableHeaderView:_readerView];
        [self.navigationItem setRightBarButtonItem:_donebutton];
        [self setTitle:@"Scan Barcode"];
    }];

}

- (void)doneButtonDidTap:(id)sender
{
    [_readerView stop];
    [UIView animateWithDuration:0.25f delay:0.0 options:(UIViewAnimationCurveEaseIn <<  16) animations:^(void){
        _readerWrapperView.frame = kDefaultReaderViewFrame;
        _tableView.frame = kDefaultTableViewFrame;
    }completion:^(BOOL finished){
        [self.navigationItem setRightBarButtonItem:_scanButton];
//        [self.tableView setTableHeaderView:_searchBar];
        [self setTitle:@"Shelf"];
    }];
}

- (void)addButtonDidTap:(id)sender {
    NSLog(@"add button did tap");
}

- (void)segmentedControlDidChange:(UISegmentedControl *)sender
{
    NSLog(@"segmented control did change index : %i",[_segmentedControl selectedSegmentIndex]);
}

- (void)insertNewObject:(NSDictionary*)book
{
    NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
    NSEntityDescription *entity = [[self.fetchedResultsController fetchRequest] entity];
    NSManagedObject *newManagedObject = [NSEntityDescription insertNewObjectForEntityForName:[entity name] inManagedObjectContext:context];
    
    // If appropriate, configure the new managed object.
    // Normally you should use accessor methods, but using KVC here avoids the need to add a custom class to the template.
    NSDateFormatter *fm = [[NSDateFormatter alloc] init];
    [fm setDateFormat:@"yyyy年MM月"];
    [newManagedObject setValue:[book objectForKey:@"title"] forKey:@"title"];
    [newManagedObject setValue:[book objectForKey:@"author"] forKey:@"author"];
    [newManagedObject setValue:[book objectForKey:@"artistName"] forKey:@"artistName"];
    [newManagedObject setValue:[book objectForKey:@"itemCaption"] forKey:@"itemCaption"];
    [newManagedObject setValue:[fm dateFromString:[book objectForKey:@"salesDate"]] forKey:@"salesDate"];
    [newManagedObject setValue:[book objectForKey:@"itemUrl"] forKey:@"itemUrl"];
    
    if ([book objectForKey:@"isbn"]) {
        [newManagedObject setValue:[book objectForKey:@"isbn"] forKey:@"isbnjan"];
    }else if ([book objectForKey:@"jan"]) {
        [newManagedObject setValue:[book objectForKey:@"jan"] forKey:@"isbnjan"];
    }
    
    [newManagedObject setValue:[NSDate date] forKey:@"created"];
    [newManagedObject setValue:[NSDate date] forKey:@"updated"];
    
    _currentManagedObject = newManagedObject;
    _currentManagedObjectContext = context;    
    
    SFImageDownloader *downloader = [[SFImageDownloader alloc] initWithURL:[NSURL URLWithString:[book objectForKey:@"mediumImageUrl"]]];
    [downloader setDelegate:self];    
    [downloader startDownload];
    
//    [newManagedObject setValue:imgData forKey:@"mediumImage"];
    
    // Save the context.
    NSError *error = nil;
    if (![context save:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
}



- (void)downloader:(SFImageDownloader *)downloader didFailWithError:(NSError *)error
{
    NSLog(@"dl error");
}

- (void)downloader:(SFImageDownloader *)downloader didFinishLoading:(NSData *)data
{
    NSLog(@"iameg dl finied");

    [_currentManagedObject setValue:data forKey:@"mediumImage"];
    // Save the context.
    NSError *error = nil;
    if (![_currentManagedObjectContext save:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    [self.tableView reloadData];
}

@end
