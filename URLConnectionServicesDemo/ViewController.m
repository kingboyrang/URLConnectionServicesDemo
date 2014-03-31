//
//  ViewController.m
//  URLConnectionServicesDemo
//
//  Created by aJia on 2014/2/21.
//  Copyright (c) 2014年 lz. All rights reserved.
//

#import "ViewController.h"
#import "ServiceRequestManager.h"
#import "ServiceOperation.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	//==================>使用说明，请查看＝＝＝＝》使用说明v1.0.rtf
   
    _queue=[[ServiceOperationQueue alloc] init];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
//同步请求
- (IBAction)buttonSyncClick:(id)sender {
    NSLog(@"开始同步请求!");
    NSMutableArray *params=[NSMutableArray array];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"695749595",@"qqCode", nil]];
    
    ServiceArgs *args=[[[ServiceArgs alloc] init] autorelease];
    args.methodName=@"qqCheckOnline";//要调用的webservice方法
    args.soapParams=params;//传递方法参数
   
    ServiceRequestManager *manager=[ServiceRequestManager requestWithArgs:args];
    [manager setSuccessBlock:^() {
        if (manager.error) {
            NSLog(@"同步请求失败，失败原因=%@",manager.error.description);
            return;
        }
        NSLog(@"同步请求成功，请求结果为=%@",manager.responseString);
    }];
    [manager startSynchronous];//开始同步
}
//异步请求
- (IBAction)buttonAsyncClick:(id)sender {
    NSLog(@"开始异步请求!");
    NSMutableArray *params=[NSMutableArray array];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"695749595",@"qqCode", nil]];
    
    ServiceArgs *args=[[[ServiceArgs alloc] init] autorelease];
    args.methodName=@"qqCheckOnline";//要调用的webservice方法
    args.soapParams=params;//传递方法参数
    
    ServiceRequestManager *manager=[ServiceRequestManager requestWithArgs:args];
    [manager setFinishBlock:^() {
        NSLog(@"异步请求成功，请求结果为=%@",manager.responseString);
    }];
    [manager setFailedBlock:^() {
         NSLog(@"异步请求失败，失败原因=%@",manager.error.description);
    }];
    [manager startAsynchronous];//开始异步
}
//队列请法
- (IBAction)buttonQueueClick:(id)sender {
    [_queue reset];
    NSMutableDictionary *websites = [NSMutableDictionary dictionaryWithCapacity:5] ;
    [websites setValue:@"http://www.sina.com.cn" forKey:@"sina"];
    [websites setValue:@"http://www.qq.com" forKey:@"qq"];

    // 添加url请求
    for (int i=0; i < [[websites allKeys] count]; i++) {
        NSString *key  = [[websites allKeys] objectAtIndex:i];
        NSString *urlAsString = [websites valueForKey:key];
        ServiceOperation *operation = [[ServiceOperation alloc] initWithURL:[NSURL URLWithString:urlAsString]];
        [operation setUserInfo:[NSDictionary dictionaryWithObjectsAndKeys:key,@"name", nil]];
        [_queue addOperation:operation]; // operation starts as soon as its added
        [operation release];
    }
    //添加webservice请求1
    ServiceArgs *args1=[[[ServiceArgs alloc] init] autorelease];
    args1.serviceURL=@"http://ibdcloud.com:8083/User_APP.asmx";
    args1.serviceNameSpace=@"http://tempuri.org/";
    args1.methodName=@"DesEncrypt";
    args1.soapParams=[NSArray arrayWithObjects:[NSDictionary dictionaryWithObjectsAndKeys:@"123",@"text", nil], nil];
    ServiceOperation *op1 = [[ServiceOperation alloc] initWithArgs:args1];
    [op1 setUserInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"DesEncrypt",@"name", nil]];
    [_queue addOperation:op1];
    [op1 release];
    
    //添加webservice请求2
    ServiceArgs *args2=[[[ServiceArgs alloc] init] autorelease];
    args2.methodName=@"qqCheckOnline";
    args2.soapParams=[NSArray arrayWithObjects:[NSDictionary dictionaryWithObjectsAndKeys:@"695749595",@"qqCode", nil], nil];
    ServiceOperation *op2 = [[ServiceOperation alloc] initWithArgs:args2];
    [op2 setUserInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"qqCheckOnline",@"name", nil]];
    [_queue addOperation:op2];
    [op2 release];
    
    //每当一个请求完成就会执行这里
    [_queue setFinishBlock:^(ServiceOperation *operation) {
        NSDictionary *dic=[operation userInfo];
        NSLog(@"请求名=%@,请求状态=%d,请求完成!",[dic objectForKey:@"name"],operation.responseStatusCode);
        //NSLog(@"请求返回的结果=%@",operation.responseString);
    }];
    //所有的请求完成就会执行这里
    [_queue setCompleteBlock:^{
         for (ServiceOperation *operation in _queue.items) {
             NSDictionary *dic=[operation userInfo];
             NSLog(@"name=%@",[dic objectForKey:@"name"]);
             NSLog(@"请求返回的结果=%@",operation.responseString);
         }
    }];
}
//下载图片==>注图太小了下载过快，看不出什么效果
- (IBAction)buttonDownloadClick:(id)sender {
    self.labRate.text=@"0%";
    self.progressView.progress=0.0;
    [self.imageView setImage:nil];
    ServiceRequestManager *manager=[ServiceRequestManager requestWithURL:[NSURL URLWithString:@"http://c.hiphotos.baidu.com/image/h%3D1024%3Bcrop%3D0%2C0%2C1280%2C1024/sign=db9c6b4eba0e7bec3cda07e11d1a825b/622762d0f703918f4271428b533d269758eec4cb.jpg"]];
    [manager setProgressBlock:^(long long total, long long size, float rate) {
        NSLog(@"size=%lld",size);
        self.labRate.text=[NSString stringWithFormat:@"%d%%",(int)(rate*100)];
        self.progressView.progress=rate;
    }];
    [manager setFinishBlock:^() {
        UIImage *image=[UIImage imageWithData:manager.responseData];
        [self.imageView setImage:image];
    }];
    [manager setFailedBlock:^() {
        NSLog(@"下载失败，失败原因=%@",manager.error.description);
    }];
    [manager startAsynchronous];//开始异步
}
- (void)dealloc {
    [_imageView release];
    [_labRate release];
    [_progressView release];
    [super dealloc];
}
@end
