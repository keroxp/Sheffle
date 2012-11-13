//
//  SFAppDelegate.m
//  Sheffle
//
//  Created by 桜井 雄介 on 12/07/20.
//  Copyright (c) 2012年 Kaeru Lab. All rights reserved.
//

#import "SFAppDelegate.h"
#import "SFCoreDataManager.h"

@implementation SFAppDelegate

@synthesize window = _window;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    
    [[UISegmentedControl appearance] setTintColor:kBarTintColor];
    [[UIBarButtonItem appearanceWhenContainedIn:[UINavigationBar class], nil] setTintColor:kBarTintColor];
    [[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:@"barbg.png"] forBarMetrics:UIBarMetricsDefault];
    [[UINavigationBar appearance] setShadowImage:[UIImage imageNamed:@"navbarshadow.png"]];

    // 未登録の本棚
    if (![[SFCoreDataManager sharedManager] hasDataOfEntityName:@"Shelf" withIDKey:@"identifier" forIDValue:kDefaultShelfIdentifier]){        
        SFShelf *shelf = [[SFCoreDataManager sharedManager] insertNewShelf];
        [shelf setIdentifier:kDefaultShelfIdentifier];        
        [shelf setTitle:@"未登録の本棚"];
        [shelf setIndex:@(kDefaultShelfIndex)];
        [[SFCoreDataManager sharedManager] saveContext];
    }
    
    // お気に入りの本棚
    if (![[SFCoreDataManager sharedManager] hasDataOfEntityName:@"Shelf" withIDKey:@"identifier" forIDValue:kFavoriteShelfIdentifier]){
        SFShelf *shelf = [[SFCoreDataManager sharedManager] insertNewShelf];
        [shelf setIdentifier:kFavoriteShelfIdentifier];
        [shelf setTitle:@"お気に入り"];
        [shelf setIndex:@(kFavoriteShelfIndex)];
        [[SFCoreDataManager sharedManager] saveContext];
    }
        
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
