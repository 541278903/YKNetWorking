//
//  YKNetWorking.h
//  YYKPodLib_Sec
//
//  Created by edward on 2020/6/21.
//  Copyright © 2020 edward. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YKNetworkRequest.h"
#import "YKNetworkResponse.h"
#import "YKBaseNetWorking.h"
#import "YKNetWorkingConst.h"


@protocol YKNetWorkingDelegate <NSObject>

@optional
/// 可设置缓存内容
/// @warning 需要开启缓存开关yk_isCache
/// @param request 请求
/// @param resonse 响应
/// @param isException 是否报错
- (void)cacheRequest:(YKNetworkRequest * _Nullable)request resonse:(YKNetworkResponse * _Nullable)resonse isException:(BOOL)isException;


@end

NS_ASSUME_NONNULL_BEGIN

@interface YKNetWorking : NSObject


#pragma mark ----------------------只读属性-----------------------------
/**
 存储网络请求的字典
 */
@property (nonatomic, strong, readonly) NSMutableDictionary *requestDictionary;

#pragma mark ----------------------可写属性-----------------------------

@property (nonatomic, strong) YKNetworkRequest *request;

/** 通用请求头 */
@property (nonatomic, copy) NSDictionary *commonHeader;

/** 通用参数 */
@property (nonatomic, copy) NSDictionary *commonParams;

/** 接口前缀 */
@property (nonatomic, copy) NSString *prefixUrl;

/** 忽略Config中配置的默认请求头 */
@property (nonatomic, assign) BOOL ignoreDefaultHeader;

/** 忽略Config中配置的默认请求参数 */
@property (nonatomic, assign) BOOL ignoreDefaultParams;

/// 根据需求处理回调信息判断是否是正确的回调 即中转统一处理源数据
@property (nonatomic, copy) NSError *(^handleResponse)(YKNetworkResponse *response,YKNetworkRequest *request);

/**
 动态参数的配置，每次执行请求都会加上这次的参数
 */
@property (nonatomic, copy) NSDictionary *(^dynamicParamsConfig)(YKNetworkRequest *request);

/**
 动态请求头的配置，每次执行请求都会加上这次的请求头
 */
@property (nonatomic, copy) NSDictionary *(^dynamicHeaderConfig)(YKNetworkRequest *request);

///代理器
@property (nonatomic, weak) id<YKNetWorkingDelegate> delegate;

#pragma mark ----------------------可调用方法-----------------------------
/// 构造
/// @param defaultHeader 默认请求头文件
/// @param defaultParams 默认请求参数
/// @param prefixUrl 默认地址前缀
/// @param handleResponse 默认请求处理方法
- (instancetype)initWithDefaultHeader:(NSDictionary<NSString *,NSString *> * _Nullable)defaultHeader  defaultParams:(NSDictionary * _Nullable)defaultParams prefixUrl:(NSString * _Nullable)prefixUrl handleResponse:(NSError *(^ _Nullable)(YKNetworkResponse *response,YKNetworkRequest *request) )handleResponse;

/// 请求地址
- (YKNetWorking * (^)(NSString *url))url;

/// 请求参数
- (YKNetWorking * (^)(NSDictionary *_Nullable params))params;

/// 请求头
- (YKNetWorking * (^)(NSDictionary *_Nullable headers))headers;

/// 请求模式
- (YKNetWorking * (^)(YKNetworkRequestMethod metohd))method;

/// 本次请求不启用动态参数
- (YKNetWorking *)disableDynamicParams;

/// 本次请求不启用动态请求头
- (YKNetWorking *)disableDynamicHeader;

/// 本次请求不使用集中处理数据方式
- (YKNetWorking *)disableHandleResponse;

/// 最短的重复请求时间间隔
- (YKNetWorking * (^)(float timeInterval))minRepeatInterval;

/// 需要使用uploadDataSignal进行上传数据
- (YKNetWorking * (^)(NSData *data,NSString *fileName,NSString *mimeType))uploadData;

/// 文件上传/下载进度
- (YKNetWorking * (^)(void(^handleProgress)(float progress)))progress;

/// 下载目的路径
- (YKNetWorking *(^)(NSString *destPath))downloadDestPath;

/// 虚拟回调 设置虚拟回调则原本的请求则不会进行请求直接返回虚拟内容
- (YKNetWorking *(^)(id mockData))mockData;

/** 请求体类型 默认二进制形式 */
- (YKNetWorking * (^)(YKNetworkRequestParamsType paramsType))paramsType;

/// 上传二进制的内容
- (YKNetWorking *(^)(NSString *fileField))fileFieldName;

/// 返回内容的格式
- (YKNetWorking *(^)(YKNetworkResponseType type))responseType;

/// 取消当前所有请求
- (void)cancelAllRequest;

- (void)cancelRequestWithName:(NSString *)name;

/**
 处理AF请求体,普通情况下无需调用,有特殊需求时才需要拦截AF的请求体进行修改
 */
- (void)handleRequestSerialization:(AFHTTPRequestSerializer *(^)(AFHTTPRequestSerializer *serializer))requestSerializerBlock;

/**
 处理AF响应体,普通情况下无需调用,有特殊需求时才需要拦截AF的响应体进行修改
 */
- (void)handleResponseSerialization:(AFHTTPResponseSerializer *(^)(AFHTTPResponseSerializer *serializer))responseSerializerBlock;




#pragma mark -----------非响应式编程可用以下调用常规方法------------

- (void)execute;


@end


NS_ASSUME_NONNULL_END


#if __has_include("YKNetWorking/YKBlockTrampoline.h")
#import "YKNetWorking/YKBlockTrampoline.h"
#endif

#if __has_include("YKNetWorking/YKNetWorking+RACExtension.h")
#import "YKNetWorking/YKNetWorking+RACExtension.h"
#endif
