//
//  YKNetworkingConfig.m
//  MMCNetworkingDemo
//
//  Created by Arclin on 2018/4/28.
//

#import "YKNetworkingConfig.h"
#import <AFNetworking/AFNetworking.h>

@interface YKNetworkingConfig ()

/// 网络状态
@property(nonatomic,assign,readwrite) AFNetworkReachabilityStatus status;

@end

@implementation YKNetworkingConfig

static YKNetworkingConfig *_instance;

+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [super allocWithZone:zone];
        [[NSNotificationCenter defaultCenter] addObserver:_instance selector:@selector(changeStatus:) name:@"toConfig" object:nil];
    });
    return _instance;
}

+ (instancetype)defaultConfig {
    if (!_instance) {
        _instance = [[self alloc] init];
        _instance.distinguishError = YES;
        _instance.timeoutInterval = 30;
    }
    return _instance;
}

- (void)changeStatus:(NSNotification *)notification
{
    NSDictionary *dic = notification.userInfo;
    self.status = [dic[@"status"]?:@"0" integerValue];
}

- (void)setParams:(NSDictionary *)params responseObj:(id)responseObj forUrl:(NSString *)url {
//    [[MMCNetworkCache defaultManager] setObject:responseObj forRequestUrl:url params:params memoryOnly:NO];
}

@end
