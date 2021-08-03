//
//  YKNetWorkingRequest.h
//  YK_BaseTools
//
//  Created by edward on 2020/7/16.
//  Copyright © 2020 Edward. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFNetworking/AFNetworking.h>
#import "YKNetWorkingConst.h"


NS_ASSUME_NONNULL_BEGIN

@interface YKNetworkRequest : NSObject<NSCopying>

/** 唯一标识符 */
@property (nonatomic, copy) NSString *name;

/** 请求地址 */
@property (nonatomic, copy)   NSString *urlStr;

/** 请求参数 */    //MARK:rewrite
@property (nonatomic, strong) NSMutableDictionary *params;

/** 请求头 */   //MARK:rewrite
@property (nonatomic, strong) NSMutableDictionary<NSString *,NSString *> *header;

/** 请求方式 */
@property (nonatomic, assign) YKNetworkRequestMethod       method;

/** 请求体类型 默认二进制形式 */
@property (nonatomic, assign) YKNetworkRequestParamsType   paramsType;

/** 获取当前的请求方式(字符串) ***/
@property (nonatomic, copy, readonly)      NSString       *methodStr;

/** 禁止了动态参数 */  //MARK:rewrite
@property (nonatomic, assign) BOOL disableDynamicParams;

/** 禁止了动态请求头 */
@property (nonatomic, assign) BOOL disableDynamicHeader;

/** 是否禁用默认返回处理方式 */
@property (nonatomic, assign) BOOL disableHandleResponse;

/** 上传/下载进度 */
@property (nonatomic, copy) void(^progressBlock)(float progress);

/** 最短重复请求时间 */   //MARK:rewrite
@property (nonatomic, assign) float repeatRequestInterval;

/** 下载路径 */   //MARK:rewrite
@property (nonatomic, copy) NSString *destPath;

/// 上传文件的二进制
@property(nonatomic,strong) NSData *uploadFileData;

/// 上传文件名
@property(nonatomic,copy) NSString *uploadName;

/// mimetype
@property(nonatomic,copy) NSString *uploadMimeType;

/** 起始时间 */
@property(nonatomic,assign) NSTimeInterval startTimeInterval;

/** 假数据 */
@property (nonatomic, strong) id<NSCopying> mockData;

/** 请求上传文件的字段名 */
@property (nonatomic, copy) NSString *fileFieldName;


/** 处理AF请求体: 特殊情况下需要修改时使用 一般可以不用 */
@property (nonatomic, copy) AFHTTPRequestSerializer *(^requestSerializerBlock)(AFHTTPRequestSerializer *);

/** 处理AF响应体: 特殊情况下需要修改时使用 一般可以不用 */
@property (nonatomic, copy) AFHTTPResponseSerializer *(^responseSerializerBlock)(AFHTTPResponseSerializer *);

/** 请求Task 当启用假数据返回的时候为空 */
@property (nonatomic, strong) NSURLSessionDataTask        *task;

/** 下载Task */
@property (nonatomic, strong) NSURLSessionDownloadTask    *downloadTask;

#pragma mark -----------❌unUse❌(后续拓展才会真正使用到，敬请期待)------------


/** SSL证书 */
@property (nonatomic, copy) NSString *sslCerPath;

/** 文件名 */
@property (nonatomic, strong) NSMutableArray<NSString *> *fileName;
/** 上传的数据 */
@property (nonatomic, strong) NSMutableArray<NSData *> *data;

/** 文件类型 */
@property (nonatomic, strong) NSMutableArray<NSString *> *mimeType;

/** 是否需要清理缓存 */
@property (nonatomic, assign) BOOL clearCache;

/** 忽略最短请求间隔 强制发出请求 */
@property (nonatomic, assign, getter=isForce) BOOL force;

/** 自定义属性 */
@property (nonatomic, strong) NSMutableDictionary<NSString *,id<NSCopying>> *customProperty;

@end

NS_ASSUME_NONNULL_END
