//
//  SFBookAuthor.h
//  Sheffle
//
//  Created by 桜井雄介 on 2012/11/11.
//  Copyright (c) 2012年 Kaeru Lab. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class SFBook;

@interface SFBookAuthor : NSManagedObject

@property (nonatomic, retain) NSString * identifier;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * nameKana;
@property (nonatomic, retain) NSSet *books;
@property (nonatomic, retain) NSDate *created;
@property (nonatomic, retain) NSDate *updated;

@end

@interface SFBookAuthor (CoreDataGeneratedAccessors)

- (void)addBooksObject:(SFBook *)value;
- (void)removeBooksObject:(SFBook *)value;
- (void)addBooks:(NSSet *)values;
- (void)removeBooks:(NSSet *)values;

@end
