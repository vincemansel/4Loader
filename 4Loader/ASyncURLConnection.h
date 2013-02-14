//
//  ASyncURLConnection.h
//  AsyncImageDownload
//
//  Created by waveOcean Software on 2/12/13.
//  Copyright (c) 2013 vincemansel. All rights reserved.
//
//  Partially based on Sample from Pro Multithreading and Memory Management for IOS and OSX: Appendix A
//

#import <Foundation/Foundation.h>

/*
 * By using typedef for a Block type variables,
 * Source code will have better readability.
 */

typedef void (^completeBlock_t)(NSData *data);
typedef void (^errorBlock_t)(NSError *error);

@protocol ASyncURLConnectionDelegate <NSObject>

- (void)connectionUpdateInBytes:(NSUInteger)current forMaxBytes:(NSUInteger)max;

@end

@interface ASyncURLConnection : NSURLConnection
{
    /*
     * Because ARC is enabled, all the variables below are
     * qualified with __strong  when it doesn't have an explicit qualifier.
     */
    
    NSMutableData *data_;
    NSURLResponse *response_;
    completeBlock_t completeBlock_;
    errorBlock_t errorBlock_;
}

/*
 * To give the source code better readability,
 * The typedefined Block type variable is used for the argument.
 */

@property (assign, nonatomic) NSUInteger max;
@property (assign, nonatomic) NSUInteger current;
@property (assign, nonatomic) id<ASyncURLConnectionDelegate> delegate;
@property (assign, nonatomic) NSURLCache *cache;

+ (id)request:(NSString *)requestUrl forDelegate:delegate withCache:cache
completeBlock:(completeBlock_t)completeBlock
   errorBlock:(errorBlock_t)errorBlock;

- (id)initWithRequest:(NSString *)requestUrl
        completeBlock:(completeBlock_t)completeBlock
           errorBlock:(errorBlock_t)errorBlock;
@end

