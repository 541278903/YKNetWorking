//
//  YKNetWorkingRequest.m
//  YK_BaseTools
//
//  Created by edward on 2020/7/16.
//  Copyright © 2020 Edward. All rights reserved.
//

#import "YKNetworkRequest.h"
#import <MJExtension/MJExtension.h>

@implementation YKNetworkRequest

- (nonnull id)copyWithZone:(nullable NSZone *)zone {
    YKNetworkRequest *request = [[YKNetworkRequest allocWithZone:zone] init];
    request.urlStr = self.urlStr;
    request.params = self.params;
    request.header = self.header;
    request.method = self.method;
    request.disableDynamicParams = self.disableDynamicParams;
    request.disableDynamicHeader = self.disableDynamicHeader;
    request.disableHandleResponse = self.disableHandleResponse;
    request.progressBlock = self.progressBlock;
    request.repeatRequestInterval = self.repeatRequestInterval;
    request.destPath = self.destPath;
    request.uploadFileData = self.uploadFileData;
    request.uploadName = self.uploadName;
    request.uploadMimeType = self.uploadMimeType;
    request.startTimeInterval = self.startTimeInterval;
    request.task = self.task;
    request.downloadTask = self.downloadTask;
    return request;
}
- (NSMutableDictionary *)params {
    if (!_params) {
        _params = [NSMutableDictionary dictionary];
    }
    return _params;
}

- (NSMutableDictionary<NSString *,NSString *> *)header
{
    if (!_header) {
        _header = [NSMutableDictionary dictionary];
    }
    return _header;
}
- (NSString *)methodStr {
    switch (self.method) {
        case YKNetworkRequestMethodGET:
            return @"GET";
        case YKNetworkRequestMethodPOST:
            return @"POST";
        case YKNetworkRequestMethodDELETE:
            return @"DELETE";
        case YKNetworkRequestMethodPUT:
            return @"PUT";
        case YKNetworkRequestMethodPATCH:
            return @"PATCH";
        default:
            return @"GET";
            break;
    }
}

- (NSMutableArray<NSString *> *)fileName
{
    if (!_fileName) {
        _fileName = [NSMutableArray array];
    }
    return _fileName;
}

- (NSMutableArray<NSData *> *)data
{
    if (!_data) {
        _data = [NSMutableArray array];
    }
    return _data;
}

- (NSMutableArray<NSString *> *)mimeType
{
    if (!_mimeType) {
        _mimeType = [NSMutableArray array];
    }
    return _mimeType;
}
@end
