//
//  ServiceArgs.m
//  CommonLibrary
//
//  Created by aJia on 13/2/20.
//  Copyright (c) 2013年 rang. All rights reserved.
//

#import "ServiceArgs.h"

@interface ServiceArgs()
-(NSString*)paramsFormatString:(NSArray*)params;
-(NSString*)soapAction:(NSString*)namespace methodName:(NSString*)methodName;
-(NSString*)paramsTostring;
-(NSURL*)requestURL;
@end

static NSString *defaultWebServiceUrl=@"http://webservice.webxml.com.cn/webservices/qqOnlineWebService.asmx";
static NSString *defaultWebServiceNameSpace=@"http://WebXml.com.cn/";

@implementation ServiceArgs

+(void)setWebServiceURL:(NSString*)url
{
    if (defaultWebServiceUrl!=url) {
        [defaultWebServiceUrl release];
        defaultWebServiceUrl=[url retain];
    }
}
+(void)setNameSapce:(NSString*)space
{
    if (defaultWebServiceNameSpace!=space) {
        [defaultWebServiceNameSpace release];
        defaultWebServiceNameSpace=[space retain];
    }
}
-(id)init{
    if (self=[super init]) {
        self.httpWay=ServiceHttpSoap;
    }
    return self;
}
#pragma mark -
#pragma mark 属性重写
-(NSString*)defaultSoapMesage{
    NSString *soapBody=@"<?xml version=\"1.0\" encoding=\"utf-8\"?>\n"
    "<soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">\n"
    "<soap:Header>%@</soap:Header><soap:Body>%@</soap:Body></soap:Envelope>";
    return soapBody;
}
-(NSURL*)webURL{
    return [NSURL URLWithString:[self serviceURL]];
}
-(NSString*)serviceURL{
    if (_serviceURL&&[_serviceURL length]>0) {
        return _serviceURL;
    }
    return defaultWebServiceUrl;
}
-(NSString*)serviceNameSpace{
    if (_serviceNameSpace) {
        return _serviceNameSpace;
    }
    return defaultWebServiceNameSpace;
}
-(NSString*)soapMessage{
    if (_soapMessage&&[_soapMessage length]>0) {
        return _soapMessage;
    }
    if (self.httpWay==ServiceHttpPost) {
        return [self paramsTostring];
    }
    return [self stringSoapMessage:[self soapParams]];
}
-(NSDictionary*)headers{
    if (_headers&&[_headers count]>0) {
        return _headers;
    }
    if (self.httpWay==ServiceHttpGet) {
        return [NSDictionary dictionaryWithObjectsAndKeys:[self.webURL host],@"Host", nil];
    }
    if (self.httpWay==ServiceHttpPost) {
        NSMutableDictionary *dic=[NSMutableDictionary dictionary];
        [dic setValue:[[self webURL] host] forKey:@"Host"];
        [dic setValue:@"application/x-www-form-urlencoded" forKey:@"Content-Type"];
        [dic setValue:[NSString stringWithFormat:@"%d",[[self soapMessage] length]] forKey:@"Content-Length"];
        return dic;
    }
    NSString *soapAction=[self soapAction:[self serviceNameSpace] methodName:[self methodName]];
    NSMutableDictionary *dic=[NSMutableDictionary dictionary];
    [dic setValue:[[self webURL] host] forKey:@"Host"];
    [dic setValue:@"text/xml; charset=utf-8" forKey:@"Content-Type"];
    [dic setValue:[NSString stringWithFormat:@"%d",[[self soapMessage] length]] forKey:@"Content-Length"];
    if ([soapAction length]>0) {
         [dic setValue:soapAction forKey:@"SOAPAction"];
    }
    return dic;
}
- (NSURLRequest*)request{
    NSMutableURLRequest *req=[NSMutableURLRequest requestWithURL:[self requestURL]];
    //头部设置
    [req setAllHTTPHeaderFields:[self headers]];
    //超时设置
    [req setTimeoutInterval:60];
    //访问方式
    if (self.httpWay==ServiceHttpGet) {
        [req setHTTPMethod:@"GET"];
    }else{
        [req setHTTPMethod:@"POST"];
    }
    //body内容
    if (self.httpWay!=ServiceHttpGet) {
        [req setHTTPBody:[self.soapMessage dataUsingEncoding:NSUTF8StringEncoding]];
    }
    return req;
}
#pragma mark -
#pragma mark 公有方法
-(NSString*)stringSoapMessage:(NSArray*)params{
    NSString *header=_soapHeader&&[_soapHeader length]>0?_soapHeader:@"";
    NSString *xmlnsStr=[[self serviceNameSpace] length]>0?[NSString stringWithFormat:@" xmlns=\"%@\"",[self serviceNameSpace]]:@"";

    if (params) {
        NSMutableString *soap=[NSMutableString stringWithFormat:@"<%@%@>",[self methodName],xmlnsStr];
        
        [soap appendString:[self paramsFormatString:params]];
        [soap appendFormat:@"</%@>",[self methodName]];
        return [NSString stringWithFormat:[self defaultSoapMesage],header,soap];
    }
    NSString *body=[NSString stringWithFormat:@"<%@%@ />",[self methodName],xmlnsStr];
    return [NSString stringWithFormat:[self defaultSoapMesage],header,body];
}
+(ServiceArgs*)serviceMethodName:(NSString*)methodName{
    return [self serviceMethodName:methodName soapMessage:nil];
}
+(ServiceArgs*)serviceMethodName:(NSString*)name soapMessage:(NSString*)msg{
    ServiceArgs *args=[[[ServiceArgs alloc] init] autorelease];
    args.methodName=name;
    if (msg&&[msg length]>0) {
        args.soapMessage=msg;
    }else{
        args.soapMessage=[args stringSoapMessage:nil];
    }
    return args;
}
#pragma mark -
#pragma mark 私有方法
-(NSURL*)requestURL{
    if (self.httpWay==ServiceHttpSoap) {
        return [self webURL];
    }
    if (self.httpWay==ServiceHttpGet) {
        NSString *params=[self paramsTostring];
        NSString *str=[params length]>0?[NSString stringWithFormat:@"?%@",params]:@"";
        NSString *result=[NSString stringWithFormat:@"%@/%@%@",[self serviceURL],[self methodName],str];
        return [NSURL URLWithString:result];
    }
    return [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@",[self serviceURL],[self methodName]]];
}
-(NSString*)paramsTostring
{
    NSArray *arr=[self soapParams];
    if (arr&&[arr count]>0) {
        NSMutableArray *results=[NSMutableArray array];
        for (NSDictionary *item in arr) {
             NSString *key=[[item allKeys] objectAtIndex:0];
            [results addObject:[NSString stringWithFormat:@"%@=%@",key,[item objectForKey:key]]];
        }
        return [results componentsJoinedByString:@"&"];
    }
    return @"";
}
-(NSString*)paramsFormatString:(NSArray*)params{
    NSMutableString *xml=[NSMutableString stringWithFormat:@""];
    for (NSDictionary *item in params) {
        NSString *key=[[item allKeys] objectAtIndex:0];
        [xml appendFormat:@"<%@>",key];
        [xml appendString:[item objectForKey:key]];
        [xml appendFormat:@"</%@>",key];
    }
    return xml;
}
-(NSString*)soapAction:(NSString*)namespace methodName:(NSString*)methodName{
    if (namespace&&[namespace length]>0) {
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"/$" options:0 error:nil];
        NSUInteger numberOfMatches = [regex numberOfMatchesInString:namespace options:0 range:NSMakeRange(0, [namespace length])];
        //NSArray *array=[regex matchesInString:namespace options:0 range:NSMakeRange(0, [namespace length])];
        if(numberOfMatches>0){
            return [NSString stringWithFormat:@"%@%@",namespace,methodName];
        }
        return [NSString stringWithFormat:@"%@/%@",namespace,methodName];
    }
    return @"";
}
@end
