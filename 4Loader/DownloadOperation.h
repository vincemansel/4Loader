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

@interface DownloadOperation : NSOperation

@property (assign, nonatomic) float timeoutValue;

- (id)initWithLastSelectedView:(SmallView *)selectedView urlString:(NSString *)url_ delegate:(id<ASyncURLConnectionDelegate>)aDelegate;

@end
