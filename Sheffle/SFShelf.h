//
//  SFShelf.h
//  Sheffle
//
//  Created by 桜井 雄介 on 2012/11/13.
//  Copyright (c) 2012年 Kaeru Lab. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class SFBook;

@interface SFShelf : NSManagedObject

@property (nonatomic, retain) NSDate * created;
@property (nonatomic, retain) NSString * identifier;
@property (nonatomic, retain) NSNumber * index;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSDate * updated;
@property (nonatomic, retain) NSSet *books;
@end

@interface SFShelf (CoreDataGeneratedAccessors)

- (void)addBooksObject:(SFBook *)value;
- (void)removeBooksObject:(SFBook *)value;
- (void)addBooks:(NSSet *)values;
- (void)removeBooks:(NSSet *)values;

@end
