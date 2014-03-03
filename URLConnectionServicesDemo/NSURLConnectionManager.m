//
//  NSURLConnectionManager.m
//  IOSWebservices
//
//  Created by aJia on 2014/2/18.
//  Copyright (c) 2014年 rang. All rights reserved.
//

#import "NSURLConnectionManager.h"

@interface NSURLConnectionManager ()
@property (nonatomic,retain) NSMutableData *receiveData;
- (NSURLRequest*)requestWithServiceArgs:(ServiceArgs*)args;
@end

@implementation NSURLConnectionManager
-(void)dealloc{
    [self cancel];
	[super dealloc];
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
    if (!self.receiveData) {
        self.receiveData=[NSMutableData data];
    }
    if (_receiveData) {
        [_receiveData setLength:0];
    }
    if (self.request) {
        [self cancel];//取消前一次请求
        NSURLConnection *conn=[[self class] connectionWithRequest:self.request delegate:self];
        //[[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:YES];
        if (conn) {
            
        }
    }
}
- (void)startSynchronous{
    if (self.request) {
       [self cancel];//取消前一次请求
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSURLResponse *response=nil;
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
            if (self.successBlock) {
                self.successBlock();
            }
        });
    }
}
#pragma mark -
#pragma mark NSURLConnection delegate Methods
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    // store data
    [_receiveData setLength:0];      //通常在这里先清空接受数据的缓存
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [_receiveData appendData:data];    //可能多次收到数据，把新的数据添加在现有数据最后
}
- (void)connection:(NSURLConnection *)connection
  didFailWithError:(NSError *)error
{
    self.error=error;
    self.responseString=@"";
    if (self.failedBlock) {
        self.failedBlock();
    }
    //[connection cancel];
    connection=nil;
}
- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSString *xml=[[NSString alloc] initWithData:self.receiveData encoding:NSUTF8StringEncoding];
    self.responseString=xml;
    [xml release];
    self.error=nil;
    if(self.finishBlock)
    {
        self.finishBlock();
    }
    connection=nil;
    //[_receiveData setLength:0];//清空
}
#pragma mark -private Methods
- (NSURLRequest*)requestWithServiceArgs:(ServiceArgs*)args{
    
    NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:args.webURL];
    //头部设置
    [request setAllHTTPHeaderFields:[args headers]];
    //超时设置
    [request setTimeoutInterval: 30 ];
    //访问方式
    [request setHTTPMethod:@"POST"];
    //body内容
    [request setHTTPBody:[args.soapMessage dataUsingEncoding:NSUTF8StringEncoding]];
    return request;
}
@end
