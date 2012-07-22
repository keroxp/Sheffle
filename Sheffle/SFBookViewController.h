//
//  SFBookViewController.h
//  Sheffle
//
//  Created by 桜井 雄介 on 12/07/22.
//  Copyright (c) 2012年 Kaeru Lab. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface SFBookViewController : UIViewController

@property(strong,nonatomic) NSManagedObjectContext *managedObjectContext;

@end
