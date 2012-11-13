//
//  UIViewController+AddBook.m
//  Sheffle
//
//  Created by 桜井 雄介 on 2012/11/13.
//  Copyright (c) 2012年 Kaeru Lab. All rights reserved.
//

#import "UIViewController+AddBook.h"
#import "SFBookSearchViewController.h"
#import "SFCoreDataManager.h"
#import "SFAPIConnection.h"
#import "SVProgressHUD.h"
#import "SFRakutenBook.h"

#define kDefaultShelfViewFrame CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)
#define kDefaultReaderViewFrame CGRectMake(0, 0, self.view.frame.size.width, 0)
#define kScanModeShelfViewFrame CGRectMake(0, 100.0f, self.view.frame.size.width, self.view.frame.size.height - 100.0f)
#define kScanModeReaderViewFrame CGRectMake(0, 0, self.view.frame.size.width, 100.0f)

@implementation UIViewController (AddBook)

- (void)startAddBookMode
{
    UIActionSheet *as = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"バーコードをスキャン",@"キーワードから検索", nil];
    [as showFromTabBar:self.tabBarController.tabBar];
}

#pragma mark - Action Sheet

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 0:
            // バーコード
            [self startReaderView];
            break;
        case 1: {
            // 文字検索
            SFBookSearchViewController *svc = [self.storyboard instantiateViewControllerWithIdentifier:@"BookSearchView"];
            svc.delegate = self;
            svc.shelves = [[SFCoreDataManager sharedManager] shelves];
            UINavigationController *nvc = [[UINavigationController alloc] initWithRootViewController:svc];
            [self presentViewController:nvc animated:YES completion:NULL];
            break;
        }
        case 2:
            break;
        default:
            break;
    }
}

#pragma mark - Reader View

- (void)readerView:(ZBarReaderView *)readerView didReadSymbols:(ZBarSymbolSet *)symbols fromImage:(UIImage *)image
{
    [readerView stop];

    for(ZBarSymbol *symbol in symbols) {
        
        NSString *resultText = [symbol data];
        
        SFAPIConnection *c = [SFAPIConnection connectionWithRequestType:SFAPIRequestTypeBooksBookSearch patameters:@{@"isbn" : resultText}];
        
        // ぐるぐるを表示
        [SVProgressHUD showWithStatus:@"Loading"];
        [self.view setUserInteractionEnabled:NO];
   
        // 成功時および失敗時のハンドラをセット
        [c setCompletionHandler:^(NSHTTPURLResponse *responseHeader, NSDictionary *JSON){
            //        $(@"Reponse is : %@",responseHeader);
            //        $(@"body is %@",responseString);
            if ([JSON objectForKey:@"Body"] != nil && [JSON objectForKey:@"Body"] != [NSNull null]) {
                // 成功時
                JSON = [[[[[JSON objectForKey:@"Body"] objectForKey:@"BooksBookSearch"] objectForKey:@"Items"] objectForKey:@"Item"] objectAtIndex:0];
                [SVProgressHUD dismissWithSuccess:[JSON objectForKey:@"title"] afterDelay:1.5f];
                SFRakutenBook *book = [[SFRakutenBook alloc] initWithJSON:JSON];
                if ([self respondsToSelector:@selector(addBookViewController:didFinishLoadBook:)]) {
                    [self addBookViewController:self didFinishLoadBook:book];
                }
            }else{
                // 失敗時
                $(@"data might not be found");
                [SVProgressHUD dismissWithError:@"Product not found" afterDelay:2.0f];
            };
            [[self view] setUserInteractionEnabled:YES];
            for (UIBarButtonItem*b in self.navigationItem.rightBarButtonItems) {
                [b setEnabled:YES];
            }
            [readerView start];
        }];
        [c setFailedHandler:^(NSError *error){
            [SVProgressHUD dismissWithError:@"Error happend" afterDelay:2.0f];
//            $(@"error happend : %@",error);
            [readerView start];
        }];
        
        // リクエストをスタート
        [c  startAPIConnection];
    }
}

- (void)finishAddBookMode
{
    [self finishReaderView];
}

#pragma mark - Book Search 

- (void)bookSearchViewController:(UIViewController *)controller didCommitRegisteringForShelf:(SFShelf *)shelf books:(NSArray *)books
{
    if ([self respondsToSelector:@selector(addBookViewController:didCommitRegisteringForShelf:books:)]){
        [self addBookViewController:self didCommitRegisteringForShelf:shelf books:books];
    }
}

#pragma mark - Private

- (void)startReaderView
{
    ZBarReaderView *readerView = (ZBarReaderView*)[self.view viewWithTag:1001];
    
    if (!readerView) {
        // Reader Viewの初期化
        ZBarImageScanner *scanner = [[ZBarImageScanner alloc] init];
        [scanner setSymbology: ZBAR_I25 config: ZBAR_CFG_ENABLE to: 0];
        ZBarReaderView *readerView = [[ZBarReaderView alloc] initWithImageScanner:scanner];
        readerView.frame = kDefaultReaderViewFrame;
        readerView.readerDelegate = self;
        readerView.tag = 1001;
        [self.view addSubview:readerView];
    }
    
    [readerView start];

    [UIView animateWithDuration:0.25f delay:0.0 options:(UIViewAnimationCurveEaseIn <<  16) animations:^(void){
        readerView.frame = kScanModeReaderViewFrame;
        self.viewToBeResized.frame = kScanModeShelfViewFrame;
    }completion:^(BOOL finished){
        if ([self respondsToSelector:@selector(addBookViewController:willBeginReading:)]) {
            [self addBookViewController:self willBeginReading:readerView];
        }
    }];
}

- (void)finishReaderView
{
    ZBarReaderView *readerView = (ZBarReaderView*)[self.view viewWithTag:1001];
    [readerView stop];
    [UIView animateWithDuration:0.25f delay:0.0 options:(UIViewAnimationCurveEaseIn <<  16) animations:^(void){
        readerView.frame = kDefaultReaderViewFrame;
        self.viewToBeResized.frame = kDefaultShelfViewFrame;
    }completion:^(BOOL finished){
        if ([self respondsToSelector:@selector(addBookViewController:willEndReading:)]) {
            [self addBookViewController:self willEndReading:readerView];
        }
    }];
}

@end
