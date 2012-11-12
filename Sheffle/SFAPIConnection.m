//
//  SFAPIConnection.m
//  Sheffle
//
//  Created by 桜井雄介 on 2012/11/11.
//  Copyright (c) 2012年 Kaeru Lab. All rights reserved.
//

#import "SFAPIConnection.h"

#define kAPIURL @"http://api.rakuten.co.jp/rws/3.0/json?"

/*
 http://api.rakuten.co.jp/rws/3.0/rest?
 developerId=[YOUR_developerID]
 &operation=BooksBookSearch
 &version=2011-12-01
 &title=%E5%A4%AA%E9%99%BD
 &booksGenreId=001004008
 &sort=%2BitemPrice
 */

@interface SFAPIConnection()
{
    NSURLConnection *_connection;
    NSMutableString *_urlString;
    NSHTTPURLResponse *_responseHeader;
    NSMutableData *_responseData;
    NSOperationQueue *_queue;
    BOOL isReady, isExcuting, isFinished, isCancelled;
}

@end

@implementation SFAPIConnection

#pragma mark - Override Methods from NSOperation

+ (BOOL)automaticallyNotifiesObserversForKey:(NSString *)key
{
    if ([key isEqualToString:@"isFinished"] ||
        [key isEqualToString:@"isExcuting"] ) {
        return YES;
    }
    return [super automaticallyNotifiesObserversForKey:key];
}

- (void)start
{
    $(@"start api request for url : %@",_urlString);
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    [self setValue:[NSNumber numberWithBool:YES] forKey:@"isExcuting"];
    
    // YouTubeへのアクセスは普通のコネクションで
    NSURL *URL = [NSURL URLWithString:[_urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    NSURLRequest *r = [NSURLRequest requestWithURL:URL]; //] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:120];
    _connection = [NSURLConnection connectionWithRequest:r delegate:self];
    
    if (_connection != nil) {
        do {
            [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
        } while (isExcuting);
    }
}

- (BOOL)isConcurrent
{
    return YES;
}

- (BOOL)isExecuting
{
    return isExcuting;
}

- (BOOL)isFinished
{
    return isFinished;
}

#pragma mark - Public

- (id)initWithRequestType:(SFAPIRequestType)requestType parameters:(NSDictionary *)parameters
{
    self = [super init];
    if(self){
        _requestType = requestType;
        _parameters = parameters;
        _urlString = [NSMutableString stringWithString:kAPIURL];
        [_urlString appendFormat:@"developerId=%@&",kRakutenAPPID];
        [_urlString appendString:@"version=2011-12-01&"];
        switch (self.requestType) {
            case SFAPIRequestTypeBooksBookSearch:
                [_urlString appendString:@"operation=BooksBookSearch&"];
                break;
            case SFAPIRequestTypeBooksTotalSearch:
                [_urlString appendString:@"operation=BooksTotalSearch&"];
                break;
            default:
                break;
        }
        for (NSString *key in [_parameters keyEnumerator]) {
            [_urlString appendFormat:@"%@=%@&",key,[_parameters objectForKey:key]];
        }
    }
    return self;
}

+ (id)connectionWithRequestType:(SFAPIRequestType)reqeustType patameters:(NSDictionary *)parameters
{
    return [[SFAPIConnection alloc] initWithRequestType:reqeustType parameters:parameters];
}

- (void)startAPIConnection
{
    _queue = [[NSOperationQueue alloc] init];
    [_queue addOperation:self];
}

- (void)cancelAPIConnection
{
    $(@"cancel api request for url : %@",_urlString);
    [_connection cancel];
    _responseHeader = nil;
    _responseData = nil;
    [self setValue:[NSNumber numberWithBool:NO] forKey:@"isExcuting"];
    [self setValue:[NSNumber numberWithBool:YES] forKey:@"isFinished"];
}

- (void)finishAPIRequest
{
    $(@"finish api request for type of : %i",self.requestType);
    _responseData = nil;
    _responseHeader = nil;
    [self setValue:[NSNumber numberWithBool:NO] forKey:@"isExcuting"];
    [self setValue:[NSNumber numberWithBool:YES] forKey:@"isFinished"];
    if (_queue.operationCount == 0) {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    }
}

#pragma mark - NSURLConnectionDownload


- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    _responseHeader = [(NSHTTPURLResponse*)response copy];
    
    //    if (_responseHeader.statusCode != 200) {
    //        [self cancelAPIRequest];
    //        self.failedHandler(nil);
    //    }
    
    _responseData = [NSMutableData data];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [_responseData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    [self rescueClientError:error];
    
    if ([self failedHandler])
        self.failedHandler(error);
    
    [self finishAPIRequest];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSDictionary *JSON = nil;
    if (_responseData) {
        NSString *responseString = [[NSString alloc] initWithData:_responseData encoding:NSUTF8StringEncoding];
        JSON = [responseString JSONValue];
    }
    // JSONValueに失敗してもfailedHandlerに投げる
    if (!JSON || JSON.count == 0) {
        // Rescue
        // Handle if needed
        if (self.failedHandler) {
            [self setCompletionBlock:^(){
                NSOperationQueue *queue = [NSOperationQueue mainQueue];
                [queue addOperationWithBlock:^(){
                    NSError *error = [NSError errorWithDomain:@"JSONValue fialed now" code:200 userInfo:nil];
                    self.failedHandler(error);
                }];
            }];
        }
    }else{
        //    if (self.request.requestType != FANAPIRequestTypeYouTubeSearch) $(@"%@",JSON);
        __block NSDictionary *_JSON = JSON;
        __block NSHTTPURLResponse *responseHeader = _responseHeader;
        [self setCompletionBlock:^{
            // Run on main thread.
            NSOperationQueue *queue = [NSOperationQueue mainQueue];
            [queue addOperationWithBlock:^{
                if(self.completionHandler)
                    self.completionHandler(responseHeader, _JSON);
            }];
        }];
    }
    [self finishAPIRequest];
}

- (void)rescueClientError:(NSError *)error
{
    __block UIAlertView *alertView;
    NSString *message = [error localizedDescription];
    
    alertView = [[UIAlertView alloc]
                 initWithTitle: NSLocalizedString(@"ダウンロードに失敗しました", nil)
                 message: message
                 delegate: self
                 cancelButtonTitle: nil
                 otherButtonTitles: NSLocalizedString(@"OK", nil), nil];
    
    [self setCompletionBlock:^(){
        [[NSOperationQueue mainQueue] addOperationWithBlock:^(){
            [alertView show];
        }];
    }];
}

@end
