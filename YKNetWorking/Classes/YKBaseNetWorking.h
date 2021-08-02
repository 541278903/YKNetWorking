//
//  YKBaseNetWorking.h
//  YKNetWorking
//
//  Created by edward on 2021/8/2.
//

#import <Foundation/Foundation.h>
#import "YKNetworkRequest.h"
#import "YKNetworkResponse.h"
#import "YKNetworkingConfig.h"

NS_ASSUME_NONNULL_BEGIN

@interface YKBaseNetWorking : NSObject

typedef void(^complateBlockType)( id _Nullable responData ,NSError * _Nullable error);

typedef void(^progressBlockType)(float progress);

+ (NSURLSessionDataTask *)executeTaskWith:(YKNetworkRequest *)request
                            complateBlock:(complateBlockType)complate;

+ (NSURLSessionDownloadTask *)uploadTaskWith:(YKNetworkRequest *)request
                            downloadProgress:(progressBlockType)downloadProgress
                               complateBlock:(complateBlockType)complate;

+ (NSURLSessionDownloadTask *)downloadTaskWith:(YKNetworkRequest *)request
                              downloadProgress:(progressBlockType)downloadProgress
                                 complateBlock:(complateBlockType)complate;
@end

NS_ASSUME_NONNULL_END
