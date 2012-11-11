//
//  SFBook+Alpha.m
//  Sheffle
//
//  Created by 桜井雄介 on 2012/11/11.
//  Copyright (c) 2012年 Kaeru Lab. All rights reserved.
//

#import "SFBook+Alpha.h"

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
