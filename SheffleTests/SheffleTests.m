//
//  SheffleTests.m
//  SheffleTests
//
//  Created by 桜井 雄介 on 12/07/20.
//  Copyright (c) 2012年 Kaeru Lab. All rights reserved.
//

#import "SheffleTests.h"
#import <SBJson/SBJson.h>

@implementation SheffleTests

- (void)setUp
{
    [super setUp];
    
    // Set-up code here.
}

- (void)tearDown
{
    // Tear-down code here.
    
    [super tearDown];
}

- (void)sbjsontest
{
    NSString *json = @"{ hoge : 'hoge' , fuga : 1 , bar : ['hoge', 'foo', 'bar']}";
    NSDictionary *jsonv = [json JSONValue];
    NSLog(@"%@",jsonv);
}

@end
