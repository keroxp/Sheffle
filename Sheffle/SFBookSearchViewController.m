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
#import "KXP.h"

@interface SFBookSearchViewController ()
{
    NSArray *_results;
    NSMutableDictionary *_thumbnails;
    SFAPIConnection *_currentConnection;
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
    _thumbnails = [NSMutableDictionary dictionary];
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.searchDisplayController.delegate = self;
    self.searchDisplayController.searchResultsDataSource = self;
    self.searchDisplayController.searchBar.delegate = self;
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(reload)];
}

- (void)reload
{
    [[self tableViewToBeAssigned] reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Lazy Image Download

- (NSInteger)numberOfContents
{
    return _results.count;
}

- (NSString *)imageURLForIndexPath:(NSIndexPath *)indexPath
{
    return [[_results objectAtIndex:indexPath.row] objectForKey:@"mediumImageUrl"];
}

- (NSMutableDictionary *)thumbnails
{
    return _thumbnails;
}

- (UITableView *)tableViewToBeAssigned
{
    if (self.searchDisplayController.isActive) {
        return self.searchDisplayController.searchResultsTableView;
    }else{
        return self.tableView;
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return (_results.count == 0) ? 1 : _results.count;
}

- (NSString *)pathForPlaceholderImage
{
    return [[NSBundle mainBundle] pathForResource:@"Placeholder" ofType:@"png"];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"BookSearchCell";
    static NSString *NotFound = @"NotFound";
    static NSString *Loading = @"Loading";
    
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];

    if (_results.count == 0 && indexPath.section == 0 && indexPath.row == 0) {
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
    
    if (_results.count > 0) {
        NSDictionary *book = [_results objectAtIndex:indexPath.row];
        cell.textLabel.text = [book objectForKey:@"title"];
        cell.detailTextLabel.text = [book objectForKey:@"author"];
        cell.imageView.image = [self imageForIndexPath:indexPath];
    }
    return cell;
}

#pragma mark - UISearch Bar Delegate

- (void)startSearchWithParameters:(NSDictionary*)params
{
    // 遅延実行予約を消す
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    
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
            $(@"%@",JSON);
//$(@"body is %@",responseString);
            if ([JSON objectForKey:@"Body"] != nil && [JSON objectForKey:@"Body"] != [NSNull null]) {
                // 成功時
                _results = [[[[JSON objectForKey:@"Body"] objectForKey:@"BooksBookSearch"] objectForKey:@"Items"] objectForKey:@"Item"];                
                [self.searchDisplayController.searchResultsTableView reloadData];
            }else{
                // 失敗時
                $(@"data might not be found");
                [self.searchDisplayController.searchResultsTableView reloadData];
            }
            
        }];
        [c startAPIConnection];
        _currentConnection = c;
    }
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    // 遅延実行予約を消す
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    if (searchText.length > 0) {
        // 遅延予約
        [self performSelector:@selector(startSearchWithParameters:) withObject:@{@"title" : searchText} afterDelay:1.5f];
    }
}

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    // searchDisplayController setActive:NOをすると困るので似たような処理を手動でやる
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [self.tableViewToBeAssigned reloadData];
    [self startSearchWithParameters:@{@"title" : searchBar.text}];
}


#pragma mark - Action

- (IBAction)cancelButtonDidTap:(UIBarButtonItem *)sender {
    // モーダルビューを消す
    [self dismissModalViewControllerAnimated:YES];
}

#pragma mark - Segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"showSearchDetail"]) {
        UIViewController *vc = segue.destinationViewController;
        vc.title = [[_results objectAtIndex:self.searchDisplayController.searchResultsTableView.indexPathForSelectedRow.row] objectForKey:@"title"];
    }
}
@end
