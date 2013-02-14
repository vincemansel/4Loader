//
//  SmallView.h
//  4Loader
//
//  Created by waveOcean Software on 2/12/13.
//  Copyright (c) 2013 vincemansel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ASyncURLConnection.h"

@class SmallView;

@protocol SmallViewDelegate <NSObject>

- (void)viewWasSelected:(SmallView *)smallView withNumberOfTaps:(NSInteger)tapCount;

@end
@interface SmallView : UIView <ASyncURLConnectionDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIProgressView *progressView;

@property (assign, nonatomic) id<SmallViewDelegate> delegate;

- (void)initializeView;

@end
