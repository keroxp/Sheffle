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
#import "SFBook+Alpha.h"
#import "SFShelf.h"
#import "SFShelf+Alpha.h"
#import "SFBookAuthor.h"

@interface SFCoreDataManager : NSObject

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;

+ (id)sharedManager;

- (SFShelf*)insertNewShelf;
- (SFBook*)insertNewBook;
- (SFBookAuthor*)insertNewBookAuthor;

- (BOOL)hasDataOfEntityName:(NSString*)entityName withIDKey:(NSString*)IDkey forIDValue:(NSString*)IDValue;
- (NSArray*)shelves;
- (NSURL*)applicationDocumentsDirectory;
- (NSFetchedResultsController*)fetchedResultsControllerWithEntityName:(NSString*)entityName
                                                      sortDescriptors:(NSArray*)sortDesctiptors
                                                   sectionNameKeyPath:(NSString*)sectionNameKeyPath
                                                            cacheName:(NSString*)cacheName
                                                            predicate:(NSPredicate*)predicate;
- (void)saveContext;

@end
