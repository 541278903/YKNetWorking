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

+ (NSURLSessionDataTask *)executeTaskWith:(YKNetworkRequest *)request;

+ (NSURLSessionDownloadTask *)downloadTaskWith:(YKNetworkRequest *)request
                              downloadProgress:(void (^)(float progress))downloadProgress
                                 complateBlock:(complateBlockType)complate;
@end

NS_ASSUME_NONNULL_END
