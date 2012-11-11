//
//  SFBook.h
//  Sheffle
//
//  Created by 桜井雄介 on 2012/11/11.
//  Copyright (c) 2012年 Kaeru Lab. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class SFBookAuthor, SFShelf;

@interface SFBook : NSManagedObject

@property (nonatomic, retain) NSString * author;
@property (nonatomic, retain) NSString * authorKana;
@property (nonatomic, retain) NSString * bookSize;
@property (nonatomic, retain) NSDate * created;
@property (nonatomic, retain) NSString * identifier;
@property (nonatomic, retain) NSData * image;
@property (nonatomic, retain) NSData * image2x;
@property (nonatomic, retain) NSString * isbn;
@property (nonatomic, retain) NSString * itemCaption;
@property (nonatomic, retain) NSNumber * itemPrice;
@property (nonatomic, retain) NSString * itemUrl;
@property (nonatomic, retain) NSString * publisherName;
@property (nonatomic, retain) NSDate * salesDate;
@property (nonatomic, retain) NSString * seriesName;
@property (nonatomic, retain) NSString * seriesNameKana;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * titleKana;
@property (nonatomic, retain) NSDate * updated;
@property (nonatomic, retain) NSNumber * favorite;
@property (nonatomic, retain) SFShelf *shelf;
@property (nonatomic, retain) SFBookAuthor *bookAuthor;

@end
