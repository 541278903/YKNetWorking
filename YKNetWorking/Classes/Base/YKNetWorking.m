//
//  YKNetWorking.m
//  YYKPodLib_Sec
//
//  Created by edward on 2020/6/21.
//  Copyright © 2020 edward. All rights reserved.
//

#import "YKNetWorking.h"
#import "YKNetworkingConfig.h"
#import <AFNetworking/AFNetworking.h>
#import "YKNetWorking+BasePrivate.h"


@interface YKNetWorking()
/**
 存储网络请求的字典
 */
@property (nonatomic, strong, readwrite) NSMutableDictionary *requestDictionary;

@property (nonatomic, strong)AFNetworkReachabilityManager *AfManager;

@property (nonatomic, strong)AFHTTPSessionManager *manager;
/**当前状态*/
@property (nonatomic, assign) AFNetworkReachabilityStatus networkStatus;

@property (nonatomic, strong) YKNetworkResponse *response;
///
@property (nonatomic, strong) NSDictionary *inputHeaders;
///
@property (nonatomic, strong) NSDictionary *inputParams;

@end

@implementation YKNetWorking

/**显示网络请求日志----debug*/

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.AfManager = [AFNetworkReachabilityManager sharedManager];
        self.manager.responseSerializer = [AFHTTPResponseSerializer serializer];
        //设置参数类型ContentTypes，在后面的array中添加形式即可，最终会转成nsset
        self.manager.responseSerializer.acceptableContentTypes = [NSSet setWithArray:@[@"text/plain",@"text/xml",@"application/json",@"application/octet-stream",@"multipart/form-data"]];
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            [[AFNetworkReachabilityManager sharedManager] startMonitoring];
            [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
                [[NSNotificationCenter defaultCenter] postNotificationName:kYKNetworking_NetworkStatus object:nil userInfo:@{@"status":@(status)}];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"toConfig" object:nil userInfo:@{@"status":@(status)}];
            }];
        });
        [YKNetworkingConfig defaultConfig];
    }
    return self;
}

- (instancetype)initWithCommonHeader:(NSDictionary<NSString *,NSString *> *)commonHeader  commonParams:(NSDictionary *)commonParams  prefixUrl:(NSString *)prefixUrl
{
    self = [self init];
    if (self) {
        self.commonHeader = commonHeader;
        self.commonParams = commonParams;
        self.prefixUrl = prefixUrl;
    }
    return self;
}

- (instancetype)initWithDefaultHeader:(NSDictionary<NSString *,NSString *> * _Nullable)defaultHeader  defaultParams:(NSDictionary * _Nullable)defaultParams prefixUrl:(NSString * _Nullable)prefixUrl handleResponse:(NSError *(^ _Nullable)(YKNetworkResponse *response,YKNetworkRequest *request))handleResponse
{
    self = [self initWithCommonHeader:defaultHeader commonParams:defaultHeader prefixUrl:prefixUrl];
    if (self) {
        self.handleResponse = handleResponse;
    }
    return self;
}


- (YKNetWorking * _Nonnull (^)(YKNetworkRequestMethod))method
{
    return ^YKNetWorking *(YKNetworkRequestMethod method){
        self.request.method = method;
        return self;
    };
}

- (YKNetWorking * _Nonnull (^)(NSString * _Nonnull))url
{
    return ^YKNetWorking *(NSString *url){
        NSString *urlStr;
        
        NSString *utf8Url = [url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet characterSetWithCharactersInString:@"`#%^{}\"[]|\\<> "].invertedSet];

        if ([url hasPrefix:@"http://"] || [url hasPrefix:@"https://"]) {
            self.request.urlStr = utf8Url;
            return self;
        }        // 优先自己的前缀
        NSString *prefix = self.prefixUrl?:[YKNetworkingConfig defaultConfig].defaultPrefixUrl?:@"";
        if (!prefix || prefix.length == 0) {
            self.request.urlStr = utf8Url;
            return self;
        }
        // 处理重复斜杠的问题
        NSString *removeSlash;
        if(prefix.length > 0 && utf8Url.length > 0) {
            NSString *lastCharInPrefix = [prefix substringFromIndex:prefix.length - 1];
            NSString *firstCharInUrl = [utf8Url substringToIndex:1];
            if ([lastCharInPrefix isEqualToString:@"/"] &&
                [firstCharInUrl isEqualToString:@"/"]) {
                removeSlash = [prefix substringToIndex:prefix.length - 1];
            }
        }
        if (removeSlash) {
            prefix = removeSlash;
        }
        urlStr = [NSString stringWithFormat:@"%@%@",prefix,utf8Url];
        self.request.urlStr = urlStr;
        return self;
    };
}

- (YKNetworkRequest *)request
{
    if(!_request)
    {
        _request = [[YKNetworkRequest alloc]init];
        if(!self.ignoreDefaultHeader) {
            [_request.header setValuesForKeysWithDictionary:[YKNetworkingConfig defaultConfig].defaultHeader];
        }
        if (self.commonHeader) {
            [self.commonHeader enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
                if (![_request.header.allKeys containsObject:key]) {
                    [_request.header setValue:obj forKey:key];
                }
            }];
        }
        if(!self.ignoreDefaultParams) {
            [_request.params setValuesForKeysWithDictionary:[YKNetworkingConfig defaultConfig].defaultParams];
        }
        if(self.commonParams)
        {
            [self.commonParams enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
                if (![_request.params.allKeys containsObject:key]) {
                    [_request.params setValue:obj forKey:key];
                }
            }];
        }
        
        
    }
    return _request;
}

- (YKNetWorking * _Nullable (^)(NSDictionary * _Nullable))params
{
    return ^YKNetWorking *(NSDictionary *params){
        if (params) {
            self.inputParams = params;
            NSMutableDictionary *reqParams = [NSMutableDictionary dictionaryWithDictionary:params];
            [self.request.params setValuesForKeysWithDictionary:reqParams];
        }
        return self;
    };
}

/// 请求头
- (YKNetWorking * (^)(NSDictionary *_Nullable headers))headers
{
    return ^YKNetWorking *(NSDictionary *headers){
        if (headers) {
            self.inputHeaders = headers;
            NSMutableDictionary *reqHeaders = [NSMutableDictionary dictionaryWithDictionary:headers];
            [self.request.header setValuesForKeysWithDictionary:reqHeaders];
        }
        return self;
    };
}

/// 取消默认参数
- (YKNetWorking *)disableDynamicParams
{
    self.request.disableDynamicParams = YES;
    return self;
}

/// 本次请求不使用集中处理数据方式
- (YKNetWorking *)disableHandleResponse
{
    self.request.disableHandleResponse = YES;
    return self;
}

/// 取消默认请求头
- (YKNetWorking *)disableDynamicHeader
{
    self.request.disableDynamicHeader = YES;
    return self;
}

- (YKNetWorking *(^)(float))minRepeatInterval
{
    return ^YKNetWorking *(float repeatInterval) {
        self.request.repeatRequestInterval = repeatInterval;
        return self;
    };
}

- (YKNetWorking *(^)(NSString *))downloadDestPath
{
    return ^YKNetWorking *(NSString *destPath) {
        self.request.destPath = destPath;
        return self;
    };
}

- (YKNetWorking * _Nonnull (^)(NSData * _Nonnull, NSString * _Nonnull, NSString * _Nonnull))uploadData
{
    return ^YKNetWorking *(NSData *data,NSString *filename,NSString * mimeType){
        self.request.uploadFileData = data;
        self.request.uploadName = filename;
        self.request.uploadMimeType = mimeType;
        
        return self;
    };
}

- (YKNetWorking * _Nonnull (^)(void (^ _Nonnull)(float)))progress
{
    return ^YKNetWorking *(void(^progressBlock)(float progress)) {
        self.request.progressBlock = progressBlock;
        return self;
    };
}


/// 虚拟回调 设置虚拟回调则原本的请求则不会进行请求直接返回虚拟内容
- (YKNetWorking * _Nonnull (^)(id _Nonnull mockData))mockData
{
    return ^YKNetWorking *(id _Nonnull mockData){
        self.request.mockData = mockData;
        return self;
    };
}

/** 请求体类型 默认二进制形式 */
- (YKNetWorking * (^)(YKNetworkRequestParamsType paramsType))paramsType {
    return ^YKNetWorking *(YKNetworkRequestParamsType paramsType) {
        self.request.paramsType = paramsType;
        return self;
    };
}

- (YKNetWorking *(^)(NSString *fileField))fileFieldName
{
    return ^YKNetWorking *(NSString *fileField) {
        self.request.fileFieldName = fileField;
        return self;
    };
}

/// 返回内容的格式
- (YKNetWorking *(^)(YKNetworkResponseType type))responseType
{
    return ^YKNetWorking *(YKNetworkResponseType type){
        self.request.responseType = type;
        return self;
    };
}

- (void)handleRequestSerialization:(AFHTTPRequestSerializer *(^)(AFHTTPRequestSerializer *serializer))requestSerializerBlock
{
    if (requestSerializerBlock) {
        self.request.requestSerializerBlock = requestSerializerBlock;
    }
}

/**
 处理AF响应体,普通情况下无需调用,有特殊需求时才需要拦截AF的响应体进行修改
 */
- (void)handleResponseSerialization:(AFHTTPResponseSerializer *(^)(AFHTTPResponseSerializer *serializer))responseSerializerBlock
{
    if (responseSerializerBlock) {
        self.request.responseSerializerBlock = responseSerializerBlock;
    }
}

- (void)execute
{
    
}




- (void)cancelAllRequest
{
    [self.requestDictionary enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, YKNetworkRequest * _Nonnull obj, BOOL * _Nonnull stop) {
        if (obj.task) {
            [obj.task cancel];
        }else if (obj.downloadTask)
        {
            [obj.downloadTask cancel];
        }
    }];
    [self.requestDictionary removeAllObjects];
}

- (void)cancelRequestWithName:(NSString *)name {
    // 移除请求
    if ([self.requestDictionary.allKeys containsObject:name]) {
        YKNetworkRequest *request = [self.requestDictionary objectForKey:name];
        if (request.task) {
            [request.task cancel];
        } else if (request.downloadTask) {
            [request.downloadTask cancel];
        }
        [self.requestDictionary removeObjectForKey:request.name];
    } else {
#ifdef DEBUG
        //
        NSLog(@"请求已经完成或者没有name = %@的请求",name);
#endif
    }
}

- (void)dealloc
{
#ifdef DEBUG
    //
    NSLog(@"📶dealloc:YKNetWorking");
#endif
}

#pragma mark get/set

- (AFHTTPSessionManager *)manager{
    if(!_manager)
    {
        _manager = [AFHTTPSessionManager manager];
    }
    return _manager;
}

- (NSMutableDictionary *)requestDictionary
{
    if (!_requestDictionary) {
        _requestDictionary = [NSMutableDictionary dictionary];
    }
    return _requestDictionary;
}

@end
