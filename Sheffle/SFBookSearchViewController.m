//
//  SFBookSearchViewController.m
//  Sheffle
//
//  Created by 桜井雄介 on 2012/11/11.
//  Copyright (c) 2012年 Kaeru Lab. All rights reserved.
//

#import "SFBookSearchViewController.h"
#import "R9HTTPRequest.h"
#import "SFAPIConnection.h"
#import "SFCoreDataManager.h"
#import "SFRakutenBook.h"
#import "KXPPickerViewController.h"

@interface SFBookSearchViewController ()
{
    NSArray *_results;
    NSMutableDictionary *_thumbnails;
    NSMutableDictionary *_thumbnails2;
    NSMutableArray *_booksToBeRegisted;
    NSMutableArray *_selectionStates;
    SFAPIConnection *_currentConnection;
    SFShelf *_currentShelf;
//    NSString *_currentShelf;
    NSInteger _selectedPickerIndex;
    KXPPickerViewController *_pickerViewController;
}
@end

@implementation SFBookSearchViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    _results = [NSArray array];
    _booksToBeRegisted = [NSMutableArray array];
    _selectionStates = [NSMutableArray array];
    _thumbnails = [NSMutableDictionary dictionary];
    _thumbnails2 = [NSMutableDictionary dictionary];

    // 本棚を読み込み
    if (!_shelves) {
        _shelves = [[SFCoreDataManager sharedManager] shelves];
    }
    // 何もなければ一番上を選択
    _currentShelf = (self.shelves.count > 0) ? [_shelves objectAtIndex:0] : nil;

    
    KXPPickerViewController *pvc = [[KXPPickerViewController alloc] init];
    pvc.delegate = self;
    pvc.pickerView.delegate = self;
    pvc.pickerView.dataSource = self;
    _pickerViewController = pvc;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.searchDisplayController.delegate = self;
    self.searchDisplayController.searchResultsDataSource = self;
    self.searchDisplayController.searchResultsDelegate = self;
    self.searchDisplayController.searchBar.delegate = self;
    
//    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(reload)];
//    self.navigationItem.leftBarButtonItem = self.editButtonItem;
    [self.navigationItem setRightBarButtonItems:@[self.doneButton,self.editButtonItem]];
    
}

- (void)configureDoneButton
{
    if (_booksToBeRegisted.count > 0) {
        [_doneButton setEnabled:YES];
    }else{
        [_doneButton setEnabled:NO];
    }
}

- (void)reload
{
//    [[self tableViewToBeAssigned] reloadData];
    $(@"%@",self.tableViewToBeAssigned);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.searchDisplayController.searchBar becomeFirstResponder];
}

#pragma mark - UIPickerView

// デリゲートメソッドの実装
-(NSInteger)numberOfComponentsInPickerView:(UIPickerView*)pickerView{
    return 1;
}

// 行数を返す例
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return _shelves.count;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    $();
    _selectedPickerIndex = row;
}

// 表示する内容を返す例
-(NSString*)pickerView:(UIPickerView*)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{    
    // 行インデックス番号を返す
    return [[_shelves objectAtIndex:row] title];
}

- (void)pickerViewController:(KXPPickerViewController *)controller didTapCancelButton:(UIBarButtonItem *)cancelButton
{
    // cancel
    [controller dismissWithAnimated:NO];
}

- (void)pickerViewController:(KXPPickerViewController *)controller didTapDoneButton:(UIBarButtonItem *)doneButton
{
    $();
    _currentShelf = [_shelves objectAtIndex:_selectedPickerIndex];
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
    [controller dismissWithAnimated:NO];
}

#pragma mark - Lazy Image Download

- (NSInteger)numberOfContents
{
    return _results.count;
}

- (NSString *)imageURLForIndexPath:(NSIndexPath *)indexPath
{
    SFRakutenBook *book = (self.searchDisplayController.isActive) ? [_results objectAtIndex:indexPath.row] : [_booksToBeRegisted objectAtIndex:indexPath.row];
    return book.mediumImageUrl;
}

- (NSMutableDictionary *)thumbnails
{
    return (self.searchDisplayController.isActive) ? _thumbnails : _thumbnails2;
}

- (UITableView *)tableViewToBeAssigned
{
    if (self.searchDisplayController.isActive) {
        return self.searchDisplayController.searchResultsTableView;
    }else{
        return self.tableView;
    }
}

- (NSString *)pathForPlaceholderImage
{
    return [[NSBundle mainBundle] pathForResource:@"Placeholder" ofType:@"png"];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return (tableView == self.tableView) ? 2 : 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if (tableView == self.tableView) {
        switch (section) {
            case 0:
                return 1;
                break;
//            case 1:
//                return 1;
//                break;
            case 1:
                return (_booksToBeRegisted.count == 0) ? 1 : _booksToBeRegisted.count;
                break;
            default:
                break;
        }
    }else{
        return (_results.count == 0) ? 1 : _results.count;
    }
    return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (tableView == self.tableView) {
        switch (section) {
            case 0:
                return @"Shelf to be registerd";
                break;
            case 1:
                return @"Selected Items";
                break;
            default:
                break;
        }
    }
    return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *Shelf = @"ShelfCell";
    static NSString *Book = @"BookCell";
    static NSString *Results = @"ResultsCell";
    static NSString *NotFound = @"NotFoundCell";
    static NSString *Loading = @"LoadingCell";
    
    UITableViewCell *cell = nil;

    if (tableView == self.tableView) {
        [self configureDoneButton];
        switch (indexPath.section) {
            case 0:
                cell = [tableView dequeueReusableCellWithIdentifier:Shelf];
                cell.textLabel.text = _currentShelf.title;
                break;
            case 1: {
                cell = [tableView dequeueReusableCellWithIdentifier:Book];
                if (_booksToBeRegisted.count == 0) {
                    KXPNotFoundCell *ncell = [[KXPNotFoundCell alloc] initWithReuseIdentifier:NotFound];
                    ncell.textLabel.text = @"Not Selected";
                    return ncell;
                }else{
                    SFRakutenBook *book = [_booksToBeRegisted objectAtIndex:indexPath.row];
                    cell.textLabel.text = book.title;
                    cell.detailTextLabel.text = book.author;
                    cell.imageView.image = [self imageForIndexPath:indexPath];
                }
            }
            default:
                break;
        }
    }else{
        
        cell = [tableView dequeueReusableCellWithIdentifier:Results];
        
        if (_results.count == 0 && indexPath.row == 0) {
            if (!_currentConnection) {
                KXPNotFoundCell *ncell = [tableView dequeueReusableCellWithIdentifier:NotFound];
                if (!ncell) {
                    ncell = [[KXPNotFoundCell alloc] initWithReuseIdentifier:NotFound];
                }                
                return ncell;
            }else{
                KXPLoadingCell *lcell = [tableView dequeueReusableCellWithIdentifier:Loading];
                if (!lcell) {
                    lcell = [[KXPLoadingCell alloc] initWithReuseIdentifier:Loading];
                }
                return lcell;
            }
        }
        
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:Results];
        }
        
        if (_results.count > 0) {
            SFRakutenBook *book = [_results objectAtIndex:indexPath.row];
            cell.textLabel.text = book.title;
            cell.detailTextLabel.text = (book.author.length > 0) ? book.author : @"Unknown";
            cell.imageView.image = [self imageForIndexPath:indexPath];
            cell.accessoryType = ([[_selectionStates objectAtIndex:indexPath.row] boolValue]) ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
        }
    }
    
    return cell;
}

#pragma mark - Table View Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.tableView) {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        switch (indexPath.section) {
            case 0:
                // 本棚選択
                [_pickerViewController showWithAnimated:YES];
                break;
            case 1:
                break;
            case 2:
                break;
            default:
                break;
        }
    }else{
        if (_results.count > 0) {
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
            SFRakutenBook *book = [_results objectAtIndex:indexPath.row];
            $(@"%@",book.title);
            if ([[_selectionStates objectAtIndex:indexPath.row] boolValue]) {
                // 非選択
                [_selectionStates replaceObjectAtIndex:indexPath.row withObject:@(NO)];
                [_booksToBeRegisted removeObject:book];
                $(@"unchecked");
            }else{
                // 選択
                [_selectionStates replaceObjectAtIndex:indexPath.row withObject:@(YES)];
                [_booksToBeRegisted addObject:book];
                $(@"checked");
            }
            [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            $(@"%@",_booksToBeRegisted);
        }
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.tableView && indexPath.section == 1) {
        return YES;
    }
    return NO;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.tableView) {
        if (editingStyle == UITableViewCellEditingStyleDelete) {
            // Delete the row from the data source
            [_booksToBeRegisted removeObjectAtIndex:indexPath.row];
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        }else if (editingStyle == UITableViewCellEditingStyleInsert) {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }
}

#pragma mark - UISearch Bar Delegate

- (void)startSearchWithParameters:(NSDictionary*)params
{
    // 遅延実行予約を消す
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    
    //サムネイルを消す
    [self.thumbnails removeAllObjects];
//    _results = nil;
    
    // 検索開始
    UISearchBar *searchBar = self.searchDisplayController.searchBar;
    if (searchBar.text.length > 0) {
        
        if (_currentConnection) {
            [_currentConnection cancelAPIConnection];
            _currentConnection = nil;
        }
        
        SFAPIConnection *c = [SFAPIConnection connectionWithRequestType:SFAPIRequestTypeBooksBookSearch patameters:params];
        [c setCompletionHandler:^(NSHTTPURLResponse *r, NSDictionary *JSON){            
            $(@"Reponse is : %i",r.statusCode);
//            $(@"%@",JSON);
            if ([JSON objectForKey:@"Body"] != nil && [JSON objectForKey:@"Body"] != [NSNull null]) {
                // 成功時
                _results = [SFRakutenBook booksWithbooks:[[[[JSON objectForKey:@"Body"] objectForKey:@"BooksBookSearch"] objectForKey:@"Items"] objectForKey:@"Item"]];
                for (int i = 0; i < _results.count; i++) {
                    [_selectionStates addObject:@(NO)];
                }
                _currentConnection = nil;
                [self.tableViewToBeAssigned reloadData];
            }else{
                // 失敗時
                $(@"data might not be found");
                _currentConnection = nil;
                [self.tableViewToBeAssigned reloadData];
            }
            
        }];
        [c startAPIConnection];
        _currentConnection = c;
    }
}

- (void)searchDisplayController:(UISearchDisplayController *)controller willHideSearchResultsTableView:(UITableView *)tableView
{
    [self.tableView reloadData];
}

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    // searchDisplayController setActive:NOをすると困るので似たような処理を手動でやる
//    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [self startSearchWithParameters:@{@"title" : searchBar.text}];
}

#pragma mark - Action

- (IBAction)cancelButtonDidTap:(UIBarButtonItem *)sender {
    // モーダルビューを消す
    [self dismissViewControllerAnimated:YES completion:NULL];    
}

- (IBAction)doneButtonDidTap:(id)sender {
    // 登録処理
    [_currentShelf addBooks:[SFBook bookSetWithRakutenBooks:_booksToBeRegisted]];
    [[SFCoreDataManager sharedManager] saveContext];
    [self dismissViewControllerAnimated:YES completion:NULL];
//    if ([self.delegate respondsToSelector:@selector(bookSearchViewController:didCommitRegisteringForShelf:books:)]){
//        [self.delegate bookSearchViewController:self didCommitRegisteringForShelf:_currentShelf books:_booksToBeRegisted];
//        [self dismissViewControllerAnimated:YES completion:NULL];
//    }
}

@end
