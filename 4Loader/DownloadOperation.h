//
//  DownloadOperation.h
//  4Loader
//
//  Created by waveOcean Software on 2/13/13.
//  Copyright (c) 2013 vincemansel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ASyncURLConnection.h"
#import "SmallView.h"

@protocol DownloadOperationDelegate <NSObject>

- (void)connectionUpdateInBytes:(NSUInteger)current forMaxBytes:(NSUInteger)max forView:(UIView *)aView;
- (void)downloadComplete:(NSData *)data forView:(UIView *)aView;
- (void)timeoutOccuredForView:(UIView *)aView;

@end

@interface DownloadOperation : NSOperation <ASyncURLConnectionDelegate>

@property (assign, nonatomic) float timeoutValue;
@property (assign, nonatomic) id<DownloadOperationDelegate> dlDelegate;

- (id)initWithLastSelectedView:(SmallView *)selectedView urlString:(NSString *)url_ delegate:(id<DownloadOperationDelegate>)aDelegate;

@end
