//
//  SFTableShelfViewController.m
//  Sheffle
//
//  Created by  on 12/07/24.
//  Copyright (c) 2012年 Kaeru Lab. All rights reserved.
//

#import "SFTableShelfViewController.h"
#import "SFShelfViewController.h"
#define kBarTintColor [UIColor colorWithRed:214.0f/255.0f green:168.0f/255.0f blue:91.0f/255.0f alpha:1.0f]

@interface SFTableShelfViewController ()
{
    NSIndexPath *_selectedPath;
    NSArray *_sectionIndexes;
    NSMutableDictionary *_sectionIndexTitles;
}

@end

@implementation SFTableShelfViewController

@synthesize fetchedResultsController = __fetchedResultsController;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self){

   }
    return self;
}

- (void)viewDidLoad 
{
    
    [self.tableView clearsContextBeforeDrawing];
    
    self.searchDisplayController.delegate = self;
    self.searchDisplayController.searchBar.delegate = self;
    self.searchDisplayController.searchResultsDataSource = self;
    
    [[self tableView] setAllowsMultipleSelectionDuringEditing:YES];        
}

- (void)viewDidUnload {
    [super viewDidUnload];
}

#pragma mark - Table View Data Source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [[self.fetchedResultsController sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
    return [sectionInfo numberOfObjects];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [[self.fetchedResultsController.sections objectAtIndex:section] name];
}

- (NSArray *)sectionIndexTitles
{
    if (!_sectionIndexes) {
        int sectionCount = self.fetchedResultsController.sections.count;
        int max = (sectionCount < 25 ) ? sectionCount : 25;
        NSMutableArray *ma = [NSMutableArray arrayWithCapacity:max];
        for (int i = 0 ; i < max; i++) {
            NSString *name = [[self.fetchedResultsController.sections objectAtIndex:i] name];
            [ma addObject:name];
        }
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


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellID = @"TableShelfCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellID];
        
    SFBook *book = [self.fetchedResultsController objectAtIndexPath:indexPath];
    [cell.textLabel setText:book.title];
    [cell.detailTextLabel setText:book.author];
    [cell.imageView setContentMode:UIViewContentModeScaleAspectFit];
    [cell.imageView setImage:[UIImage imageWithData:book.image]];    
    [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    
    return cell;
}


#pragma mark - Table View Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    _selectedPath = indexPath;
    if (!self.isEditing) {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        SFBook *book = [self.fetchedResultsController objectAtIndexPath:_selectedPath];
        [self.parentViewController performSegueWithIdentifier:@"showBook" sender:book];
    }else{
        NSArray *selectedRows = [self.tableView indexPathsForSelectedRows];
        int nob = selectedRows.count;
        NSString *deleteButtonTitle = [NSString stringWithFormat:@"Delete (%i)", nob];
        NSString *moveButtonTitle = [NSString stringWithFormat:@"Move (%i)", nob];
        NSString *staredButtonTitle = [NSString stringWithFormat:@"Stared (%i)", nob];
        if (selectedRows.count == self.fetchedResultsController.fetchedObjects.count)
        {
            deleteButtonTitle = @"Delete all";
            moveButtonTitle = @"Move all";
            staredButtonTitle = @"Stared all";
        }
        SFShelfViewController *svc = (SFShelfViewController*)self.parentViewController;
        svc.trashButton.title = deleteButtonTitle;
        svc.moveButton.title = moveButtonTitle;
        svc.staredButton.title = staredButtonTitle;
    }
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
            $(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}


/*
 // Implementing the above methods to update the table view in response to individual changes may have performance implications if a large number of changes are made simultaneously. If this proves to be an issue, you can instead just implement controllerDidChangeContent: which notifies the delegate that all section and object changes have been processed. 
 
 - (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
 {
 // In the simplest, most efficient, case, reload the table view.
 [self.tableView reloadData];
 }
 */

#pragma mark - Segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    static NSString *segueIDForBook = @"showBook";
    if ([[segue identifier] isEqualToString:segueIDForBook]) {
        SFBookViewController *bvc = (SFBookViewController*)[segue destinationViewController];
        [bvc setBook:[self.fetchedResultsController objectAtIndexPath:_selectedPath]];
    }
}

@end
