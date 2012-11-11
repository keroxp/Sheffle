//
//  SFBookSearchViewController.h
//  Sheffle
//
//  Created by 桜井雄介 on 2012/11/11.
//  Copyright (c) 2012年 Kaeru Lab. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SFBookSearchViewController : UITableViewController
<UISearchBarDelegate,UISearchDisplayDelegate>

- (IBAction)cancelButtonDidTap:(UIBarButtonItem *)sender;

@end
