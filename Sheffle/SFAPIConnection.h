//
//  SFAPIConnection.h
//  Sheffle
//
//  Created by 桜井雄介 on 2012/11/11.
//  Copyright (c) 2012年 Kaeru Lab. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^SFAPIConnectionCompletionHandler)(NSHTTPURLResponse* response, NSDictionary *JSONData);
typedef void(^SFAPIConnectionFailedHandler) (NSError *error);

typedef enum{
    SFAPIRequestTypeBooksBookSearch = 0,
    SFAPIRequestTypeBooksTotalSearch
}SFAPIRequestType;

@interface SFAPIConnection : NSOperation

// コンプハンドラ
@property (nonatomic, copy) SFAPIConnectionCompletionHandler completionHandler;
// フェイルドハンドラ
@property (nonatomic, copy) SFAPIConnectionFailedHandler failedHandler;
// リクエストタイプ
@property (nonatomic, assign) SFAPIRequestType requestType;
// パラメータ
@property (nonatomic, weak) NSDictionary *parameters;

- (id)initWithRequestType:(SFAPIRequestType)requestType parameters:(NSDictionary*)parameters;
+ (id)connectionWithRequestType:(SFAPIRequestType)reqeustType patameters:(NSDictionary*)parameters;
- (void)startAPIConnection;
- (void)cancelAPIConnection;

@end
