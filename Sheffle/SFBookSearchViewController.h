//
//  SFBookSearchViewController.h
//  Sheffle
//
//  Created by 桜井雄介 on 2012/11/11.
//  Copyright (c) 2012年 Kaeru Lab. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KXPPickerViewController.h"

@interface SFBookSearchViewController : UITableViewController
<UISearchBarDelegate,UISearchDisplayDelegate,UIPickerViewDelegate,UIPickerViewDataSource,KXPPickerViewControllerDelegate>

@property (nonatomic,strong) NSArray *shelves;

- (IBAction)cancelButtonDidTap:(UIBarButtonItem *)sender;
- (IBAction)doneButtonDidTap:(id)sender;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *doneButton;

@end
