//
//  SFShelf.h
//  Sheffle
//
//  Created by 桜井 雄介 on 12/07/22.
//  Copyright (c) 2012年 Kaeru Lab. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface SFShelf : NSManagedObject

@property (strong,nonatomic) NSString *title;
@property (strong,nonatomic) NSDate *created;
@property (strong,nonatomic) NSDate *updated;

@end
