//
//  SFShelvesViewController.m
//  Sheffle
//
//  Created by 桜井 雄介 on 2012/08/05.
//  Copyright (c) 2012年 Kaeru Lab. All rights reserved.
//

#import "SFShelvesViewController.h"
#import "SFShelfViewController.h"

@interface SFShelvesViewController ()
{
    BOOL _isEdittingTitle;
    NSIndexPath *_selectedPath;
    UIAlertView *_alertView;
}
- (void)configureCell:(UITableViewCell*)cell atIndexPath:(NSIndexPath*)indexPath;
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

    // Uncomment the following line to preserve selection between presentations.
    self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addButtonDidTap:)];
    
    self.title = @"Shelves";
    self.navigationItem.leftBarButtonItem = self.editButtonItem;
    self.navigationItem.rightBarButtonItem = addButton;
    
    // Viewの初期化
    
    self.searchDisplayController.delegate = self;
    self.searchDisplayController.searchResultsDataSource = self;
    
    self.navigationController.navigationBar.opaque = NO;
    self.navigationController.navigationBar.layer.opaque = NO;
    
    // PullToAdd
    
//    [self.tableView addPullToRefreshWithActionHandler:^(void) {
//        [self addButtonDidTap:nil];
//    }];
    
//    UIImageView *iv = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"navbarbg.png"]];
//    iv.frame = CGRectMake(100, 200, iv.frame.size.width, iv.frame.size.height);
//    [self.view addSubview:iv];
    
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

- (void)cancelButtonDidTap:(id)sender
{
    $(@"cencel");
    [self dismissModalViewControllerAnimated:YES];
}

- (void)addButtonDidTap:(id)sender
{
    $(@"add");
    if (!_alertView) {
        _alertView = [[UIAlertView alloc] initWithTitle:@"New Shelf" message:nil delegate:self cancelButtonTitle:@"Cencel" otherButtonTitles:@"Save", nil];
        _alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
        UITextField *tf = [_alertView textFieldAtIndex:0];
        tf.placeholder = @"Shelf Title";
    }
    [_alertView textFieldAtIndex:0].text = nil;
    [_alertView show];

}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
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
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.fetchedResultsController.sections.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // 編集中は追加ボタンを出す
    id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController.sections objectAtIndex:section];
    return [sectionInfo numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"ShelvesCell_";
    static NSString *BadgedCellIdentifier = @"BadgedCell";
    static NSString *EditableCellIdentifier = @"EditableCell";

    
    //UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    TDBadgedCell *cell = [tableView dequeueReusableCellWithIdentifier:BadgedCellIdentifier];
    if (!cell) {
        cell = [[TDBadgedCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:BadgedCellIdentifier];
        //cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.textLabel.backgroundColor = [UIColor clearColor];
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    $(@"configure cell");
    SFShelf *shelf = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
        TDBadgedCell *bcell = (TDBadgedCell*)cell;
        bcell.textLabel.text = shelf.title;
        bcell.badgeString = [NSString stringWithFormat:@"%i",shelf.books.count];
        bcell.badgeColor = [UIColor darkGrayColor];
//        bcell.badge.radius = 7.5f;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
//        bcell.detailTextLabel.text = [NSString stringWithFormat:@"%i",shelf.books.count];
//        bcell.detailTextLabel.textColor = [UIColor whiteColor];
    
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
        NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
        [context deleteObject:[self.fetchedResultsController objectAtIndexPath:indexPath]];
        
        NSError *error = nil;
        if (![context save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            $(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
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
}

// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    if (indexPath.section == 0){
        if (indexPath.row == 0 || indexPath.row == 1) {
            return NO;
        }
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
    $(@"did change content");
    UITableView *tableView = self.tableView;
    
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate: {
            [self configureCell:[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
        }
            break;
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:@[newIndexPath]withRowAnimation:UITableViewRowAnimationFade];
            break;
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
    NSManagedObjectContext *context = [[SFCoreDataManager sharedManager] managedObjectContext];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Shelf" inManagedObjectContext:context];
    NSSortDescriptor *index = [[NSSortDescriptor alloc] initWithKey:@"index" ascending:YES];
    request.entity = entity;
    request.sortDescriptors = @[index];
    
    NSFetchedResultsController *frc = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:context sectionNameKeyPath:nil cacheName:@"Shelves"];
    frc.delegate = self;
    
//    [NSFetchedResultsController deleteCacheWithName:@"Shelves"];
    
    _fetchedResultsController = frc;
    
    NSError *error = nil;
    if (![_fetchedResultsController performFetch:&error]) {
        $(@"unsolvable error : %@", [error userInfo]);
        abort();
    }
    return _fetchedResultsController;
}

@end
