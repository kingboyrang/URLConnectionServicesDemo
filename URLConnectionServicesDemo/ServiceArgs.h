//
//  ServiceArgs.h
//  CommonLibrary
//
//  Created by aJia on 13/2/20.
//  Copyright (c) 2013年 rang. All rights reserved.
//

#import <Foundation/Foundation.h>
//请求方式
typedef enum{
    ServiceHttpGet=0,
    ServiceHttpPost=1,
    ServiceHttpSoap=2
}ServiceHttpWay;

@interface ServiceArgs : NSObject
@property(nonatomic,copy) NSString *serviceURL;//webservice访问地址
@property(nonatomic,readonly) NSURL *webURL;
@property(nonatomic,copy) NSString *serviceNameSpace;//webservice命名空间
@property(nonatomic,copy) NSString *methodName;
@property(nonatomic,copy) NSString *soapMessage;//soap字符串
@property(nonatomic,copy) NSString *soapHeader;//有认证的请求头设置
@property(nonatomic,retain) NSDictionary *headers;
@property(nonatomic,assign) ServiceHttpWay httpWay;//请求方式,默认为soap请求
@property(nonatomic,readonly) NSURLRequest *request;
//soapMessage处理
@property(nonatomic,readonly) NSString *defaultSoapMesage;
@property(nonatomic,retain) NSArray *soapParams;//参数设置

-(NSString*)stringSoapMessage:(NSArray*)params;
+(ServiceArgs*)serviceMethodName:(NSString*)methodName;
+(ServiceArgs*)serviceMethodName:(NSString*)methodName soapMessage:(NSString*)soapMsg;
//webservice访问设置
+(void)setNameSapce:(NSString*)space;
+(void)setWebServiceURL:(NSString*)url;
@end
