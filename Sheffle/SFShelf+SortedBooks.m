//
//  SFShelf+SortedBooks.m
//  Sheffle
//
//  Created by 桜井 雄介 on 2012/08/05.
//  Copyright (c) 2012年 Kaeru Lab. All rights reserved.
//

#import "SFShelf+SortedBooks.h"

@implementation SFShelf (SortedBooks)

- (NSArray *)sortedBooks
{
    NSSortDescriptor *title = [[NSSortDescriptor alloc] initWithKey:@"titleKana" ascending:NO];
    NSSortDescriptor *author = [[NSSortDescriptor alloc] initWithKey:@"authorKana" ascending:NO];
    NSSortDescriptor *created = [[NSSortDescriptor alloc] initWithKey:@"created" ascending:NO];
    NSSortDescriptor *size = [[NSSortDescriptor alloc] initWithKey:@"size" ascending:NO];
    
    NSArray *books = [self.books sortedArrayUsingDescriptors:@[title,author,created,size]];
    return books;
}

@end
