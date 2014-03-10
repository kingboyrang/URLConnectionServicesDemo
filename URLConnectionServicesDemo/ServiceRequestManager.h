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
typedef void (^SRMFinishBlock)();
typedef void (^SRMFailedBlock)();
typedef void (^SRMSuccessBlock)();
typedef void (^SRMProgressBlock)(long long total,long long size,float rate);

@interface ServiceRequestManager : NSObject<NSURLConnectionDelegate>
@property (nonatomic,retain) NSURLRequest *request;
@property (nonatomic,readonly) NSString *responseString;//请求返回字符串
@property (nonatomic,readonly) NSMutableData *responseData;//请求返回数据
@property (nonatomic,readonly) int responseStatusCode;//请求状态
@property (nonatomic,readonly) NSError *error;//请求失败
@property (nonatomic,assign) NSStringEncoding defaultResponseEncoding;//默认编码

+ (id)requestWithRequest:(NSURLRequest*)request;
+ (id)requestWithURL:(NSURL*)url;
+ (id)requestWithArgs:(ServiceArgs*)args;
+ (id)requestWithName:(NSString*)methodName;
- (id)initWithRequest:(NSURLRequest*)request;
- (id)initWithURL:(NSURL*)url;
- (id)initWithArgs:(ServiceArgs*)args;
- (id)initWithName:(NSString*)methodName;
- (void)setFinishBlock:(SRMFinishBlock)aCompletionBlock;
- (void)setFailedBlock:(SRMFailedBlock)aFailedBlock;
- (void)setSuccessBlock:(SRMSuccessBlock)aSuccessBlock;
- (void)setProgressBlock:(SRMProgressBlock)aBytesReceivedBlock;
//同步请求
- (void)startSynchronous;
//开始异步请求
- (void)startAsynchronous;
@end
