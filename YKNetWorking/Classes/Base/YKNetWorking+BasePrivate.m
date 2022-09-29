//
//  YKNetWorking+BasePrivate.m
//  YKNetWorking
//
//  Created by edward on 2022/9/30.
//

#import "YKNetWorking+BasePrivate.h"

@implementation YKNetWorking (BasePrivate)


//MARK: setting

- (BOOL)handleConfigWithRequest:(YKNetworkRequest *)request
{
    //TODO:设置请求内容  (暂)
    if (!request.name || request.name.length == 0) {
        request.name = [NSUUID UUID].UUIDString;
    }
    YKNetworkRequest *requestCopy = [request copy];
    
    YKNetworkingConfig *config = [YKNetworkingConfig defaultConfig];
    
    if (!request.disableDynamicHeader && (self.dynamicHeaderConfig || config.dynamicHeaderConfig)) {
        NSDictionary *(^dynamicHeaderConfig)(YKNetworkRequest *request) = self.dynamicHeaderConfig ?: config.dynamicHeaderConfig;
        NSDictionary *dynamicHeader = dynamicHeaderConfig(requestCopy);
        [dynamicHeader enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            if (![request.header.allKeys containsObject:key]) {
                [request.header setObject:obj forKey:key];
            }
        }];
    }
    if (!request.disableDynamicParams && (self.dynamicParamsConfig || config.dynamicParamsConfig)) {
        NSDictionary *(^dynamicParamsConfig)(YKNetworkRequest *request) = self.dynamicParamsConfig ?: config.dynamicParamsConfig;
        NSDictionary *dynamicParams = dynamicParamsConfig(requestCopy);
        [dynamicParams enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            if (![request.params.allKeys containsObject:key]) {
                [request.params setObject:obj forKey:key];
            }
        }];
    }
    
    request.startTimeInterval = [[NSDate date] timeIntervalSince1970];
    
    [self.requestDictionary setObject:request forKey:request.name];
    
    return YES;
}

- (void)saveTask:(YKNetworkRequest *)request response:(YKNetworkResponse *)response isException:(BOOL)isException
{
    //系统回调执行
    if ([YKNetworkingConfig defaultConfig].cacheRequest)
    {
        [YKNetworkingConfig defaultConfig].cacheRequest(response, request, isException);
    }
    //本类代理回调
    if (self.delegate && [self.delegate respondsToSelector:@selector(cacheRequest:resonse:isException:)])
    {
        [self.delegate cacheRequest:request resonse:response isException:isException];
    }
}

- (BOOL)handleError:(YKNetworkRequest *)request response:(YKNetworkResponse *)response isCache:(BOOL)isCache error:(NSError *)error
{
    
    //MARK:发生错误时对错误进行处理
    
    return YES;
}

@end
