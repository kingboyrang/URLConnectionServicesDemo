//
//  NSURLConnectionManager.h
//  IOSWebservices
//
//  Created by aJia on 2014/2/18.
//  Copyright (c) 2014年 rang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ServiceArgs.h"

//block
typedef void (^requestFinishBlock)();
typedef void (^requestFailedBlock)();
typedef void (^requestSuccessBlock)();

@interface NSURLConnectionManager : NSURLConnection<NSURLConnectionDelegate>
@property (nonatomic,retain) NSURLRequest *request;
@property (nonatomic,copy) NSString *responseString;
@property (nonatomic,retain) NSMutableData *responseData;
@property (nonatomic,assign) int responseStatusCode;
@property (nonatomic,retain) NSError *error;
@property (readwrite, nonatomic, copy) requestFinishBlock finishBlock;
@property (readwrite, nonatomic, copy) requestFailedBlock failedBlock;
@property (readwrite, nonatomic, copy) requestSuccessBlock successBlock;
+ (id)requestWithRequest:(NSURLRequest*)request;
+ (id)requestWithArgs:(ServiceArgs*)args;
+ (id)requestWithName:(NSString*)methodName;
- (id)initWithRequest:(NSURLRequest*)request;
- (id)initWithArgs:(ServiceArgs*)args;
- (void)setFinishBlock:(requestFinishBlock)afinishBlock;
- (void)setFailedBlock:(requestFailedBlock)afailedBlock;
- (void)setSuccessBlock:(requestSuccessBlock)asuccessBlock;

//同步请求
- (void)startSynchronous;
//开始异步请求
- (void)startAsynchronous;
@end
