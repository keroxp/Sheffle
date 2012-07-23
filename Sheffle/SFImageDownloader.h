//
//  SFImageDownloader.h
//  Sheffle
//
//  Created by 桜井 雄介 on 12/07/23.
//  Copyright (c) 2012年 Kaeru Lab. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol SFImageDownloaderDelegate;

typedef enum{
    SFImageDownloadIndexTypeIndex = 0,
    SFImageDownloadIndexTypeIndexPath
}SFImageDownloadIndexType;

@interface SFImageDownloader : NSObject <NSURLConnectionDelegate, NSURLConnectionDataDelegate>

@property (weak, nonatomic) id<SFImageDownloaderDelegate> delegate;
@property (readonly) SFImageDownloadIndexType indexType;

- (id)initWithURL:(NSURL*)url;
- (void)startDownload;
- (void)startDownloadForIndex:(NSInteger)index;
- (void)startDownloadForIndexPath:(NSIndexPath*)indexPath;                                   
- (void)cancelDownload;

@end

@protocol SFImageDownloaderDelegate

@required
- (void)downloader:(SFImageDownloader*)downloader didFailWithError:(NSError*)error;

@optional
- (void)downloader:(SFImageDownloader*)downloader didFinishLoading:(NSData*)data;
- (void)downloader:(SFImageDownloader *)downloader didFinishLoading:(NSData *)data forIndex:(NSInteger)index;
- (void)downloader:(SFImageDownloader *)downloader didFinishLoading:(NSData *)data forIndexPath:(NSIndexPath*)indexPath;
                  
@end
