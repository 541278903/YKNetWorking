//
//  YKNetworkingConfig.h
//  MMCNetworkingDemo
//
//  Created by Arclin on 2018/4/28.
//

#import <Foundation/Foundation.h>
#import "YKNetworkRequest.h"
#import "YKNetworkResponse.h"

typedef NS_ENUM(NSInteger, YKNetworkingOnlineStatus) {
    YKNetworkingOnlineStatusUnknown          = -1,
    YKNetworkingOnlineStatusNotReachable     = 0,
    YKNetworkingOnlineStatusReachableViaWWAN = 1,
    YKNetworkingOnlineStatusReachableViaWiFi = 2,
};

@interface YKNetworkingConfig : NSObject

+ (instancetype)defaultConfig;


#pragma mark ----------------------只读属性-----------------------------

/// 网络状态
@property(nonatomic,assign,readonly) YKNetworkingOnlineStatus status;

#pragma mark ----------------------可写属性-----------------------------
/** 超时时间 默认30秒 */
@property (nonatomic, assign) double timeoutInterval;

/** 公用头部 */
@property (nonatomic, copy) NSDictionary *defaultHeader;

/** 公用参数 */
@property (nonatomic, copy) NSDictionary *defaultParams;

/** 公用url前缀 */
@property (nonatomic, copy) NSString *defaultPrefixUrl;

/** 首选的缓存策略 默认NetworkOnly */
//@property (nonatomic, assign) MMCCacheStrategy defaultCacheStrategy;

/**
 区分业务错误（200情况下执行handleResponse）和 网络链接错误（400+、500+类下执行handleError）
 若为false时 400+、500+类错误下 handleResponse 和 handleError 将会同时执行
 默认为true
 */
@property (nonatomic, assign) BOOL distinguishError;

/** 动态添加参数，每次执行网络请求前都会访问一遍 修改的值优先级最低 */
@property (nonatomic, copy) NSDictionary *(^dynamicParamsConfig)(YKNetworkRequest *request);

/** 动态添加请求头，每次执行网络请求前都会访问一遍 修改的值优先级最低 */
@property (nonatomic, copy) NSDictionary *(^dynamicHeaderConfig)(YKNetworkRequest *request);

/** 根据需求设置缓存内容 */
@property (nonatomic, copy) void(^cacheRequest)(YKNetworkResponse *response,YKNetworkRequest *request,BOOL isException);

/**
 设置特定的参数和响应体, 一般是用来做假数据用，需要在请求链中使用MMCCacheStrategyCacheOnly，使用其他缓存机制有可能会被网络数据覆盖

 @param params 参数
 @param responseObj 响应体
 @param url 接口地址
 */
- (void)setParams:(NSDictionary *)params responseObj:(id)responseObj forUrl:(NSString *)url;

@end
