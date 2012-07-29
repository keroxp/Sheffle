//
//  SFImageDownloader.m
//  Sheffle
//
//  Created by 桜井 雄介 on 12/07/23.
//  Copyright (c) 2012年 Kaeru Lab. All rights reserved.
//

#import "SFImageDownloader.h"

@interface SFImageDownloader () 
{
    NSURLConnection *_connection;
    NSMutableData *_buffer;
    NSHTTPURLResponse *_response;
    NSUInteger _index;
    NSIndexPath *_indexPath;
    NSURL *_URL;
}

@end

@implementation SFImageDownloader

@synthesize indexType = _indexType;
@synthesize delegate = _delegate;

- (id)initWithURL:(NSURL *)url
{
    self = [super init];
    if (self) {
        _URL = url;
    }
    return self;
}


- (void)startDownload
{
    NSLog(@"start dl : %@",_URL);
    NSURLRequest *req = [NSURLRequest requestWithURL:_URL];
    _connection = [NSURLConnection connectionWithRequest:req delegate:self];
    [_connection start];
}

- (void)cancelDownload{
    [_connection  cancel];
    _buffer = nil;
    _connection = nil;
}

- (void)startDownloadForIndex:(NSInteger)index
{
    _indexType = SFImageDownloadIndexTypeIndex;
    _index = index;
    [self startDownload];
}

- (void)startDownloadForIndexPath:(NSIndexPath *)indexPath
{
    _indexType = SFImageDownloadIndexTypeIndexPath;
    _indexPath = indexPath;
    [self startDownload];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    [[self delegate] downloader:self didFailWithError:error];
    _connection = nil;
    _buffer = nil;
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    NSLog(@"receive resoponse");
    _response = [(NSHTTPURLResponse*)response copy];
    _buffer = [NSMutableData data];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [_buffer appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSLog(@"finish loading");
    if (_buffer) {
        if (self.indexType == SFImageDownloadIndexTypeIndex) {
//            self.completionHandler(_response, _buffer, _index);
            [[self delegate] downloader:self didFinishLoading:_buffer forIndex:_index];
        }else if (self.indexType == SFImageDownloadIndexTypeIndexPath) {
//            self.completionHandler(_response, _buffer, _indexPath);
            [[self delegate] downloader:self didFinishLoading:_buffer forIndexPath:_indexPath];
        }else {
//            self.completionHandler(_response, _buffer, nil);
            [[self delegate] downloader:self didFinishLoading:_buffer];
        }
    }
    _connection = nil;
}

@end
