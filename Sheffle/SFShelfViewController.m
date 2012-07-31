//
//  SFShelfViewController.m
//  Sheffle
//
//  Created by 桜井 雄介 on 12/07/22.
//  Copyright (c) 2012年 Kaeru Lab. All rights reserved.
//

#import "SFShelfViewController.h"

#define kRakutenAPPID @"1058212220451425377"
#define kBarTintColor [UIColor colorWithRed:214.0f/255.0f green:168.0f/255.0f blue:91.0f/255.0f alpha:1.0f]
#define kDefaultShelfViewFrame CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)
#define kDefaultReaderViewFrame CGRectMake(0, 0, self.view.frame.size.width, 0)
#define kScanModeShelfViewFrame CGRectMake(0, 100.0f, self.view.frame.size.width, self.view.frame.size.height - 100.0f)
#define kScanModeReaderViewFrame CGRectMake(0, 0, self.view.frame.size.width, 100.0f)

@interface SFShelfViewController ()
{
    UIBarButtonItem *_donebutton;
    UIBarButtonItem *_scanButton;
    UIBarButtonItem *_addButton;
    UIBarButtonItem *_segmentedControlItem;
    UISegmentedControl *_segmentedControl;
    SFShelf *_currentShelf;
    ZBarReaderView *_readerView;
    SFShelfViewMode _shelfViewMode;
}

- (void)titleDidTap:(id)sender;
- (void)scanButtonDidTap:(id)sender;
- (void)doneButtonDidTap:(id)sender;
- (void)addButtonDidTap:(id)sender;
- (void)segmentedControlDidChange:(UISegmentedControl*)sender;
- (void)insertNewObject:(NSDictionary*)book image:(UIImage*)image;
- (UIImage*)resizeImage:(UIImage*)image;

@end

@implementation SFShelfViewController

//@synthesize readerView = _readerView;
//@synthesize shelfView = _shelfView;
//@synthesize tableShelfViewController = _tableShelfViewController;
//@synthesize gridShelfViewController = _gridShelfViewController;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Reader Viewの初期化

    
    // ZbarImageViewを構築
    ZBarImageScanner *scanner = [[ZBarImageScanner alloc] init];
    [scanner setSymbology: ZBAR_I25 config: ZBAR_CFG_ENABLE to: 0];
    _readerView = [[ZBarReaderView alloc] initWithImageScanner:scanner];
    [_readerView setFrame:kDefaultReaderViewFrame];
    [_readerView setReaderDelegate:self];
    [[self view] addSubview:_readerView];
        
    // Shelf Viewの初期化
    
    // ２種類のShelfViewControllerを構築
    _tableShelfViewController = [[SFTableShelfViewController alloc] initWithStyle:UITableViewStylePlain];
    _gridShelfViewController = [[SFGridShelfViewController alloc] init];
    
    [[_tableShelfViewController view] setFrame:kDefaultShelfViewFrame];
    [[_gridShelfViewController view] setFrame:kDefaultShelfViewFrame];
    [_tableShelfViewController didMoveToParentViewController:self];
    
    [self addChildViewController:_tableShelfViewController];
    [self addChildViewController:_gridShelfViewController];
    

    [_shelfView setFrame:kDefaultShelfViewFrame];
    _shelfView = [_tableShelfViewController view];
//    _shelfView = [_gridShelfViewController view];
    [[self navigationItem] setLeftBarButtonItem:[_tableShelfViewController editButtonItem]];
    [[self view] addSubview:_shelfView];
    
    _shelfViewMode = SFShelfViewModeGrid;
    
    // NavigationBarを初期化
    
//    [self setTitle:@"Shelves"];
    
    UIButton *titleButton = [UIButton buttonWithType:UIButtonTypeCustom];
//    [titleButton setTintColor:kBarTintColor];
    [titleButton setTitle:@"Shelf" forState:UIControlStateNormal];
    [[titleButton titleLabel] setFont:[UIFont boldSystemFontOfSize:20.0f]];
    [titleButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [titleButton setFrame:CGRectMake(0, 0, 130, 33)];
    [titleButton addTarget:self action:@selector(titleDidTap:) forControlEvents:UIControlEventTouchUpInside];
    
    [[self navigationItem] setTitleView:titleButton];
    
    _scanButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCamera target:self action:@selector(scanButtonDidTap:)];
    [_scanButton setTintColor:kBarTintColor];
    _donebutton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneButtonDidTap:)];    
    [_donebutton setTintColor:kBarTintColor];
    
    [[self editButtonItem] setTintColor:kBarTintColor];
    [[self navigationItem] setRightBarButtonItem:_scanButton];
    
    // Toolbarを初期化
    
    _segmentedControl = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:@"Title",@"Author",@"Date",@"Stared", nil]];
    [_segmentedControl setSelectedSegmentIndex:0];
    [_segmentedControl setSegmentedControlStyle:UISegmentedControlStyleBar];
    [_segmentedControl setTintColor:kBarTintColor];
    [_segmentedControl addTarget:self action:@selector(segmentedControlDidChange:) forControlEvents:UIControlEventValueChanged];
    _segmentedControlItem = [[UIBarButtonItem alloc] initWithCustomView:_segmentedControl];
    
    _addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addButtonDidTap:)];
    [_addButton setTintColor:kBarTintColor];
    
    [self setToolbarItems:[NSArray arrayWithObjects:_segmentedControlItem,_addButton, nil]];

    
//    [self.view setFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    
    
    // Viewの初期化
    CALayer *topShadowLayer = [CALayer layer];
    topShadowLayer.frame = self.view.bounds;
    [self.view.layer addSublayer:topShadowLayer];
    topShadowLayer.masksToBounds = YES;
    CGRect shadowFrame = CGRectMake(-10.0, -10.0, topShadowLayer.bounds.size.width+10.0, 10.0);
    UIBezierPath *path = [UIBezierPath bezierPathWithRect:shadowFrame];                          
    topShadowLayer.shadowOffset = CGSizeMake(0, 2.5); 
    topShadowLayer.shadowColor = [[UIColor blackColor] CGColor];
    topShadowLayer.shadowOpacity = 0.5;
    topShadowLayer.shadowPath = [path CGPath];
    
    CALayer *bottomShadowLayer = [CALayer layer];
    [bottomShadowLayer setFrame:self.view.bounds];
    [self.view.layer addSublayer:bottomShadowLayer];
    [bottomShadowLayer setMasksToBounds:YES];
    CGRect dpsFrame = CGRectMake(-10.0, self.view.bounds.size.height + 10.0, bottomShadowLayer.bounds.size.width+10.0, 10.0);
    UIBezierPath *dpsPath = [UIBezierPath bezierPathWithRect:dpsFrame];
    [bottomShadowLayer setShadowOffset:CGSizeMake(0, 2.5)];
    [bottomShadowLayer setShadowColor:[[UIColor blackColor] CGColor]];
    [bottomShadowLayer setShadowOpacity:0.75];
    [bottomShadowLayer setShadowPath:[dpsPath CGPath]];
    
    
//    NSLog(@"%@", [_gridShelfViewController view]);
//    NSLog(@"%@", [_gridShelfViewController bookShelfView]);
//    NSLog(@"%@",_tableShelfViewController.view);

}

- (void)viewDidUnload
{
    [self setReaderView:nil];
    [self setShelfView:nil];
    _readerView = nil;
    _scanButton = nil;
    _donebutton = nil;
    _segmentedControl = nil;
    _segmentedControlItem = nil;
    _addButton = nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)insertNewObject:(NSDictionary *)book image:(UIImage *)image
{
    SFBook *newBook = [[SFCoreDataManager sharedManager] insertNewBook];
    
    if ([newBook identifier]) {
        // 内部情報をセット
        [newBook setCreated:[NSDate date]];
        [newBook setUpdated:[NSDate date]];
        [newBook setImage2x:UIImagePNGRepresentation(image)];
        [newBook setImage:UIImagePNGRepresentation([self resizeImage:image])];
        [newBook setShelf:_currentShelf];
        
        [newBook setAuthor:[book objectForKey:@"author"]];
        [newBook setAuthorKana:[book objectForKey:@"authorKana"]];
        [newBook setTitle:[book objectForKey:@"title"]];
        [newBook setTitleKana:[book objectForKey:@"titleKana"]];
        [newBook setSeriesName:[book objectForKey:@"seriesName"]];
        [newBook setSeriesNameKana:[book objectForKey:@"seriesNameKana"]];
        [newBook setIsbn:[book objectForKey:@"isbn"]];
        [newBook setItemCaption:[book objectForKey:@"itemCaption"]];
        [newBook setItemPrice:[[book objectForKey:@"itemPrice"] intValue]];
        [newBook setItemUrl:[book objectForKey:@"itemUrl"]];
        
        NSDateFormatter *dfm = [[NSDateFormatter alloc] init];
        [dfm setDateFormat:@"yyyy年MM月"];
        [newBook setSalesDate:[dfm dateFromString:[book objectForKey:@"salesDate"]]];
        [newBook setBookSize:[book objectForKey:@"size"]];
        
        [_currentShelf addBooks:[NSSet setWithObject:newBook]];
    }    
    [[SFCoreDataManager sharedManager] saveContext];
}

- (UIImage *)resizeImage:(UIImage *)image
{
    // サムネイル用の処理
    CGSize resized = CGSizeMake(image.size.width/2, image.size.height);
    UIGraphicsBeginImageContextWithOptions(resized, NO, 0.0);
    CGRect itemRect = CGRectMake(0.0, 0.0, resized.width, resized.height);
    [image drawInRect:itemRect];
    UIImage *resizedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return resizedImage;
}


#pragma mark - ZBarReaderView

- (void)readerView:(ZBarReaderView *)readerView didReadSymbols:(ZBarSymbolSet *)symbols fromImage:(UIImage *)image
{

    [_readerView stop];
    
    for(ZBarSymbol *symbol in symbols) {
        
        NSString *resultText = [symbol data];
        
        // 楽天ブックス総合検索APIのURL
        
        NSMutableString *apiURIString = [NSMutableString stringWithString:@"http://api.rakuten.co.jp/rws/3.0/json?"];
        [apiURIString appendFormat:@"developerId=%@&",kRakutenAPPID];
        //　2012/07/30 総合検索から書籍検索へ切り替えた
        [apiURIString appendString:@"operation=BooksBookSearch&"];
        [apiURIString appendString:@"version=2011-12-01&"];
        [apiURIString appendFormat:@"isbn=%@",resultText];
//        NSLog(@"url is %@",apiURIString);
        
        // HTTPRequestを構築
        R9HTTPRequest *req = [[R9HTTPRequest alloc] initWithURL:[NSURL URLWithString:[apiURIString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
        
        // ぐるぐるを表示
        [SVProgressHUD showWithStatus:@"Loading"];
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        [[self view] setUserInteractionEnabled:NO];
        
        // 成功時および失敗時のハンドラをセット
        [req setCompletionHandler:^(NSHTTPURLResponse *responseHeader, NSString *responseString){
            //        NSLog(@"Reponse is : %@",responseHeader);
            //        NSLog(@"body is %@",responseString);
            NSDictionary *JSON = [NSDictionary dictionary];
            @try {
                JSON = [[[[[[responseString JSONValue] objectForKey:@"Body"] objectForKey:@"BooksBookSearch"] objectForKey:@"Items"] objectForKey:@"Item"] objectAtIndex:0];
                NSError *error = nil;
                NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:[JSON objectForKey:@"largeImageUrl"]] options:NSDataReadingUncached error: &error];
                UIImage *cover = [UIImage imageWithData:data];
                if (error) {
                    NSLog(@"Error : %@", error);
                }
                [self insertNewObject:JSON image:cover];
                [SVProgressHUD dismissWithSuccess:[JSON objectForKey:@"title"] afterDelay:3.0f];
            }
            @catch (NSException *exception) {
                NSLog(@"exception:%@",exception);
                NSLog(@"data not found : %@",responseString);
                [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
                [SVProgressHUD dismissWithError:@"Product not found" afterDelay:3.0f];
            }
            @finally {
                [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
                [[self view] setUserInteractionEnabled:YES];
                [_readerView start];
            }                      
        }];
        [req setFailedHandler:^(NSError *error){
            [SVProgressHUD dismissWithError:@"Error happed" afterDelay:3.0f];
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
            NSLog(@"error happend : %@",error);
            [_readerView start];
        }];
        
        // リクエストをスタート
        [req startRequest];
    }
}

#pragma mark - Event Handler

- (void)titleDidTap:(id)sender
{
    NSLog(@"title did tap");
}

- (void)scanButtonDidTap:(id)sender 
{
    [_readerView start];
    switch (_shelfViewMode) {
        case SFShelfViewModeTable:
            [[_tableShelfViewController tableView] setContentOffset:CGPointZero];
            break;
        case SFShelfViewModeGrid:
            [[_gridShelfViewController bookShelfView] setContentOffset:CGPointZero];
        default:
            break;
    }
    [UIView animateWithDuration:0.25f delay:0.0 options:(UIViewAnimationCurveEaseIn <<  16) animations:^(void){
        _readerView.frame = kScanModeReaderViewFrame;
        _shelfView.frame = kScanModeShelfViewFrame;
    }completion:^(BOOL finished){
        [self.navigationItem setRightBarButtonItem:_donebutton];
        [self setTitle:@"Scan Barcode"];
    }];

}

- (void)doneButtonDidTap:(id)sender
{
    [_readerView stop];
    [UIView animateWithDuration:0.25f delay:0.0 options:(UIViewAnimationCurveEaseIn <<  16) animations:^(void){
        _readerView.frame = kDefaultReaderViewFrame;
        _shelfView.frame = kDefaultShelfViewFrame;
    }completion:^(BOOL finished){
        [self.navigationItem setRightBarButtonItem:_scanButton];
        [self setTitle:@"Shelf"];
    }];
}

- (void)addButtonDidTap:(id)sender {
    NSLog(@"add button did tap");
}

- (void)segmentedControlDidChange:(UISegmentedControl *)sender
{
    NSLog(@"segmented control did change index : %i",[_segmentedControl selectedSegmentIndex]);
}
@end
