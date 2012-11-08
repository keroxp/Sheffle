//
//  SFBook.m
//  Sheffle
//
//  Created by 桜井 雄介 on 2012/07/30.
//  Copyright (c) 2012年 Kaeru Lab. All rights reserved.
//

#import "SFBook.h"
#import "SFShelf.h"

@implementation SFBook

@dynamic author;
@dynamic created;
@dynamic identifier;
@dynamic isbn;
@dynamic itemCaption;
@dynamic itemPrice;
@dynamic itemUrl;
@dynamic publisherName;
@dynamic salesDate;
@dynamic title;
@dynamic updated;
@dynamic image2x;
@dynamic image;
@dynamic titleKana;
@dynamic authorKana;
@dynamic bookSize;
@dynamic shelf;

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
    [self setItemPrice:[[book objectForKey:@"itemPrice"] intValue]];
    [self setItemUrl:[book objectForKey:@"itemUrl"]];
    [self setPublisherName:[book objectForKey:@"publisherName"]];
    
    NSDateFormatter *dfm = [[NSDateFormatter alloc] init];
    [dfm setDateFormat:@"yyyy年MM月"];
    [self setSalesDate:[dfm dateFromString:[book objectForKey:@"salesDate"]]];
    [self setBookSize:[book objectForKey:@"size"]];
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
