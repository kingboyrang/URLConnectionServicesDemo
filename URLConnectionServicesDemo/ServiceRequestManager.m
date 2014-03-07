//
//  NSURLConnectionManager.m
//  IOSWebservices
//
//  Created by aJia on 2014/2/18.
//  Copyright (c) 2014年 rang. All rights reserved.
//

#import "ServiceRequestManager.h"

@interface ServiceRequestManager ()
@property (readwrite, nonatomic, copy) SRMFinishBlock finishBlock;
@property (readwrite, nonatomic, copy) SRMFailedBlock failedBlock;
@property (readwrite, nonatomic, copy) SRMSuccessBlock successBlock;
@property (readwrite, nonatomic, copy) SRMProgressBlock progressBlock;
@property (nonatomic,retain) NSURLConnection *connection;
@property (nonatomic,assign) long long totalFileSize;
- (NSURLRequest*)requestWithServiceArgs:(ServiceArgs*)args;
- (void)showNetworkActivityIndicator;
- (void)hideNetworkActivityIndicator;
- (void)clearAndDelegate;
@end

@implementation ServiceRequestManager
-(void)dealloc{
    if (self.connection) {
        [self.connection cancel];
        [self.connection release],self.connection=nil;
    }
	[super dealloc];
}
+ (id)requestWithRequest:(NSURLRequest*)request{
    return [[[self alloc] initWithRequest:request] autorelease];
}
+ (id)requestWithArgs:(ServiceArgs*)args{
    return [[[self alloc] initWithArgs:args] autorelease];
}
+ (id)requestWithName:(NSString *)methodName{
    ServiceArgs *args=[ServiceArgs serviceMethodName:methodName];
    return [[[self alloc] initWithArgs:args] autorelease];
}
+ (id)requestWithURL:(NSURL*)url{
    return [[[self alloc] initWithURL:url] autorelease];
}
- (id)init{
    if (self=[super init]) {
        self.error=nil;
        self.responseString=@"";
        self.responseStatusCode=100;
        self.defaultResponseEncoding=NSUTF8StringEncoding;
        self.responseData=[[NSMutableData data] retain];
    }
    return self;
}
- (id)initWithRequest:(NSURLRequest*)request{
    self=[self init];
    self.request=request;
    return self;
}
- (id)initWithArgs:(ServiceArgs*)args{
    self=[self init];
    self.request=[self requestWithServiceArgs:args];
    return self;
}
- (id)initWithURL:(NSURL*)url{
    self=[self init];
    self.request=[NSURLRequest requestWithURL:url];
    return self;
}
- (void)setFinishBlock:(SRMFinishBlock)afinishBlock{
    if (_finishBlock!=afinishBlock) {
        [_finishBlock release];
        _finishBlock=[afinishBlock copy];
    }
}
- (void)setFailedBlock:(SRMFailedBlock)afailedBlock{
    if (_failedBlock!=afailedBlock) {
        [_failedBlock release];
        _failedBlock=[afailedBlock copy];
    }
}
- (void)setSuccessBlock:(SRMSuccessBlock)asuccessBlock{
    if (_successBlock!=asuccessBlock) {
        [_successBlock release];
        _successBlock=[asuccessBlock copy];
    }
}
- (void)setProgressBlock:(SRMProgressBlock)aprogressBlock{
    if (_progressBlock!=aprogressBlock) {
        [_progressBlock release];
        _progressBlock=[aprogressBlock copy];
    }
}
- (void)startAsynchronous{
    /**
    if (!self.responseData) {
        self.responseData=[NSMutableData data];
    }
     [self.responseData setLength:0];
     ***/
    
    if (self.request) {
        [self clearAndDelegate];//取消前一次请求
        self.connection=[[NSURLConnection alloc] initWithRequest:self.request delegate:self];
        [self.connection start];
        [self showNetworkActivityIndicator];
    }
}
- (void)startSynchronous{
    /***
    if (!self.responseData) {
        self.responseData=[NSMutableData data];
    }
    [self.responseData setLength:0];
     ***/
    if (self.request) {
        [self clearAndDelegate];//取消前一次请求
        [self showNetworkActivityIndicator];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSHTTPURLResponse *response=nil;
            NSError *error=nil;
            NSData *data=[NSURLConnection sendSynchronousRequest:self.request returningResponse:&response error:&error];
            //请求完成
            if (error) {
                self.responseString=@"";
            }else{
                NSString *xml=[[NSString alloc] initWithData:data encoding:self.defaultResponseEncoding];
                self.responseString=xml;
                [xml release];
            }
            self.error=error;
            self.responseStatusCode=[response statusCode];
            [self.responseData appendData:data];
            if (self.successBlock) {
                [self hideNetworkActivityIndicator];
                self.successBlock();
            }
        });
    }
}
#pragma mark -
#pragma mark NSURLConnection delegate Methods
- (void)connection:(NSURLConnection *)con didReceiveResponse:(NSURLResponse *)response {
    // store data
    [self.responseData setLength:0];      //通常在这里先清空接受数据的缓存
    
    NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
    self.responseStatusCode=[httpResponse statusCode];
    //取得文件大小
    self.totalFileSize=[response expectedContentLength];
}

- (void)connection:(NSURLConnection *)con didReceiveData:(NSData *)data {
    [self.responseData appendData:data];    //可能多次收到数据，把新的数据添加在现有数据最后
    if (self.progressBlock) {
        long long proValue=[self.responseData length]*1.0;
        self.progressBlock(self.totalFileSize,[self.responseData length]*1.0,proValue/self.totalFileSize);
    }
}
- (void)connection:(NSURLConnection *)con
  didFailWithError:(NSError *)error
{
    [self hideNetworkActivityIndicator];
    self.error=error;
    self.responseString=@"";
    if (self.failedBlock) {
        self.failedBlock();
    }
    [self clearAndDelegate];
}
- (void)connectionDidFinishLoading:(NSURLConnection *)con
{
    [self hideNetworkActivityIndicator];
    NSString *xml=[[NSString alloc] initWithData:self.responseData encoding:self.defaultResponseEncoding];
    self.responseString=xml;
    [xml release];
    self.error=nil;
    if(self.finishBlock)
    {
        self.finishBlock();
    }
    [self clearAndDelegate];
}
#pragma mark -private Methods
- (void)clearAndDelegate{
    if (self.connection) {
        [self.connection cancel];
        [self.connection release],self.connection=nil;
    }
}
- (NSURLRequest*)requestWithServiceArgs:(ServiceArgs*)args{
    
    NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:args.webURL];
    //头部设置
    [request setAllHTTPHeaderFields:[args headers]];
    //超时设置
    [request setTimeoutInterval:60];
    //访问方式
    [request setHTTPMethod:@"POST"];
    //body内容
    [request setHTTPBody:[args.soapMessage dataUsingEncoding:NSUTF8StringEncoding]];
    return request;
}
- (void)showNetworkActivityIndicator
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}
- (void)hideNetworkActivityIndicator
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}
@end
