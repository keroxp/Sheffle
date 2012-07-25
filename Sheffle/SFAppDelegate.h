//
//  SFAppDelegate.h
//  Sheffle
//
//  Created by 桜井 雄介 on 12/07/20.
//  Copyright (c) 2012年 Kaeru Lab. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "SFShelfViewController.h"
#import "SFCoreDataController.h"

@interface SFAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) SFCoreDataController *coreDataController;

@end
