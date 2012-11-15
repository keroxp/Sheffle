//
//  SFShelvesViewController.m
//  Sheffle
//
//  Created by 桜井 雄介 on 2012/08/05.
//  Copyright (c) 2012年 Kaeru Lab. All rights reserved.
//

#import "SFShelvesViewController.h"
#import "SFShelfViewController.h"
#import "SFAppDelegate.h"
#import "SFPopoverViewController.h"

@interface SFShelvesViewController ()
{
    BOOL _isEdittingTitle;
    NSIndexPath *_selectedPath;
    UIAlertView *_alertView;
    BOOL _hidden;
    SFPopoverViewController *_popoverController;
}

- (void)cancelButtonDidTap:(id)sender;
- (void)addButtonDidTap:(id)sender;

@end

@implementation SFShelvesViewController

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
    
    _hidden = YES;

    // Uncomment the following line to preserve selection between presentations.
    self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addButtonDidTap:)];
    addButton.style = UIBarButtonItemStyleBordered;
    addButton.tintColor = kBarTintColor;
    
    self.title = @"Shelves";
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    UIBarButtonItem *sp = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    [self setToolbarItems:@[sp,addButton]];
    
    // Viewの初期化
    self.searchDisplayController.delegate = self;
    self.searchDisplayController.searchResultsDataSource = self;
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(showPop:)];
}

- (void)showPop:(UIBarButtonItem*)sender
{
    if (_popoverController == nil) {
        SFShelvesViewController *sv = [self.storyboard instantiateViewControllerWithIdentifier:@"BooksView"];
        UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:sv];
        SFPopoverViewController *pvc = [[SFPopoverViewController alloc] initWithViewContentViewController:nc];
        _popoverController = pvc;
    }
    
    if (_hidden) {
        [_popoverController showInView:self.view animated:YES];
        _hidden = NO;
    }else{
        [_popoverController dismisWithAnimated:YES];
        _hidden = YES;
    }

}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    self.fetchedResultsController = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Action Handlers

- (void)addButtonDidTap:(id)sender
{
    $(@"add");
    if (!_alertView) {
        _alertView = [[UIAlertView alloc] initWithTitle:@"New Shelf" message:nil delegate:self cancelButtonTitle:@"Cencel" otherButtonTitles:@"Save", nil];
        _alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
        _alertView.tag = 100;
        UITextField *tf = [_alertView textFieldAtIndex:0];
        tf.placeholder = @"Shelf Title";
    }
    [_alertView textFieldAtIndex:0].text = nil;
    [_alertView show];

}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 100) {
        // 追加
        switch (buttonIndex) {
            case 0:
                [alertView dismissWithClickedButtonIndex:0 animated:YES];
                break;
            case 1: {
                // 本棚の保存
                UITextField *tf = [alertView textFieldAtIndex:0];
                SFShelf *newShelf = [[SFCoreDataManager sharedManager] insertNewShelf];
                if ([tf.text isEqualToString:@""]) {
                    newShelf.title = @"Undefined Shelf";
                }else{
                    newShelf.title = tf.text;
                }
                [newShelf setIndex:@(self.fetchedResultsController.fetchedObjects.count)];
                [[SFCoreDataManager sharedManager] saveContext];
            }
                break;
            default:
                break;
        }
    }else if (alertView.tag == 200){
        NSManagedObjectContext *moc = [[SFCoreDataManager sharedManager] managedObjectContext];
        SFShelf *shelf = [self.fetchedResultsController objectAtIndexPath:_selectedPath];
        switch (buttonIndex) {
            case 0: {
                [self setEditing:NO animated:YES];
                break;
            }
            case 1: {
                //本棚のみ
                SFShelf *defaultShelf = [self.fetchedResultsController.fetchedObjects objectAtIndex:kDefaultShelfIndex];
                [defaultShelf addBooks:shelf.books];
                [moc deleteObject:shelf];
                [[SFCoreDataManager sharedManager] saveContext];
                [self setEditing:NO animated:YES];
                break;
            }
            case 2: {
                // 本ごと
                NSString *t = @"この操作は取り消せません";
                NSString *m = [NSString stringWithFormat:@"本当に\"%@\"とその本を削除しますか？",shelf.title];
                UIAlertView *av = [[UIAlertView alloc] initWithTitle:t message:m delegate:self cancelButtonTitle:@"やめる" otherButtonTitles:@"削除", nil];
                av.tag = 300;
//                  [alertView dismissWithClickedButtonIndex:alertView.cancelButtonIndex animated:NO];
                [av show];
                break;
            }
            default:
                break;
        }
    }else if (alertView.tag == 300){
        NSManagedObjectContext *moc = [[SFCoreDataManager sharedManager] managedObjectContext];
        SFShelf *shelf = [self.fetchedResultsController objectAtIndexPath:_selectedPath];
        switch (buttonIndex) {
            case 1: {
                for (SFBook*book in shelf.books) {
                    [moc deleteObject:book];
                }
                [moc deleteObject:shelf];
                [[SFCoreDataManager sharedManager] saveContext];
                [self setEditing:NO animated:YES];
                break;
            }
            default:
                break;
        }
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;//self.fetchedResultsController.sections.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // 編集中は追加ボタンを出す
//    id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController.sections objectAtIndex:section];
//    return [sectionInfo numberOfObjects];
    switch (section) {
        case 0:
            return 2;
        case 1:
            return self.fetchedResultsController.fetchedObjects.count;
        default:
            break;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *All = @"AllCell";
    static NSString *Shelves = @"ShelvesCell";
    static NSString *Favorite = @"FavoriteCell";
    
    TDBadgedCell *cell = nil;
    
    switch (indexPath.section) {
        case 0:
            switch (indexPath.row) {
                case 0:
                    // 全て
                    cell = [tableView dequeueReusableCellWithIdentifier:All];
                    cell.textLabel.text = @"すべての本";
                    return cell;
                    break;
                case 1:
                    // お気に入り
                    cell = [tableView dequeueReusableCellWithIdentifier:Favorite];
                    cell.textLabel.text = @"お気に入り";
                    return cell;
                    break;
                default:
                    break;
            }
            break;
        case 1: {
            cell = [tableView dequeueReusableCellWithIdentifier:Shelves];
            SFShelf *shelf = [self.fetchedResultsController.fetchedObjects objectAtIndex:indexPath.row];
            cell.textLabel.text = shelf.title;
            cell.badgeString = [NSString stringWithFormat:@"%i",shelf.books.count];
            cell.badgeColor = [UIColor darkGrayColor];
//            cell.detailTextLabel.text = [NSString stringWithFormat:@"%i",[shelf.index integerValue]];
//        bcell.badge.radius = 7.5f;
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            
            return cell;
        }
        default:
            break;
    }
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    if (indexPath.section == 0){
        if(indexPath.row == 0 || indexPath.row == 1){
                return NO;
        }
    }
    return YES;
}


// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        _selectedPath = indexPath;
        SFShelf *s = [self.fetchedResultsController objectAtIndexPath:indexPath];
        NSString *title = [NSString stringWithFormat:@"\"%@\"を削除",s.title];
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:title
                                                     message:@"削除の方法を選んでください"
                                                    delegate:self cancelButtonTitle:@"やめる"
                                           otherButtonTitles:@"本棚のみ削除",@"本も削除", nil];
        av.tag = 200;
        [av show];
    }
}


// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
    //並べ替え
    NSMutableArray *newOrder = [self.fetchedResultsController.fetchedObjects mutableCopy];
    SFShelf *move = [self.fetchedResultsController objectAtIndexPath:fromIndexPath];
    [newOrder removeObjectAtIndex:fromIndexPath.row];
    [newOrder insertObject:move atIndex:toIndexPath.row];

    // indexの再設定
    int i = 0;
    for (SFShelf *shelf in newOrder) {
        [shelf setIndex:@(i)];
        i++;
    }
    
    // 保存
    [[SFCoreDataManager sharedManager] saveContext];
    [self.tableView reloadData];
}

// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    if (indexPath.section == 0){
            return NO;
    }
    return YES;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    _selectedPath = indexPath;
    if (!self.isEditing) {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        [self performSegueWithIdentifier:@"showShelf" sender:self];
    }
}

#pragma mark - Segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showShelf"]) {
        SFShelfViewController *svc = [segue destinationViewController];
        svc.shelf = [self.fetchedResultsController objectAtIndexPath:_selectedPath];
//        svc.fetchedresultsController = self.fetchedResultsController;
//        self.fetchedResultsController.delegate = svc;
    }
}

#pragma mark - Fetched Results Controller

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath
{
//    $(@"did change content");
    UITableView *tableView = self.tableView;
    
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
        case NSFetchedResultsChangeDelete: {
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
            break;
        }
        case NSFetchedResultsChangeUpdate: {
            [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        }
            break;
        case NSFetchedResultsChangeMove: {
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
            [tableView insertRowsAtIndexPaths:@[newIndexPath]withRowAnimation:UITableViewRowAnimationNone];
            break;
        }
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id<NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
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
//
//- (NSString *)controller:(NSFetchedResultsController *)controller sectionIndexTitleForSectionName:(NSString *)sectionName
//{
//    ;
//}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView endUpdates];
}

#pragma mark - Core Data

- (NSFetchedResultsController *)fetchedResultsController
{
    if (_fetchedResultsController) {
        return _fetchedResultsController;
    }
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Shelf" inManagedObjectContext:[[SFCoreDataManager sharedManager] managedObjectContext]];
    NSSortDescriptor *index = [[NSSortDescriptor alloc] initWithKey:@"index" ascending:YES];

    _fetchedResultsController = [[SFCoreDataManager sharedManager] fetchedResultsControllerWithEntityName:@"Shelf" sortDescriptors:@[index] sectionNameKeyPath:nil cacheName:@"Shelf" predicate:nil];
    _fetchedResultsController.delegate = self;
    
    return _fetchedResultsController;
}

@end
