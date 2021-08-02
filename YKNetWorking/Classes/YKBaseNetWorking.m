//
//  YKBaseNetWorking.m
//  YKNetWorking
//
//  Created by edward on 2021/8/2.
//

#import "YKBaseNetWorking.h"
#import "YKNetworkingConfig.h"
#import <AFNetworking/AFNetworking.h>

@interface YKBaseNetWorking ()

@end

@implementation YKBaseNetWorking

+ (NSURLSessionDataTask *)executeTaskWith:(YKNetworkRequest *)request complateBlock:(complateBlockType)complate
{
    
    [YKBaseNetWorking configWithRequest:request];
    
    NSError *serializationError = nil;
    NSMutableURLRequest *req = [[AFHTTPSessionManager manager].requestSerializer requestWithMethod:request.methodStr URLString:request.urlStr parameters:request.params error:&serializationError];
    
    if (serializationError != nil) {
        if (complate) {
            complate(nil,serializationError);
        }
    }
    
    __block NSURLSessionDataTask *dataTask = nil;
    
    return nil;
}

+ (void)configWithRequest:(YKNetworkRequest *)request
{
    AFHTTPRequestSerializer *requestSerializer;
    
    if (request.paramsType == YKNetworkResponseTypeJSON) {
        requestSerializer = [AFJSONRequestSerializer serializer];
    }else{
        requestSerializer = [AFHTTPRequestSerializer serializer];
    }
    
    
    if (request.header && request.header.count > 0) {
        [request.header enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, NSString * _Nonnull obj, BOOL * _Nonnull stop) {
            [requestSerializer setValue:obj forHTTPHeaderField:key];
        }];
    }
    
    double timeoutInterval = [YKNetworkingConfig defaultConfig].timeoutInterval;
    if (timeoutInterval != 0) {
        requestSerializer.timeoutInterval = timeoutInterval;
    }else
    {
        requestSerializer.timeoutInterval = 60;
    }
    
    //设置请求内容
    if (request.requestSerializerBlock) {
        [AFHTTPSessionManager manager].requestSerializer = request.requestSerializerBlock(requestSerializer);
    }else{
        [AFHTTPSessionManager manager].requestSerializer = requestSerializer;
    }
    
    // 直接支持多种格式的返回
    [AFHTTPSessionManager manager].responseSerializer = [AFCompoundResponseSerializer compoundSerializerWithResponseSerializers:@[
        [AFJSONResponseSerializer serializer],
        [AFImageResponseSerializer serializer],
        [AFHTTPResponseSerializer serializer],
        [AFPropertyListResponseSerializer serializer],
        [AFXMLParserResponseSerializer serializer]
    ]];
}

@end
