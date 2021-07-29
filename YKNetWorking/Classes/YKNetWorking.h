//
//  YKNetWorking.h
//  YYKPodLib_Sec
//
//  Created by edward on 2020/6/21.
//  Copyright © 2020 edward. All rights reserved.
//

//#import ".h"

#import <Foundation/Foundation.h>
#import "YKNetworkRequest.h"
#import "YKNetworkResponse.h"
#import "YKNetworkingConfig.h"
#import "RACSignal+networking.h"
#import "YKBlockTrampoline.h"

#define get(urlStr) url(urlStr).method(YKNetworkRequestMethodGET)
#define post(urlStr) url(urlStr).method(YKNetworkRequestMethodPOST)
#define put(urlStr) url(urlStr).method(YKNetworkRequestMethodPUT)
#define patch(urlStr) url(urlStr).method(YKNetworkRequestMethodPATCH)
#define delete(urlStr) url(urlStr).method(YKNetworkRequestMethodDELETE)

#define GET(urlStr,...)       url(urlStr).method(YKNetworkRequestMethodGET).params(NSDictionaryOfVariableBindings(__VA_ARGS__))
#define POST(urlStr,...)      url(urlStr).method(YKNetworkRequestMethodPOST).params(NSDictionaryOfVariableBindings(__VA_ARGS__))
#define PUT(urlStr,...)       url(urlStr).method(YKNetworkRequestMethodPUT).params(NSDictionaryOfVariableBindings(__VA_ARGS__))
#define DELETE(urlStr,...)    url(urlStr).method(YKNetworkRequestMethodPATCH).params(NSDictionaryOfVariableBindings(__VA_ARGS__))
#define PATCH(urlStr,...)     url(urlStr).method(YKNetworkRequestMethodDELETE).params(NSDictionaryOfVariableBindings(__VA_ARGS__))

#define kNoCacheErrorCode -10992

/// 监听网络状态的通知
#define kYKNetworking_NetworkStatus @"kYKNetworking_NetworkStatus"


//static NSString *kYKNetworking_NetworkStatus = @"kYKNetworking_NetworkStatus";


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


typedef void(^complateBlockType)( id _Nullable responData ,NSError * _Nullable error);

typedef void(^progressBlockType)(float progress);

#pragma mark ----------------------只读属性-----------------------------

#pragma mark ----------------------可写属性-----------------------------

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
- (instancetype)initWithDefaultHeader:(NSDictionary<NSString *,NSString *> * _Nullable)defaultHeader  defaultParams:(NSDictionary * _Nullable)defaultParams prefixUrl:(NSString * _Nullable)prefixUrl andHandleResponse:(NSError *(^ _Nullable)(YKNetworkResponse *response,YKNetworkRequest *request) )handleResponse;

/// 请求地址
- (YKNetWorking * (^)(NSString *url))url;

/// 请求参数
- (YKNetWorking * (^)(NSDictionary *_Nullable params))params;

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

/// 取消当前所有请求
- (void)cancelAllRequest;

- (void)cancelRequestWithName:(NSString *)name;

#pragma mark ----------------------🔽🔽🔽🔽在mvvm模型下使用信号量相对稳妥-----------------------------
/**
 *执行请求信号
 *执行信号返回一个RACTuple的信号量
 *@warning 该信号量仍然需要配合mapWithRawData或mapArrayWithSomething
 */
- (RACSignal<RACTuple *> *)executeSignal;

/**
 *执行请求信号
 *执行信号返回一个处理完数据的信号量
 *@warning 该信号量默认使用mapWithRawData
 */
- (RACSignal *)executeRowDataSignal;

/**
 *执行上传信号
 *执行信号返回一个RACTuple的信号量
 *@warning 该信号量仍然需要配合mapWithRawData或mapArrayWithSomething
 */
- (RACSignal<RACTuple *> *)uploadDataSignal;

/**
 *执行上传信号
 *执行信号返回一个处理完数据的信号量
 *@warning 该信号量默认使用mapWithRawData
 */
- (RACSignal *)uploadDataRowDataSignal;

/**
 *执行下载信号
 *执行信号返回一个RACTuple的信号量
 *@warning 该信号量仍然需要配合mapWithRawData或mapArrayWithSomething
 */
- (RACSignal<RACTuple *> *)downloadDataSignal;

/**
 *执行下载信号
 *执行信号返回一个处理完数据的信号量
 *@warning 该信号量默认使用mapWithRawData
 */
- (RACSignal *)downloadDataRowDataSignal;


#pragma mark -----------非响应式变成可用以下调用常规方法------------

/// 网络请求
/// @param method 请求方式
/// @param url 请求地址
/// @param params 请求参数
/// @param complateBlock 请求回调
+ (void)executeByMethod:(YKNetworkRequestMethod )method url:(NSString *)url params:(NSDictionary * _Nullable)params ComplateBlock:(complateBlockType)complateBlock;

/// get请求
/// @param url 请求地址
/// @param params 请求参数
/// @param complateBlock 请求回调
+ (void)getUrl:(NSString *)url params:(NSDictionary * _Nullable)params ComplateBlock:(complateBlockType)complateBlock;

/// post请求
/// @param url 请求地址
/// @param params 请求参数
/// @param complateBlock 请求回调
+ (void)postUrl:(NSString *)url params:(NSDictionary * _Nullable)params ComplateBlock:(complateBlockType)complateBlock;

/// 上传请求
/// @param url 请求地址
/// @param params 请求参数
/// @param data 上传数据
/// @param filename 上传文件名
/// @param mimeType mimeType
/// @param progress 进度
/// @param complateBlock 请求回调
+ (void)uploadToUrl:(NSString *)url params:(NSDictionary * _Nullable)params data:(NSData *)data filename:(NSString *)filename mimeType:(NSString *)mimeType progress:(progressBlockType)progress complateBlock:(complateBlockType)complateBlock;

/// 下载请求
/// @param fromUrl 请求地址
/// @param localUrl 远程地址
/// @param progress 进度
/// @param complateBlock 请求回调
+ (void)downloadFromUrl:(NSString *)fromUrl localUrl:(NSString *)localUrl progress:(progressBlockType)progress complateBlock:(complateBlockType)complateBlock;

@end


NS_ASSUME_NONNULL_END
