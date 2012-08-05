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
#import "SFShelf+SortedBooks.h"

@interface SFCoreDataManager : NSObject

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;

+ (id)sharedManager;

- (SFShelf*)insertNewShelf;
- (SFBook*)insertNewBook;

- (NSArray*)shelves;
- (NSFetchedResultsController*)fechedResultsController;

- (void)saveContext;
- (NSURL*)applicationDocumentsDirectory;

@end
