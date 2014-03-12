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

#pragma mark -
#pragma mark 属性重写
-(NSString*)defaultSoapMesage{
    NSString *soapBody=@"<?xml version=\"1.0\" encoding=\"utf-8\"?>\n"
    "<soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">\n"
    "<soap:Body>%@</soap:Body></soap:Envelope>";
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
    if (_serviceNameSpace&&[_serviceNameSpace length]>0) {
        return _serviceNameSpace;
    }
    return defaultWebServiceNameSpace;
}
-(NSString*)soapMessage{
    if (_soapMessage&&[_soapMessage length]>0) {
        return _soapMessage;
    }
    return [self stringSoapMessage:[self soapParams]];
}
-(NSDictionary*)headers{
    if (_headers&&[_headers count]>0) {
        return _headers;
    }
    NSString *soapAction=[self soapAction:[self serviceNameSpace] methodName:[self methodName]];
    NSMutableDictionary *dic=[NSMutableDictionary dictionary];
    [dic setValue:[[self webURL] host] forKey:@"Host"];
    [dic setValue:@"text/xml; charset=utf-8" forKey:@"Content-Type"];
    [dic setValue:[NSString stringWithFormat:@"%d",[[self soapMessage] length]] forKey:@"Content-Length"];
    [dic setValue:soapAction forKey:@"SOAPAction"];
    return dic;
}
#pragma mark -
#pragma mark 公有方法
-(NSString*)stringSoapMessage:(NSArray*)params{
    if (params) {
        NSMutableString *soap=[NSMutableString stringWithFormat:@"<%@ xmlns=\"%@\" >",[self methodName],[self serviceNameSpace]];
        
        [soap appendString:[self paramsFormatString:params]];
        [soap appendFormat:@"</%@>",[self methodName]];
        
        return [NSString stringWithFormat:[self defaultSoapMesage],soap];
    }
    NSString *body=[NSString stringWithFormat:@"<%@ xmlns=\"%@\" />",[self methodName],[self serviceNameSpace]];
    return [NSString stringWithFormat:[self defaultSoapMesage],body];
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
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"/$" options:0 error:nil];
    NSUInteger numberOfMatches = [regex numberOfMatchesInString:namespace options:0 range:NSMakeRange(0, [namespace length])];
    //NSArray *array=[regex matchesInString:namespace options:0 range:NSMakeRange(0, [namespace length])];
    if(numberOfMatches>0){
        return [NSString stringWithFormat:@"%@%@",namespace,methodName];
    }
    return [NSString stringWithFormat:@"%@/%@",namespace,methodName];
}
@end
