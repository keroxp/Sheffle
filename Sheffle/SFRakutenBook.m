//
//  SFRakutenBook.m
//  Sheffle
//
//  Created by 桜井雄介 on 2012/11/12.
//  Copyright (c) 2012年 Kaeru Lab. All rights reserved.
//

#import "SFRakutenBook.h"

@implementation SFRakutenBook

- (id)initWithJSON:(NSDictionary *)book
{
    self = [super init];
    if (self) {
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
        
        NSDateFormatter *dfm = [[NSDateFormatter alloc] init];
        [dfm setDateFormat:@"yyyy年MM月"];
        [self setSalesDate:[dfm dateFromString:[book objectForKey:@"salesDate"]]];
        [self setBookSize:[book objectForKey:@"size"]];
        [self setSmallImageUrl:[book objectForKey:@"smallImageUrl"]];
        [self setMediumImageUrl:[book objectForKey:@"mediumImageUrl"]];
        [self setLargeImageUrl:[book objectForKey:@"largeImageUrl"]];
    }
    return self;
}

+ (NSArray *)booksWithbooks:(NSArray *)books
{
    NSMutableArray *ma = [NSMutableArray arrayWithCapacity:books.count];
    for (NSDictionary*b in books) {
        SFRakutenBook *new = [[SFRakutenBook alloc] initWithJSON:b];
        [ma addObject:new];
    }
    return [NSArray arrayWithArray:ma];
}

@end
