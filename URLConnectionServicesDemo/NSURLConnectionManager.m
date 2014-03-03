//
//  NSURLConnectionManager.m
//  IOSWebservices
//
//  Created by aJia on 2014/2/18.
//  Copyright (c) 2014年 rang. All rights reserved.
//

#import "NSURLConnectionManager.h"

@interface NSURLConnectionManager ()
- (NSURLRequest*)requestWithServiceArgs:(ServiceArgs*)args;
- (void)showNetworkActivityIndicator;
- (void)hideNetworkActivityIndicator;
@end

@implementation NSURLConnectionManager
-(void)dealloc{
    [self cancel];
	[super dealloc];
}
- (id)init{
    if (self=[super init]) {
        self.error=nil;
        self.responseString=@"";
        self.responseStatusCode=100;
    }
    return self;
}
- (id)initWithRequest:(NSURLRequest*)request{
    if (self=[super init]) {
        self.request=request;
    }
    return self;
}
- (id)initWithArgs:(ServiceArgs*)args{
    if (self=[super init]) {
        self.request=[self requestWithServiceArgs:args];
    }
    return self;
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
- (void)setFinishBlock:(requestFinishBlock)afinishBlock{
    if (_finishBlock!=afinishBlock) {
        [_finishBlock release];
        _finishBlock=[afinishBlock copy];
    }
}
- (void)setFailedBlock:(requestFailedBlock)afailedBlock{
    if (_failedBlock!=afailedBlock) {
        [_failedBlock release];
        _failedBlock=[afailedBlock copy];
    }
}
- (void)setSuccessBlock:(requestSuccessBlock)asuccessBlock{
    if (_successBlock!=asuccessBlock) {
        [_successBlock release];
        _successBlock=[asuccessBlock copy];
    }
}

- (void)startAsynchronous{
    if (!self.responseData) {
        self.responseData=[NSMutableData data];
    }
    [self.responseData setLength:0];
    if (self.request) {
        [self cancel];//取消前一次请求
        NSURLConnection *conn=[[self class] connectionWithRequest:self.request delegate:self];
        //[[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:YES];
        if (conn) {
            
        }
    }
}
- (void)startSynchronous{
    if (!self.responseData) {
        self.responseData=[NSMutableData data];
    }
    [self.responseData setLength:0];
    if (self.request) {
       [self cancel];//取消前一次请求
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSHTTPURLResponse *response=nil;
            NSError *error=nil;
            NSData *data=[[self class] sendSynchronousRequest:self.request returningResponse:&response error:&error];
            //请求完成
            if (error) {
                self.responseString=@"";
            }else{
                NSString *xml=[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                self.responseString=xml;
                [xml release];
            }
            self.error=error;
            self.responseStatusCode=[response statusCode];
            [self.responseData appendData:data];
            if (self.successBlock) {
                self.successBlock();
            }
        });
    }
}
#pragma mark -
#pragma mark NSURLConnection delegate Methods
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    [self showNetworkActivityIndicator];
    // store data
    [self.responseData setLength:0];      //通常在这里先清空接受数据的缓存
    
    NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
    self.responseStatusCode=[httpResponse statusCode];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [self.responseData appendData:data];    //可能多次收到数据，把新的数据添加在现有数据最后
   
}
- (void)connection:(NSURLConnection *)connection
  didFailWithError:(NSError *)error
{
    [self hideNetworkActivityIndicator];
    self.error=error;
    self.responseString=@"";
    if (self.failedBlock) {
        self.failedBlock();
    }
    connection=nil;
}
- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    [self hideNetworkActivityIndicator];
    NSString *xml=[[NSString alloc] initWithData:self.responseData encoding:NSUTF8StringEncoding];
    self.responseString=xml;
    [xml release];
    self.error=nil;
    if(self.finishBlock)
    {
        self.finishBlock();
    }
    connection=nil;
}
#pragma mark -private Methods
- (NSURLRequest*)requestWithServiceArgs:(ServiceArgs*)args{
    
    NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:args.webURL];
    //头部设置
    [request setAllHTTPHeaderFields:[args headers]];
    //超时设置
    [request setTimeoutInterval:30];
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
