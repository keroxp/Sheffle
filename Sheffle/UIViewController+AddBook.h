//
//  UIViewController+AddBook.h
//  Sheffle
//
//  Created by 桜井 雄介 on 2012/11/13.
//  Copyright (c) 2012年 Kaeru Lab. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZBarSDK.h"
#import "SFBookSearchViewController.h"

@class SFShelf, SFRakutenBook;

@interface UIViewController (AddBook)
<UIActionSheetDelegate,ZBarReaderViewDelegate,SFBookSearchViewDelegate>

- (void)startAddBookMode;
- (void)finishAddBookMode;

@end

@interface UIViewController (AddBookDataSource)

- (UIView*)viewToBeResized;

@end

@interface UIViewController (AddBookDelegate)

- (void)addBookViewController:(UIViewController*)controller didLoadSynmols:(ZBarSymbolSet *)symbols;
- (void)addBookViewController:(UIViewController*)controller didFinishLoadBook:(SFRakutenBook*)book;
- (void)addBookViewController:(UIViewController*)controller willBeginReading:(ZBarReaderView*)readerView;
- (void)addBookViewController:(UIViewController*)controller willEndReading:(ZBarReaderView*)readerView;
- (void)addBookViewController:(UIViewController*)controller didCommitRegistering:(UIBarButtonItem*)sender withBooks:(NSArray*)books;
- (void)addBookViewController:(UIViewController*)controller didCommitRegisteringForShelf:(SFShelf*)shelf books:(NSArray*)books;

@end
