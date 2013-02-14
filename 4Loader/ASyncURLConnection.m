//
//  ASyncURLConnection.m
//  AsyncImageDownload
//
//  Created by waveOcean Software on 2/12/13.
//  Copyright (c) 2013 vincemansel. All rights reserved.
//

#import "ASyncURLConnection.h"

@implementation ASyncURLConnection

+ (id)request:(NSString *)requestUrl forDelegate:aDelegate withCache:aCache
completeBlock:(completeBlock_t)completeBlock
   errorBlock:(errorBlock_t)errorBlock
{
    /*
     * If ARC is disabled,
     * This method should return an object after autorelease is called:
     *          * id obj = [[[self alloc] initWithRequest:requestUrl
     *   completeBlock:completeBlock errorBlock:errorBlock];
     * return [obj autorelease];
     *
     * Because this method name doesn't begin with alloc/new/copy/mutableCopy,
     * the returned object has been automatically registered in autoreleasepool.
     */
    
    id obj = [[self alloc] initWithRequest:requestUrl
                           completeBlock:completeBlock errorBlock:errorBlock];
    [obj setDelegate:aDelegate];
    //[obj setCache:aCache];
    return obj;
}

- (id)initWithRequest:(NSString *)requestUrl
        completeBlock:(completeBlock_t)completeBlock
           errorBlock:(errorBlock_t)errorBlock
{
    NSURL *url = [NSURL URLWithString:requestUrl];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    if ((self = [super initWithRequest:request
                              delegate:self startImmediately:YES])) {
        data_ = [[NSMutableData alloc] init];
        
        /*
         * To make sure that you can use the passed Block safely,
         * the instance method 'copy' is called to put the Block on the heap.
         */
        completeBlock_ = [completeBlock copy];
        errorBlock_ = [errorBlock copy];
        
        [self start];
        
    }
    
    /*
     * Member variables that have a __strong qualifier
     * have ownership of the created NSMutableData class object
     *
     * When the object is discarded, the strong references
     * of the member variables with the __strong qualifier disappear.
     * The NSMutableData class object and the Block will be released automatically.
     *
     * So, you don't need to implement the dealloc instance method explicitly.
     */
    
    return self;
}

- (void)connection:(NSURLConnection *)connection
didReceiveResponse:(NSURLResponse *)response
{
    [data_ setLength:0];
    NSLog(@"Expected length = %llu", [response expectedContentLength]);
    self.max = [response expectedContentLength];
    self.current = 0;
    
    response_ = response;
}

- (void)connection:(NSURLConnection *)connection
    didReceiveData:(NSData *)data
{
    [data_ appendData:data];
    //NSLog(@"Thead = %@: Appending data: bytes = %u", [NSThread currentThread], [data_ length] );
    
    self.current = [data_ length];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.delegate connectionUpdateInBytes:self.current forMaxBytes:self.max];
    });
    
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    /*
     * Execute the Block assigned as callback for downloading success.
     * The legacy delegate callback can be replaced by Block.
     */
    
    completeBlock_(data_);
    
    // Not required - managed by NSURLConnection system as long as [NSURL sharedCached] is setup.
    //NSCachedURLResponse *cacheURLResponse = [[NSCachedURLResponse alloc] initWithResponse:response_ data:data_];
    //[self.cache storeCachedResponse:cacheURLResponse forRequest:[connection currentRequest]];
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection willCacheResponse:(NSCachedURLResponse *)cachedResponse
{
    NSLog(@"Connection: %@ : CachedResponse %@", connection, cachedResponse);
    return cachedResponse;
}

- (void)connection:(NSURLConnection *)connection
  didFailWithError:(NSError *)error
{
    /*
     * Execute the Block that is assigned for error.
     */
    
    errorBlock_(error);
}

@end
