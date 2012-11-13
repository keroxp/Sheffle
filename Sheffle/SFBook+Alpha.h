//
//  SFBook+Alpha.h
//  Sheffle
//
//  Created by 桜井雄介 on 2012/11/11.
//  Copyright (c) 2012年 Kaeru Lab. All rights reserved.
//

#import "SFBook.h"

@class SFRakutenBook;
@interface SFBook (Alpha)

// セクション用プロパティ
@property (readonly, nonatomic) NSString *titleInitial;
@property (readonly, nonatomic) NSString *authorInitial;
@property (readonly, nonatomic) NSString *publisherNameInitial;

- (void)setDataWithJSON:(NSDictionary*)JSON;
- (void)setDataWithRakutenBook:(SFRakutenBook*)book;
+ (NSSet*)bookSetWithRakutenBooks:(NSArray*)books;

@end
