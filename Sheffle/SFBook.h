//
//  SFBook.h
//  Sheffle
//
//  Created by 桜井 雄介 on 12/07/22.
//  Copyright (c) 2012年 Kaeru Lab. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface SFBook : NSManagedObject

// 楽天ブックスのデータカラム
@property (strong, nonatomic) NSString *artistName;
@property (strong, nonatomic) NSString *author;
@property (strong, nonatomic) NSString *publisherName;
@property (strong, nonatomic) NSDate *salesDate;
@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) NSString *itemCaption;
@property (strong, nonatomic) NSString *isbnjan;
@property (strong, nonatomic) NSString *itemUrl;
@property (strong, nonatomic) UIImage *smallImage;
@property (strong, nonatomic) UIImage *midiumImage;
@property (strong, nonatomic) UIImage *largeImage;

// プライベートデータカラム
@property (strong, nonatomic) NSDate *created;
@property (strong, nonatomic) NSDate *updated;

@end
