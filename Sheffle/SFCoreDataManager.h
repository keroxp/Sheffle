//
//  SFCoreDataController.h
//  Sheffle
//
//  Created by 桜井 雄介 on 12/07/26.
//  Copyright (c) 2012年 Kaeru Lab. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

#import "SFBook.h"
#import "SFShelf.h"

@interface SFCoreDataManager : NSObject

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSFetchedResultsController *fetchedResultController;

+ (id)sharedManager;

- (SFShelf*)insertNewShelf;
- (SFBook*)insertNewBook;

- (NSArray*)sortedShelves;

- (void)saveContext;
- (NSURL*)applicationDocumentsDirectory;

@end