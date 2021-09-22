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


@interface YKNetWorking()
/**
 存储网络请求的字典
 */
@property (nonatomic, strong) NSMutableDictionary *requestDictionary;

@property (nonatomic, strong)AFNetworkReachabilityManager *AfManager;

@property (nonatomic, strong)AFHTTPSessionManager *manager;
/**当前状态*/
@property (nonatomic, assign) AFNetworkReachabilityStatus networkStatus;
/** 公用头部 */
@property (nonatomic, copy) NSDictionary *defaultHeader;
/** 公用参数 */
@property (nonatomic, copy) NSDictionary *defaultParams;

@property (nonatomic, strong) YKNetworkRequest *request;

@property (nonatomic, strong) YKNetworkResponse *response;

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

- (instancetype)initWithDefaultHeader:(NSDictionary<NSString *,NSString *> *)defaultHeader  defaultParams:(NSDictionary *)defaultParams  prefixUrl:(NSString *)prefixUrl
{
    self = [self init];
    if (self) {
        self.defaultHeader = defaultHeader;
        self.defaultParams = defaultParams;
        self.prefixUrl = prefixUrl;
    }
    return self;
}

- (instancetype)initWithDefaultHeader:(NSDictionary<NSString *,NSString *> * _Nullable)defaultHeader  defaultParams:(NSDictionary * _Nullable)defaultParams prefixUrl:(NSString * _Nullable)prefixUrl andHandleResponse:(NSError *(^ _Nullable)(YKNetworkResponse *response,YKNetworkRequest *request))handleResponse
{
    self = [self initWithDefaultHeader:defaultHeader defaultParams:defaultHeader prefixUrl:prefixUrl];
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
        if(!self.ignoreDefaultHeader&&self.defaultHeader)
        {
            [_request.header setValuesForKeysWithDictionary:self.defaultHeader];//MARK:设置默认请求参数
        }
        if(!self.ignoreDefaultParams&&self.defaultParams)
        {
            [_request.params setValuesForKeysWithDictionary:self.defaultParams];//MARK:设置默认请求参数
        }
        if(self.commonHeader)
        {
            [_request.header setValuesForKeysWithDictionary:self.commonHeader];
        }
        if(self.commonParams)
        {
            [_request.params setValuesForKeysWithDictionary:self.commonParams];
        }
        
        
    }
    return _request;
}

- (YKNetWorking * _Nullable (^)(NSDictionary * _Nullable))params
{
    return ^YKNetWorking *(NSDictionary *params){
        if (params) {
            NSMutableDictionary *reqParams = [NSMutableDictionary dictionaryWithDictionary:params];
            [self.request.params setValuesForKeysWithDictionary:reqParams];
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

- (RACSignal<RACTuple *> *)executeSignal
{
    YKNetworkRequest *request = [self.request copy];
    BOOL canContinue = [self handleConfigWithRequest:request];
    if (!canContinue) {
        self.request = nil;
        return [RACSignal empty];
    }
    __weak typeof(self) weakSelf = self;
    RACSignal *singal = [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
        __strong typeof(weakSelf) strongself = weakSelf;
        [YKBaseNetWorking requestWithRequest:request progressBlock:^(float progress) {
            if (request.progressBlock) {
                request.progressBlock(progress);
            }
        } successBlock:^(YKNetworkResponse * _Nonnull response, YKNetworkRequest * _Nonnull request) {\
            NSError *error = nil;
            if(strongself.handleResponse && !request.disableHandleResponse)
            {
                error = strongself.handleResponse(response,request);
                if (!error) {
                    [subscriber sendNext:RACTuplePack(request,response)];
                }else{
                    [subscriber sendError:error];
                }
            }else{
                [subscriber sendNext:RACTuplePack(request,response)];
            }
            [self saveTask:request response:response isException:(error != nil)];
            [subscriber sendCompleted];
        } failureBlock:^(YKNetworkRequest * _Nonnull request, BOOL isCache, id  _Nullable responseObject, NSError * _Nonnull error) {
            YKNetworkResponse *response = [[YKNetworkResponse alloc] init];
            if ([strongself handleError:request response:response isCache:isCache error:error]) {
                if (strongself.handleResponse && responseObject) {
                    response.rawData = responseObject;
                    NSError *error = strongself.handleResponse(response,request);
                    if (error) {
                        [subscriber sendError:error];
                    }
                }else{
                    [subscriber sendError:error];
                }
            }
            [strongself saveTask:request response:response isException:YES];
            [subscriber sendCompleted];
        }];
        strongself.request = nil;
        
        return nil;
    }];
    return singal;
}

- (RACSignal *)executeRowDataSignal
{
    return self.executeSignal.mapWithRawData;
}

- (RACSignal<RACTuple *> *)uploadDataSignal
{
    YKNetworkRequest *request = [self.request copy];
    BOOL canContinue = [self handleConfigWithRequest:request];
    if (!canContinue) {
        self.request = nil;
        return [RACSignal empty];
    }
    
    
    
    __weak typeof(self) weakSelf = self;
    RACSignal *singal = [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
        __strong typeof(weakSelf) strongself = weakSelf;
        request.task = [YKBaseNetWorking uploadTaskWith:request uploadProgressBlock:^(float progress) {
            if (request.progressBlock) {
                request.progressBlock(progress);
            }
        } success:^(YKNetworkResponse * _Nonnull response, YKNetworkRequest * _Nonnull request) {
            NSError *error = nil;
            if (strongself.handleResponse && !request.disableHandleResponse) {
                error = strongself.handleResponse(response,request);
                if (error) {
                    [subscriber sendError:error];
                }else{
                    [subscriber sendNext:RACTuplePack(request,response)];
                }
            }else{
                [subscriber sendNext:RACTuplePack(request,response)];
            }
            [strongself saveTask:request response:response isException:(error != nil)];
            [subscriber sendCompleted];
        } failure:^(YKNetworkRequest * _Nonnull request, BOOL isCache, id  _Nullable responseObject, NSError * _Nonnull error) {
            YKNetworkResponse *response = [[YKNetworkResponse alloc] init];
            if ([strongself handleError:request response:response isCache:isCache error:error]) {
                if (strongself.handleResponse && responseObject) {
                    response.rawData = responseObject;
                    NSError *error = strongself.handleResponse(response,request);
                    if (error) {
                        [subscriber sendError:error];
                    }
                }else{
                    [subscriber sendError:error];
                }
            }
            [strongself saveTask:request response:response isException:YES];
            [subscriber sendCompleted];
        }];
        
        strongself.request = nil;
        return nil;
    }];
    return singal;
}

- (RACSignal *)uploadDataRowDataSignal
{
    return self.uploadDataSignal.mapWithRawData;
}

/// 执行下载信号
- (RACSignal<RACTuple *> *)downloadDataSignal
{
    YKNetworkRequest *request = [self.request copy];
    BOOL canContinue = [self handleConfigWithRequest:request];
    if (!canContinue) {
        self.request = nil;
        return [RACSignal empty];
    }
    __weak typeof(self) weakSelf = self;
    RACSignal *singal = [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
        __strong typeof(weakSelf) strongself = weakSelf;
        
        [YKBaseNetWorking downloadTaskWith:request downloadProgressBlock:^(float progress) {
            if (request.progressBlock) {
                request.progressBlock(progress);
            }
        } success:^(YKNetworkResponse * _Nonnull response, YKNetworkRequest * _Nonnull request) {
            NSError *error = nil;
            if (strongself.handleResponse && !request.disableHandleResponse) {
                error = strongself.handleResponse(response,request);
                if (error) {
                    [subscriber sendError:error];
                }else{
                    [subscriber sendNext:RACTuplePack(request,response)];
                }
                [strongself saveTask:request response:response isException:(error != nil)];
                [subscriber sendCompleted];
            }else{
                
            }
        } failure:^(YKNetworkRequest * _Nonnull request, BOOL isCache, id  _Nullable responseObject, NSError * _Nonnull error) {
            YKNetworkResponse *response = [[YKNetworkResponse alloc] init];
            if ([strongself handleError:request response:response isCache:isCache error:error]) {
                if (strongself.handleResponse && responseObject) {
                    response.rawData = responseObject;
                    NSError *error = strongself.handleResponse(response,request);
                    if (error) {
                        [subscriber sendError:error];
                    }
                }else{
                    [subscriber sendError:error];
                }
            }
            [strongself saveTask:request response:response isException:YES];
            [subscriber sendCompleted];
        }];
        
        
        strongself.request = nil;
        return nil;
    }];
    return singal;
}

- (RACSignal *)downloadDataRowDataSignal
{
    return self.downloadDataSignal.mapWithRawData;
}

+ (void)executeByMethod:(YKNetworkRequestMethod )method url:(NSString *)url params:(NSDictionary * _Nullable)params ComplateBlock:(complateBlockType)complateBlock
{
    if (complateBlock) {
        [[[[YKNetWorking alloc] init].url(url).method(method).disableDynamicParams.disableDynamicHeader.disableHandleResponse.params(params).executeSignal.mapWithRawData doError:^(NSError * _Nonnull error) {
            complateBlock(nil,error);
        }] subscribeNext:^(id  _Nullable x) {
            complateBlock(x,nil);
        }];
    }
}

+ (void)getUrl:(NSString *)url params:(NSDictionary * _Nullable)params ComplateBlock:(complateBlockType)complateBlock
{
    [YKNetWorking executeByMethod:YKNetworkRequestMethodGET url:url params:params ComplateBlock:complateBlock];
}

+ (void)postUrl:(NSString *)url params:(NSDictionary * _Nullable)params ComplateBlock:(complateBlockType)complateBlock
{
    [YKNetWorking executeByMethod:YKNetworkRequestMethodPOST url:url params:params ComplateBlock:complateBlock];
}

+ (void)uploadToUrl:(NSString *)url params:(NSDictionary * _Nullable)params data:(NSData *)data filename:(NSString *)filename mimeType:(NSString *)mimeType progress:(progressBlockType)progress complateBlock:(complateBlockType)complateBlock
{
    [[[[YKNetWorking alloc] init].post(url).disableDynamicParams.disableDynamicHeader.disableHandleResponse.params(params).progress(progress).uploadData(data,filename,mimeType).uploadDataSignal.mapWithRawData doError:^(NSError * _Nonnull error) {
        complateBlock(nil,error);
    }] subscribeNext:^(id  _Nullable x) {
        complateBlock(x,nil);
    }];
}

+ (void)downloadFromUrl:(NSString *)fromUrl localUrl:(NSString *)localUrl progress:(progressBlockType)progress complateBlock:(complateBlockType)complateBlock
{
    if (complateBlock) {
        [[[[YKNetWorking alloc] init].url(fromUrl).downloadDestPath(localUrl).progress(progress).downloadDataSignal.mapWithRawData doError:^(NSError * _Nonnull error) {
            complateBlock(nil,error);
        }] subscribeNext:^(id  _Nullable x) {
            complateBlock(x,nil);
        }];
    }
}

- (BOOL)handleConfigWithRequest:(YKNetworkRequest *)request
{
    //TODO:设置请求内容  (暂)
    if (!request.name || request.name.length == 0) {
        request.name = [NSUUID UUID].UUIDString;
    }
    YKNetworkRequest *requestCopy = [request copy];
    
//    [self configWithRequest:requestCopy];
    
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
    
    if (!self.handleResponse && config.handleResponse) {
        //优先使用本对象定义的
        self.handleResponse = config.handleResponse;
    }
    
    request.startTimeInterval = [[NSDate date] timeIntervalSince1970];
    
    [self.requestDictionary setObject:request forKey:request.name];
    
    return YES;
}

- (BOOL)handleError:(YKNetworkRequest *)request response:(YKNetworkResponse *)response isCache:(BOOL)isCache error:(NSError *)error
{
    
    //MARK:发生错误时对错误进行处理
    
    return YES;
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
