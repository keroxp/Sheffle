//
//  SFBooksViewController.h
//  Sheffle
//
//  Created by 桜井雄介 on 2012/11/08.
//  Copyright (c) 2012年 Kaeru Lab. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

typedef enum{
    SFBookSortTypeTitle = 0,
    SFBookSortTypeAuthor,
    SFBookSortTypePublisher
}SFBookSortType;

@interface SFBooksViewController : UITableViewController
<NSFetchedResultsControllerDelegate
,UISearchBarDelegate
,UISearchDisplayDelegate>

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (assign, nonatomic) SFBookSortType sortType;
@property (weak, nonatomic) IBOutlet UISegmentedControl *sortControl;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *addButton;
- (IBAction)sortControlDidChange:(UISegmentedControl*)sender;
- (IBAction)addButtonDidTap:(id)sender;

@end
