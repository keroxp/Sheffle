//
//  SFBook+Alpha.m
//  Sheffle
//
//  Created by 桜井雄介 on 2012/11/11.
//  Copyright (c) 2012年 Kaeru Lab. All rights reserved.
//

#import "SFBook+Alpha.h"
#import "SFRakutenBook.h"
#import "SFCoreDataManager.h"

@implementation SFBook (Alpha)

- (void)setDataWithJSON:(NSDictionary *)JSON
{
    __weak NSDictionary *book = JSON;
    // 楽天の情報をセット
    [self setAuthor:[book objectForKey:@"author"]];
    [self setAuthorKana:[book objectForKey:@"authorKana"]];
    [self setTitle:[book objectForKey:@"title"]];
    [self setTitleKana:[book objectForKey:@"titleKana"]];
    [self setSeriesName:[book objectForKey:@"seriesName"]];
    [self setSeriesNameKana:[book objectForKey:@"seriesNameKana"]];
    [self setIsbn:[book objectForKey:@"isbn"]];
    [self setItemCaption:[book objectForKey:@"itemCaption"]];
    NSInteger p = [[book objectForKey:@"itemPrice"] integerValue];
    [self setItemPrice:@(p)];
    [self setItemUrl:[book objectForKey:@"itemUrl"]];
    [self setPublisherName:[book objectForKey:@"publisherName"]];
    [self setMediumImageUrl:[book objectForKey:@"mediumImageUrl"]];
    [self setSmallImageUrl:[book objectForKey:@"smallImageUrl"]];
    [self setLargeImageUrl:[book objectForKey:@"largeImageUrl"]];
    
    NSDateFormatter *dfm = [[NSDateFormatter alloc] init];
    [dfm setDateFormat:@"yyyy年MM月"];
    [self setSalesDate:[dfm dateFromString:[book objectForKey:@"salesDate"]]];
    [self setBookSize:[book objectForKey:@"size"]];
}

- (void)setDataWithRakutenBook:(SFRakutenBook *)book
{
    [self setAuthor:book.author];
    [self setAuthorKana:book.authorKana];
    [self setTitle:book.title];
    [self setTitleKana:book.titleKana];
    [self setSeriesName:book.seriesName];
    [self setSeriesNameKana:book.seriesNameKana];
    [self setIsbn:book.isbn];
    [self setItemCaption:book.itemCaption];
    [self setItemPrice:book.itemPrice];
    [self setItemUrl:book.itemUrl];
    [self setPublisherName:book.publisherName];
    
    [self setSalesDate:book.salesDate];
    [self setBookSize:book.bookSize];
    
    [self setSmallImageUrl:book.smallImageUrl];
    [self setMediumImageUrl:book.mediumImageUrl];
    [self setLargeImageUrl:book.largeImageUrl];
}

+ (NSSet *)bookSetWithRakutenBooks:(NSArray *)books
{
    NSMutableSet *set = [NSMutableSet setWithCapacity:books.count];
    for (SFRakutenBook *book in books) {
        SFBook *new = [[SFCoreDataManager sharedManager] insertNewBook];
        [new setDataWithRakutenBook:book];
        [set addObject:new];
    }
    return set;
}

- (NSString *)titleInitial
{
    return [self.titleKana substringWithRange:NSMakeRange(0, 1)];
}

- (NSString *)authorInitial
{
    return [self.authorKana substringWithRange:NSMakeRange(0, 1)];
}

- (NSString *)publisherNameInitial
{
    return [self.publisherName substringWithRange:NSMakeRange(0, 1)];
}

@end
