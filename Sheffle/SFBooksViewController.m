//
//  SFBooksViewController.m
//  Sheffle
//
//  Created by 桜井雄介 on 2012/11/08.
//  Copyright (c) 2012年 Kaeru Lab. All rights reserved.
//

#import "SFBooksViewController.h"
#import "SFBookViewController.h"
#import "SFCoreDataManager.h"
#import "SFBook.h"

@interface SFBooksViewController ()
{
    NSArray *_sectionIndexes;
    NSMutableDictionary *_sectionIndexTitles;
    NSInteger _currentSortIndex;
}

- (NSArray*)sectionIndexTitles;

@end

@implementation SFBooksViewController

@synthesize fetchedResultsController = __fetchedResultsController;

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
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    self.navigationItem.leftBarButtonItem = self.editButtonItem;
    self.searchDisplayController.searchBar.delegate = self;
    self.searchDisplayController.delegate = self;    
    self.searchDisplayController.searchResultsDataSource = self;
    
    self.searchDisplayController.searchBar.showsScopeBar = NO;
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    NSError *e = nil;
    [self.fetchedResultsController performFetch:&e];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"showBook"]) {
        SFBookViewController *bvc = (SFBookViewController*)segue.destinationViewController;
        NSIndexPath *i = [self.tableView indexPathForSelectedRow];
        bvc.book = [self.fetchedResultsController objectAtIndexPath:i];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return self.fetchedResultsController.sections.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
    return [sectionInfo numberOfObjects];
}

- (NSArray *)sectionIndexTitles
{
    if (!_sectionIndexes) {
        int sectionCount = self.fetchedResultsController.sections.count;
        int max = (sectionCount < 25 ) ? sectionCount : 25;
//        NSString *indexStrings = @"あ/か/さ/た/な/は/ま/や/ら/わ/A/●/D/●/G/●/J/●/M/●/P/●/T/●/Z";
        NSMutableArray *ma = [NSMutableArray arrayWithCapacity:max];
        for (int i = 0 ; i < max; i++) {
            NSString *name = [[self.fetchedResultsController.sections objectAtIndex:i] name];
            [ma addObject:name];
        }
//        _sectionIndexes = [indexStrings componentsSeparatedByString:@"/"];
        _sectionIndexes = ma;
    }
    return _sectionIndexes;
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    if (!_sectionIndexTitles) {
        _sectionIndexTitles = [NSMutableDictionary dictionaryWithCapacity:3];
    }
    
    if (![_sectionIndexTitles objectForKey:self.fetchedResultsController.sectionNameKeyPath]) {
        int sectionCount = self.fetchedResultsController.sections.count;
        int max = (sectionCount < 25 ) ? sectionCount : 25;
        //        NSString *indexStrings = @"あ/か/さ/た/な/は/ま/や/ら/わ/A/●/D/●/G/●/J/●/M/●/P/●/T/●/Z";
        NSMutableArray *ma = [NSMutableArray arrayWithCapacity:max];
        for (int i = 0 ; i < max; i++) {
            int index = self.fetchedResultsController.sections.count / max * i;
            NSString *name = [[[self.fetchedResultsController.sections objectAtIndex:index] name] substringWithRange:NSMakeRange(0, 1)];
            [ma addObject:name];
        }
        [_sectionIndexTitles setObject:ma forKey:[self.fetchedResultsController.sectionNameKeyPath copy]];
    }
    return [_sectionIndexTitles objectForKey:self.fetchedResultsController.sectionNameKeyPath];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [[self.fetchedResultsController.sections objectAtIndex:section] name];
}
//
//- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
//{
//    int cellNum = (int)self.fetchedResultsController.sections.count/25 * index;
//    
////    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:cellNum inSection:0];
////    [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:NO];
//    return index;
//}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"BooksCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    // Configure the cell...
    SFBook *book = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = book.title;
    cell.detailTextLabel.text = book.author;
    cell.imageView.contentMode = UIViewContentModeScaleAspectFit;
    cell.imageView.image = [UIImage imageWithData:book.image2x];
        
    return cell;
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

#pragma mark - Fetched Results Controller Delegate

- (NSFetchedResultsController *)fetchedResultsController{
    if (!__fetchedResultsController) {
        NSSortDescriptor *title = [[NSSortDescriptor alloc] initWithKey:@"titleKana" ascending:YES];
        __fetchedResultsController = [[SFCoreDataManager sharedManager] fetchedResultsControllerWithEntityName:@"Book"
                                                                                               sortDescriptors:@[title]
                                                                                            sectionNameKeyPath:@"titleInitial"
                                                                                                     cacheName:@"BookWithTitle"];
    }
    return __fetchedResultsController;
}

- (void)viewDidUnload {
    [self setSortControl:nil];
    [self setAddButton:nil];
    [super viewDidUnload];
}

- (IBAction)sortControlDidChange:(UISegmentedControl*)sender
{
    $(@"%i",sender.selectedSegmentIndex);
    if (sender.selectedSegmentIndex != _currentSortIndex) {
        
        NSSortDescriptor *title = [[NSSortDescriptor alloc] initWithKey:@"titleKana" ascending:YES];
        NSSortDescriptor *author = [[NSSortDescriptor alloc] initWithKey:@"author" ascending:YES];
        NSSortDescriptor *publisher = [[NSSortDescriptor alloc] initWithKey:@"publisherName" ascending:YES];
        
        switch (sender.selectedSegmentIndex) {
            case 0: {
                __fetchedResultsController = [[SFCoreDataManager sharedManager] fetchedResultsControllerWithEntityName:@"Book" sortDescriptors:@[title,author,publisher] sectionNameKeyPath:@"titleInitial" cacheName:@"BookWithTitle"];
                self.sortType = SFBookSortTypeTitle;
            }
                break;
            case 1: {
                __fetchedResultsController = [[SFCoreDataManager sharedManager] fetchedResultsControllerWithEntityName:@"Book" sortDescriptors:@[author,title,publisher] sectionNameKeyPath:@"author" cacheName:@"BookWithAuthor"];
                self.sortType = SFBookSortTypeAuthor;
            }
                break;
            case 2: {
                __fetchedResultsController = [[SFCoreDataManager sharedManager] fetchedResultsControllerWithEntityName:@"Book" sortDescriptors:@[publisher,title,author] sectionNameKeyPath:@"publisherName" cacheName:@"BookWithPublisher"];
                self.sortType = SFBookSortTypePublisher;
            }
                break;
            default:
                break;
        }
        [self.tableView reloadData];
        _currentSortIndex = sender.selectedSegmentIndex;
    }
}

- (IBAction)addButtonDidTap:(id)sender {
}

#pragma mark - Search Display

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    searchBar.showsScopeBar = YES;
    return YES;
}

@end
