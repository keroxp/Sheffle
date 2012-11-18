//
//  SFAppDelegate.m
//  Sheffle
//
//  Created by 桜井 雄介 on 12/07/20.
//  Copyright (c) 2012年 Kaeru Lab. All rights reserved.
//

#import "SFAppDelegate.h"
#import "SFCoreDataManager.h"
#import "SFShelfViewController.h"
#import "SFNavigationBar.h"
#import "SFToolbar.h"


@implementation SFAppDelegate

@synthesize window = _window;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    
    [[UISegmentedControl appearanceWhenContainedIn:[SFNavigationBar class], nil ] setTintColor:kBarTintColor];
    [[UISegmentedControl appearanceWhenContainedIn:[SFToolbar class], nil] setTintColor:kBarTintColor];
    [[UIBarButtonItem appearanceWhenContainedIn:[SFToolbar class], nil] setTintColor:kBarTintColor];
    [[UIBarButtonItem appearanceWhenContainedIn:[SFNavigationBar class], nil] setTintColor:kBarTintColor];
    
    // キャッシュを削除
    [NSFetchedResultsController deleteCacheWithName:@"BooksWithTitle"];
    [NSFetchedResultsController deleteCacheWithName:@"BooksWithAuthor"];
    [NSFetchedResultsController deleteCacheWithName:@"BooksWithPublisher"];
    
    // プリキャッシュ
    [[SFCoreDataManager sharedManager] fetchedShelvesController];
    [[SFCoreDataManager sharedManager] fetchedBooksController];
    [[SFCoreDataManager sharedManager] fetchedFavoriteBooksController];
    
    // OS Verion
    NSArray *versionArray = [ [ [ UIDevice currentDevice]systemVersion]componentsSeparatedByString:@"."];
    int majorVersion = [ [ versionArray objectAtIndex:0]intValue];
    int minorVersion = [ [ versionArray objectAtIndex:1]intValue];
    $(@"VERSION %d.%d",majorVersion,minorVersion);
    _iOSVersionMajor = majorVersion;
    _iOSVersionMinor = minorVersion;
    
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
