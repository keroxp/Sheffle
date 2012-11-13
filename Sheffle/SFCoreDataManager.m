//
//  SFCoreDataController.m
//  Sheffle
//
//  Created by 桜井 雄介 on 12/07/26.
//  Copyright (c) 2012年 Kaeru Lab. All rights reserved.
//

#import "SFCoreDataManager.h"

static SFCoreDataManager *_sharedInstance;

@interface SFCoreDataManager ()
{
    NSManagedObjectModel *__managedObjectModel;
    NSPersistentStoreCoordinator *__persistentStoreCoordinator;
    NSFetchedResultsController *__fetchedResultsController;
}

- (NSString*)insertNewIdentifier;
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator;
- (NSManagedObjectModel*)managedObjectModel;
- (NSURL *)applicationDocumentsDirectory;

@end

@implementation SFCoreDataManager

@synthesize managedObjectContext = __managedObjectContext;

+ (id)sharedManager
{
    if (!_sharedInstance) {
        _sharedInstance = [[SFCoreDataManager alloc] init];
    }
    return _sharedInstance;
}

- (SFShelf *)insertNewShelf
{
    SFShelf *shelf = [NSEntityDescription insertNewObjectForEntityForName:@"Shelf" inManagedObjectContext:[self managedObjectContext]];
    [shelf setIdentifier:[self insertNewIdentifier]];
    [shelf setCreated:[NSDate date]];
    [shelf setUpdated:[NSDate date]];
    
    //TODO:indexを設置
    
    return shelf;
}

- (SFBook *)insertNewBook
{
    SFBook *book = (SFBook*)[NSEntityDescription insertNewObjectForEntityForName:@"Book" inManagedObjectContext:[self managedObjectContext]];
    
    [book setIdentifier:[self insertNewIdentifier]];
    [book setCreated:[NSDate date]];
    [book setUpdated:[NSDate date]];
    [book setFavorite:@(NO)];
    
    //TODO:indexを設置する
    
    return book;
}

- (SFBookAuthor *)insertNewBookAuthor
{
    SFBookAuthor *author = (SFBookAuthor*)[NSEntityDescription insertNewObjectForEntityForName:@"BookAuthor" inManagedObjectContext:[self managedObjectContext]];
    [author setIdentifier:[self insertNewIdentifier]];
    [author setCreated:[NSDate date]];
    [author setUpdated:[NSDate date]];
    
    return author;
}

#pragma mark - Check if Duplicated

- (BOOL)hasDataOfEntityName:(NSString *)entityName withIDKey:(NSString *)IDkey forIDValue:(NSString *)IDValue
{
    // CoreData リクエスト命令組み立て
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName: entityName inManagedObjectContext: [self managedObjectContext]];
    [request setEntity: entity];
    NSString *predicateCommand = [NSString stringWithFormat: @"%@ = '",IDkey];
    predicateCommand = [predicateCommand stringByAppendingString: IDValue];
    predicateCommand = [predicateCommand stringByAppendingString: @"'"];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat: predicateCommand];
    [request setPredicate: predicate];
    
    // CoreDataフェッチ(取り出し)
    NSArray *fetchedObjects = [[self managedObjectContext] executeFetchRequest:request error: nil];

    if (!fetchedObjects || fetchedObjects.count == 0) {
        return NO;
    }else{
        return YES;
    }
}

- (NSArray *)shelves
{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Shelf" inManagedObjectContext:[self managedObjectContext]];
    NSSortDescriptor *index = [[NSSortDescriptor alloc] initWithKey:@"index" ascending:YES];
    
    [request setEntity:entity];
    [request setSortDescriptors:@[index]];
    
    NSError *error = nil;
    NSArray *results = [[self managedObjectContext] executeFetchRequest:request error:&error];
    
    if (error) {
        $(@"fetch request failed : %@", [error localizedDescription]);
        return nil;
    }
    
    return results;
}

- (NSString *)insertNewIdentifier
{
    CFUUIDRef uuid = CFUUIDCreate(NULL);
    NSString *identifier = (__bridge NSString*)CFUUIDCreateString(NULL, uuid);
    CFRelease(uuid);
    return identifier;
}

#pragma mark - Core Data stack

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext
{
    if (__managedObjectContext != nil) {
        return __managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        __managedObjectContext = [[NSManagedObjectContext alloc] init];
        [__managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return __managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    if (__managedObjectModel != nil) {
        return __managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Sheffle" withExtension:@"momd"];
    __managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return __managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (__persistentStoreCoordinator != nil) {
        return __persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"Sheffle.sqlite"];
    
    NSError *error = nil;
    __persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![__persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
         [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption, [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        $(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return __persistentStoreCoordinator;
}

- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            $(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }else{
            $(@"successfully saved");
        }
    }else{
        $(@"context is nil");
    }
}



#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

#pragma mark - Fetched Results Controller Getter

- (NSFetchedResultsController *)fetchedResultsControllerWithEntityName:(NSString *)entityName sortDescriptors:(NSArray *)sortDesctiptors sectionNameKeyPath:(NSString *)sectionNameKeyPath cacheName:(NSString *)cacheName
{
    
    NSManagedObjectContext *context = [self managedObjectContext];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:context];
    request.entity = entity;
    request.sortDescriptors = sortDesctiptors;
    
    NSFetchedResultsController *frc = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:context sectionNameKeyPath:sectionNameKeyPath cacheName:cacheName];
    
//    [NSFetchedResultsController deleteCacheWithName:cacheName];
    
    
    NSError *error = nil;
    if (![frc performFetch:&error]) {
        $(@"unsolvable error : %@", [error userInfo]);
        abort();
    }
    return frc;
}

@end
