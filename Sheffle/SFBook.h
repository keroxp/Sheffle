//
//  SFBook.h
//  Sheffle
//
//  Created by 桜井雄介 on 2012/07/28.
//  Copyright (c) 2012年 Kaeru Lab. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class SFShelf;

@interface SFBook : NSManagedObject

@property (nonatomic, retain) NSString * artistName;
@property (nonatomic, retain) NSString * author;
@property (nonatomic) NSTimeInterval created;
@property (nonatomic, retain) NSString * isbnjan;
@property (nonatomic, retain) NSString * itemCaption;
@property (nonatomic, retain) NSString * itemUrl;
@property (nonatomic, retain) NSData * largeImage;
@property (nonatomic, retain) NSData * mediumImage;
@property (nonatomic, retain) NSString * publisherName;
@property (nonatomic) NSTimeInterval salesDate;
@property (nonatomic, retain) NSData * smallImage;
@property (nonatomic, retain) NSString * title;
@property (nonatomic) NSTimeInterval updated;
@property (nonatomic, retain) NSString * identifier;
@property (nonatomic) int16_t index;
@property (nonatomic, retain) SFShelf *shelf;

@end
