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

@interface NSURLConnectionManager : NSObject<NSURLConnectionDelegate>
@property (nonatomic,retain) NSURLRequest *request;
@property (nonatomic,copy) NSString *responseString;//请求返回字符串
@property (nonatomic,retain) NSMutableData *responseData;//请求返回数据
@property (nonatomic,assign) int responseStatusCode;//请求状态
@property (nonatomic,retain) NSError *error;//请求失败
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
