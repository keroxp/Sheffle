//
//  SFBook.h
//  Sheffle
//
//  Created by 桜井 雄介 on 2012/07/30.
//  Copyright (c) 2012年 Kaeru Lab. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
//#import "SFBook+Alpha.h"

/*

1:単行本
2:文庫
3:新書
4:全集・双書
5:事・辞典
6:図鑑
7:絵本
8:カセット,CDなど
9:コミック
10:ムックその他
*/

@class SFShelf;

typedef enum {
    SFBookSizeTankobon = 1,
    SFBookSizeBunko,
    SFBookSizeShinsho,
    SFBookSizeZenshu,
    SFBookSizeJiten,
    SFBookSizeZukan,
    SFBookSizeEhon,
    SFBookSizeCD,
    SFBookSizeComic,
    SFBookSizeMookOther
}SFBookSize;

@interface SFBook : NSManagedObject

// 内部情報
@property (nonatomic, retain) NSString * identifier;
@property (nonatomic, retain) NSDate *updated;
@property (nonatomic, retain) NSDate *created;
@property (nonatomic, retain) NSData * image;
@property (nonatomic, retain) NSData * image2x;
@property (nonatomic, retain) SFShelf *shelf;

// 楽天APIの情報
@property (nonatomic, retain) NSString * author;
@property (nonatomic, retain) NSString * authorKana;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * titleKana;
@property (nonatomic, retain) NSString * seriesName;
@property (nonatomic, retain) NSString * seriesNameKana;
@property (nonatomic, retain) NSString * isbn;
@property (nonatomic, retain) NSString * itemCaption;
@property (nonatomic) int16_t itemPrice;
@property (nonatomic, retain) NSString * itemUrl;
@property (nonatomic, retain) NSString * publisherName;
@property (nonatomic, retain) NSDate *salesDate;
@property (nonatomic, retain) NSString *bookSize;

// セクション用プロパティ
@property (readonly, nonatomic) NSString *titleInitial;
@property (readonly, nonatomic) NSString *authorInitial;
@property (readonly, nonatomic) NSString *publisherNameInitial;

- (void)setDataWithJSON:(NSDictionary*)JSON;

@end
