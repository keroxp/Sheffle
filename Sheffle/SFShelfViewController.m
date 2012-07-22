//
//  SFShelfViewController.m
//  Sheffle
//
//  Created by 桜井 雄介 on 12/07/22.
//  Copyright (c) 2012年 Kaeru Lab. All rights reserved.
//

#import "SFShelfViewController.h"
#define kRakutenAPPID @"1058212220451425377"

@interface SFShelfViewController ()
{
    
}

@end

@implementation SFShelfViewController

@synthesize managedObjectContext = __managedObjectContext;
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
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
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
    static NSString *CellID = @"ShlefCell";
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

#pragma mark - Fetched results controller

- (NSFetchedResultsController *)fetchedResultsController
{
    if (__fetchedResultsController != nil) {
        return __fetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Shelf" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    
    // Edit the sort key as appropriate.
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"updated" ascending:NO];
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

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    NSManagedObject *object = [self.fetchedResultsController objectAtIndexPath:indexPath];
    //    cell.textLabel.text = [[object valueForKey:@"timeStamp"] description];
    [cell.textLabel setText:[[object valueForKey:@"title"] description]];
}

- (IBAction)addButtonDidTap:(id)sender {
    // ADD: present a barcode reader that scans from the camera feed
    ZBarReaderViewController *reader = [ZBarReaderViewController new];
    reader.readerDelegate = self;
    reader.supportedOrientationsMask = ZBarOrientationMaskAll;
    
    ZBarImageScanner *scanner = [[ZBarImageScanner alloc] init];
//    ZBarImageScanner *scanner = reader.scanner;
    // TODO: (optional) additional reader configuration here
    
    // EXAMPLE: disable rarely used I2/5 to improve performance
    [scanner setSymbology: ZBAR_I25
                   config: ZBAR_CFG_ENABLE
                       to: 0];

    ZBarReaderView *readerView = [[ZBarReaderView alloc] initWithImageScanner:scanner];
    [readerView setFrame:CGRectMake(0, 0, self.view.frame.size.width, 100.0f)];
    [readerView setReaderDelegate:self];
    [readerView start];
    [self.tableView setTableHeaderView:readerView];

    
    // present and release the controller
//    [self presentModalViewController: reader animated: YES];
}

- (void)readerView:(ZBarReaderView *)readerView didReadSymbols:(ZBarSymbolSet *)symbols fromImage:(UIImage *)image
{
    for(ZBarSymbol *symbol in symbols) {
        
        NSString *resultText = symbol.data;        
        UIImage *resultImage = image;
    
        // 楽天ブックス総合検索APIのURL
    
        NSMutableString *apiURIString = [NSMutableString stringWithString:@"http://api.rakuten.co.jp/rws/3.0/json?"];
        [apiURIString appendFormat:@"developerId=%@&",kRakutenAPPID];
        [apiURIString appendString:@"operation=BooksTotalSearch&"];
        [apiURIString appendString:@"version=2011-12-01&"];
        [apiURIString appendFormat:@"isbnjan=%@",resultText];
        
        // HTTPRequestを構築
        R9HTTPRequest *req = [[R9HTTPRequest alloc] initWithURL:[NSURL URLWithString:[apiURIString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
        
        // ぐるぐるを表示
        [SVProgressHUD showWithStatus:@"Loading"];
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        
        NSLog(@"url is %@",apiURIString);
        [req setCompletionHandler:^(NSHTTPURLResponse *responseHeader, NSString *responseString){
            //        NSLog(@"Reponse is : %@",responseHeader);
            //        NSLog(@"body is %@",responseString);
            NSDictionary *JSON = [NSDictionary dictionary];
            @try {
                JSON = [[[[[[responseString JSONValue] objectForKey:@"Body"] objectForKey:@"BooksTotalSearch"] objectForKey:@"Items"] objectForKey:@"Item"] objectAtIndex:0];
            }
            @catch (NSException *exception) {
                NSLog(@"data not found : %@",responseString);            
            }
            @finally {
                
            }        
//            NSLog(@"data are %@", JSON);
            [SVProgressHUD dismissWithSuccess:[JSON objectForKey:@"title"] afterDelay:3.0f];
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        }];
        [req setFailedHandler:^(NSError *error){
            [SVProgressHUD dismissWithError:@"Error happed" afterDelay:3.0f];
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
            NSLog(@"error happend : %@",error);
        }];
        [req startRequest];
    }
}

- (void) imagePickerController: (UIImagePickerController*) reader didFinishPickingMediaWithInfo: (NSDictionary*) info
{
    // ADD: get the decode results
    id<NSFastEnumeration> results =[info objectForKey: ZBarReaderControllerResults];
    ZBarSymbol *symbol = nil;
    for(symbol in results)
        // EXAMPLE: just grab the first barcode
        break;
    
    // EXAMPLE: do something useful with the barcode data
    NSString *resultText = symbol.data;
    
    // EXAMPLE: do something useful with the barcode image

    UIImage *resultImage = [info objectForKey: UIImagePickerControllerOriginalImage];
    
    // 楽天ブックス総合検索APIに接続
    
    NSMutableString *apiURIString = [NSMutableString stringWithString:@"http://api.rakuten.co.jp/rws/3.0/json?"];
    [apiURIString appendFormat:@"developerId=%@&",kRakutenAPPID];
    [apiURIString appendString:@"operation=BooksTotalSearch&"];
    [apiURIString appendString:@"version=2011-12-01&"];
    [apiURIString appendFormat:@"isbnjan=%@",resultText];
    
    R9HTTPRequest *req = [[R9HTTPRequest alloc] initWithURL:[NSURL URLWithString:[apiURIString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
    [SVProgressHUD showWithStatus:@"Loading"];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    NSLog(@"url is %@",apiURIString);
    [req setCompletionHandler:^(NSHTTPURLResponse *responseHeader, NSString *responseString){
//        NSLog(@"Reponse is : %@",responseHeader);
//        NSLog(@"body is %@",responseString);
        NSDictionary *JSON = [NSDictionary dictionary];
        @try {
            JSON = [[[[[[responseString JSONValue] objectForKey:@"Body"] objectForKey:@"BooksTotalSearch"] objectForKey:@"Items"] objectForKey:@"Item"] objectAtIndex:0];
        }
        @catch (NSException *exception) {
            NSLog(@"data not found : %@",responseString);            
        }
        @finally {

        }        
        NSLog(@"data are %@", JSON);
        [SVProgressHUD dismiss];
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    }];
    [req setFailedHandler:^(NSError *error){
        [SVProgressHUD dismissWithError:@"Error happed" afterDelay:3.0f];
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        NSLog(@"error happend : %@",error);
    }];
    [req startRequest];
    
    // ADD: dismiss the controller (NB dismiss from the *reader*!)
    [reader dismissModalViewControllerAnimated: YES];
}

@end
