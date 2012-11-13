//
//  SFBookSearchViewController.h
//  Sheffle
//
//  Created by 桜井雄介 on 2012/11/11.
//  Copyright (c) 2012年 Kaeru Lab. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KXPPickerViewController.h"

@class SFShelf;
@protocol SFBookSearchViewDelegate;

@interface SFBookSearchViewController : UITableViewController
<UISearchBarDelegate,UISearchDisplayDelegate,UIPickerViewDelegate,UIPickerViewDataSource,KXPPickerViewControllerDelegate>

@property (nonatomic,strong) NSArray *shelves;
@property (weak,nonatomic) id<SFBookSearchViewDelegate> delegate;

- (IBAction)cancelButtonDidTap:(UIBarButtonItem *)sender;
- (IBAction)doneButtonDidTap:(id)sender;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *doneButton;

@end

@protocol SFBookSearchViewDelegate <NSObject>

- (void)bookSearchViewController:(UIViewController*)controller didCommitRegisteringForShelf:(SFShelf*)shelf books:(NSArray*)books;

@end