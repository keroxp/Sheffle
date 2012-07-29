//
//  SFBookViewController.m
//  Sheffle
//
//  Created by 桜井 雄介 on 2012/07/30.
//  Copyright (c) 2012年 Kaeru Lab. All rights reserved.
//

#import "SFBookViewController.h"

@interface SFBookViewController ()

@end

@implementation SFBookViewController

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
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    [self setTitle:[_book title]];
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

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    switch (section) {
        case 0:
            return 5;
            break;
        case 1:
            return 13;
        default:
            break;
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case 0:
            switch (indexPath.row) {
                case 3:
                    return 100.0f;
                    break;
                case 4:
                    return 200.0f;
                default:
                    break;
            }
            break;
        default:
            break;
    }
    return [tableView rowHeight];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return @"Internal";
            break;
        case 1:
            return @"Rakuten";
        default:
            break;
    }
    return @"undefined";
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"BookCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    // Configure the cell...
    
    switch (indexPath.section) {
        case 0: {
            switch (indexPath.row) {
                case 0:
                    [[cell textLabel] setText:@"identifier"];
                    [[cell detailTextLabel] setText:[_book identifier]];
                    break;
                case 1:
                    [[cell textLabel] setText:@"updated"];
                    [[cell detailTextLabel] setText:[_book.updated description]];
                    break;
                case 2:
                    [[cell textLabel] setText:@"created"];
                    [[cell detailTextLabel] setText:[_book.created description]];
                    break;
                case 3: {
                    UIImage *image = [UIImage imageWithData:[_book image]];
                    [[cell imageView] setImage:image];
                }
                    break;
                case 4: {
                    UIImage *image = [UIImage imageWithData:[_book image2x]];
                    [[cell imageView] setImage:image];
                }
                    break;
                default:
                    break;
            }
            break;
        }
        case 1:
            switch (indexPath.row) {
                case 0:
                    cell.textLabel.text = @"author";
                    cell.detailTextLabel.text = _book.author;
                    break;
                case 1:
                    cell.textLabel.text = @"authr kana";
                    cell.detailTextLabel.text = _book.authorKana;
                    break;
                case 2:
                    cell.textLabel.text = @"title";
                    cell.detailTextLabel.text = _book.title;
                    break;
                case 3:
                    cell.textLabel.text = @"title kana";
                    cell.detailTextLabel.text = _book.titleKana;
                    break;
                case 4:
                    cell.textLabel.text = @"series";
                    cell.detailTextLabel.text = _book.seriesName;
                    break;
                case 5:
                    cell.textLabel.text = @"series kana";
                    cell.detailTextLabel.text = _book.seriesNameKana;
                    break;
                case 6:
                    cell.textLabel.text = @"isbn";
                    cell.detailTextLabel.text = _book.isbn;
                    break;
                case 7:
                    cell.textLabel.text = @"item caption";
                    cell.detailTextLabel.text = _book.itemCaption;
                    break;
                case 8:
                    cell.textLabel.text = @"item price";
                    cell.detailTextLabel.text = [NSString stringWithFormat:@"%i",_book.itemPrice];
                    break;
                case 9:
                    cell.textLabel.text = @"item url";
                    cell.detailTextLabel.text = _book.itemUrl;
                    break;
                case 10:
                    cell.textLabel.text = @"publisher name";
                    cell.detailTextLabel.text = _book.publisherName;
                    break;
                case 11:
                    cell.textLabel.text = @"sales data";
                    cell.detailTextLabel.text = _book.salesDate.description;
                    break;
                case 12:
                    cell.textLabel.text = @"book size";
                    cell.detailTextLabel.text = _book.bookSize;
                    break;
                default:
                    break;
            }
        default:
            break;
    }    
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

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

@end
