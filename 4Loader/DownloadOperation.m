//
//  DownloadOperation.m
//  4Loader
//
//  Created by waveOcean Software on 2/13/13.
//  Copyright (c) 2013 vincemansel. All rights reserved.
//

#import "DownloadOperation.h"

#define kTimeoutInterval 30.0

@interface DownloadOperation ()
{
    NSTimer *internalTimer;
    BOOL    executing;
    BOOL    finished;
    
    NSThread *timerThread;
    id<ASyncURLConnectionDelegate> asychDelegate_;
    SmallView *lastSelectedView_;
    NSString *urlString_;
}

@property (strong, nonatomic) NSTimer *timeOutTimer;

@end

@implementation DownloadOperation

- (id)initWithLastSelectedView:(SmallView *)selectedView urlString:(NSString *)url delegate:(id<ASyncURLConnectionDelegate>)aDelegate
{
    if (self = [super init]) {

        lastSelectedView_ = selectedView;
        asychDelegate_ = aDelegate;
        urlString_ = url;
        executing = NO;
        finished = NO;
        
        timerThread = [[NSThread alloc] initWithTarget:self selector:@selector(timerTask:) object:self];
    }
    return self;
}

- (BOOL)isConcurrent
{
    return YES;
}

- (BOOL)isExecuting
{
    return executing;
}

- (BOOL)isFinished
{
    return finished;
}

- (void)start
{
    if ([self isCancelled]) {
        [self willChangeValueForKey:@"isFinished"];
        finished = YES;
        [self didChangeValueForKey:@"isFinished"];
        return;
    }
    
    [self willChangeValueForKey:@"isExecuting"];
    [NSThread detachNewThreadSelector:@selector(main) toTarget:self withObject:nil];
    executing = YES;
    [timerThread start]; // Handles the timeout timer
    [self didChangeValueForKey:@"isExecuting"];
}

- (void)main
{
    
    @try {
        @autoreleasepool {
            
            //ASyncURLConnection *conn = [self processWork];
            
            [self processWork];
            
            do {
                [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
            } while (!self.isCancelled);
            
            //conn = nil;

        }
    }
    @catch (NSException *e) {
        NSLog(@"Exception: %@", e);
        [self completeOperation];
        
    }
    
}

- (ASyncURLConnection *)processWork
{
    /*
     * On the background thread, downloading data from the specified URL starts asynchronously.
     */
    
    ASyncURLConnection *conn = [ASyncURLConnection request:urlString_ forDelegate:asychDelegate_ withCache:nil completeBlock:^(NSData *data) {
        
        dispatch_queue_t queue =
        dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        dispatch_async(queue, ^{
            
            /*
             * On a global dispatch queue, processing the downloaded data
             */
            
            NSLog(@"Got image: display on UI");
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                /*
                 * Here, it uses the result on the main dispatch queue.
                 * Displays the result on the user interface.
                 */
                
                lastSelectedView_.imageView.image = [UIImage imageWithData:data];
                [self completeOperation];

            });
        });
        
    } errorBlock:^(NSError *error) {
        
        /*
         * Error occurred
         */
        
        NSLog(@"error %@", error);
        [self completeOperation];
        
    }];
    
    return conn;
}

+ (void)showAlert:(NSString *)theTitle withMessage:(NSString *)theMessage
{
    UIAlertView *av = [[UIAlertView alloc] initWithTitle:theTitle
                                                 message:theMessage
                                                delegate:nil
                                       cancelButtonTitle:@"OK"
                                       otherButtonTitles:nil];
    [av show];
}


- (void)completeOperation {
    [self willChangeValueForKey:@"isFinished"];
    [self willChangeValueForKey:@"isExecuting"];
    
    executing = NO;
    finished = YES;
    
    [self.timeOutTimer invalidate];
    [internalTimer invalidate];
    
    [self didChangeValueForKey:@"isExecuting"];
    [self didChangeValueForKey:@"isFinished"];
}


- (void)timerTask:(DownloadOperation *)newOperation
{
    [newOperation setTimeOutTimer:[NSTimer timerWithTimeInterval:self.timeoutValue target:newOperation selector:@selector(timeoutHandler:) userInfo:newOperation repeats:NO] ];
    [[NSRunLoop currentRunLoop] addTimer:newOperation.timeOutTimer forMode:NSRunLoopCommonModes];
    [[NSRunLoop currentRunLoop] run];
}

- (void)timeoutHandler:(NSTimer *)timer
{
    id obj = [timer userInfo];
    NSLog(@"Is MainThread? = %u", [NSThread isMainThread]);
    NSLog(@"Timeout on %@", obj);
    
    [self cancel];
    //[self completeOperation];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        /*
         * Here, it uses the result on the main dispatch queue.
         * Displays the result on the user interface.
         */
        
        [[self class] showAlert:@"Timeout" withMessage:[NSString stringWithFormat:@"in quadrant %u.", lastSelectedView_.tag]];
        
    });
}



@end
