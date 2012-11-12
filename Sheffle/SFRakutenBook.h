//
//  SFRakutenBook.h
//  Sheffle
//
//  Created by 桜井雄介 on 2012/11/12.
//  Copyright (c) 2012年 Kaeru Lab. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SFRakutenBook : NSObject

@property (nonatomic, retain) NSString * author;
@property (nonatomic, retain) NSString * authorKana;
@property (nonatomic, retain) NSString * bookSize;
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
@property (nonatomic, retain) NSString * smallImageUrl;
@property (nonatomic, retain) NSString * mediumImageUrl;
@property (nonatomic, retain) NSString * largeImageUrl;

- (id)initWithJSON:(NSDictionary*)book;
+ (NSArray*)booksWithbooks:(NSArray*)books;

@end
