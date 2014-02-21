//
//  ViewController.m
//  URLConnectionServicesDemo
//
//  Created by aJia on 2014/2/21.
//  Copyright (c) 2014年 lz. All rights reserved.
//

#import "ViewController.h"
#import "NSURLConnectionManager.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	//使用说明，请查看＝＝＝＝》使用说明.rtf
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
    
    NSURLConnectionManager *manager=[NSURLConnectionManager requestWithArgs:args];
    [manager setSuccessBlock:^(ServiceRequestResult *result, NSError *error) {
        if (error) {
            NSLog(@"同步请求失败，失败原因=%@",error.description);
            return;
        }
        NSLog(@"同步请求成功，请求结果为=%@",result.xmlString);
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
    
    NSURLConnectionManager *manager=[NSURLConnectionManager requestWithArgs:args];
    [manager setFinishBlock:^(ServiceRequestResult *result) {
        NSLog(@"异步请求成功，请求结果为=%@",result.xmlString);
    }];
    [manager setFailedBlock:^(ServiceRequestResult *result, NSError *error) {
         NSLog(@"异步请求失败，失败原因=%@",error.description);
    }];
    [manager startAsynchronous];//开始异步
}
@end
