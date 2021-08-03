//
//  YKBaseNetWorking.m
//  YKNetWorking
//
//  Created by edward on 2021/8/2.
//

#import "YKBaseNetWorking.h"
#import "YKNetworkingConfig.h"
#import <AFNetworking/AFNetworking.h>

@interface YKBaseNetWorking ()

@end

@implementation YKBaseNetWorking

+ (NSURLSessionTask *)requestWithRequest:(YKNetworkRequest *)request progressBlock:(progressBlockType)progressBlock successBlock:(successBlockType)successBlock failureBlock:(failureBlockType)failureBlock
{
    __block NSURLSessionDataTask *dataTask = nil;
    
    if (request.mockData != nil) {
        if (successBlock) {
            YKNetworkResponse *resp = [[YKNetworkResponse alloc] init];
            resp.isCache = NO;
            resp.rawData = request.mockData;
            successBlock(resp,request);
            return nil;
        }
    }
    
//    dataTask = [self executeTaskWith:request success:successBlock failure:failureBlock];
    dataTask = [self executeTaskWith:request progress:progressBlock success:successBlock failure:failureBlock];
    
    
    request.task = dataTask;
    return dataTask;
    
}


#pragma mark ============ 执行请求内容 ==========
+ (NSURLSessionDataTask *)executeTaskWith:(YKNetworkRequest *)request
                                 progress:(_Nullable progressBlockType)progress
                                  success:(_Nullable successBlockType)success
                                  failure:(_Nullable failureBlockType)failure
{
    
    [YKBaseNetWorking configWithRequest:request];
    
    NSError *serializationError = nil;
    NSMutableURLRequest *req = [[AFHTTPSessionManager manager].requestSerializer requestWithMethod:request.methodStr URLString:request.urlStr parameters:request.params error:&serializationError];
    
    if (serializationError != nil) {
        if (failure) {
            failure(request,NO,nil,serializationError);
        }
    }
    
    __block NSURLSessionDataTask *dataTask = nil;
    
    dataTask = [[AFHTTPSessionManager manager] dataTaskWithRequest:req uploadProgress:^(NSProgress * _Nonnull uploadProgress) {
        
    } downloadProgress:^(NSProgress * _Nonnull downloadProgress) {
        if (progress) {
            progress((float)downloadProgress.completedUnitCount / (float)downloadProgress.totalUnitCount);
        }
    } completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        if (!error) {
            if ([response isKindOfClass:NSHTTPURLResponse.class]) {
                
                //TODO:对返回的直接处理
                
                
            }
        }
        
        if (error) {
            if (failure) {
                failure(request,NO,responseObject,error);
            }
        }else{
            if (success) {
                YKNetworkResponse *resp = [[YKNetworkResponse alloc] init];
                resp.isCache = NO;
                resp.rawData = responseObject;
                success(resp,request);
            }
        }
        
    }];
    [dataTask resume];
    
    return dataTask;
}


#pragma mark ============ 执行上传请求内容 ==========

+ (NSURLSessionDataTask *)uploadTaskWith:(YKNetworkRequest *)request
                     uploadProgressBlock:(progressBlockType)uploadProgressBlock
                                 success:(successBlockType)success
                                 failure:(failureBlockType)failure
{
    [YKBaseNetWorking configWithRequest:request];
    
    NSURLSessionDataTask *task = [[AFHTTPSessionManager manager] POST:request.urlStr parameters:request.params headers:nil constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        if (request.uploadFileData) {
            [formData appendPartWithFileData:request.uploadFileData name:request.fileFieldName fileName:request.uploadName mimeType:request.uploadMimeType];
        }
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        if (uploadProgressBlock) {
            uploadProgressBlock((float)uploadProgress.completedUnitCount / (float)uploadProgress.totalUnitCount);
        }
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (success) {
            YKNetworkResponse *response = [[YKNetworkResponse alloc] init];
            response.isCache = NO;
            response.rawData = responseObject;
            success(response,request);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (failure) {
            failure(request,NO,nil,error);
        }
    }];
    
    request.task = task;
    return task;
}

#pragma mark ============ 执行下载请求内容 ==========

+ (NSURLSessionDownloadTask *)downloadTaskWith:(YKNetworkRequest *)request
                          downloadProgressBlock:(progressBlockType)downloadProgressBlock
                                       success:(successBlockType)success
                                       failure:(failureBlockType)failure
{
    [YKBaseNetWorking configWithRequest:request];
    
    NSURL *downloadURL = [NSURL URLWithString:request.urlStr];
    
    NSURLRequest *downloadRequest = [NSURLRequest requestWithURL:downloadURL];
    
    NSURLSessionDownloadTask *task = [[AFHTTPSessionManager manager] downloadTaskWithRequest:downloadRequest progress:^(NSProgress * _Nonnull downloadProgress) {
        if (downloadProgressBlock) {
            downloadProgressBlock((float)downloadProgress.completedUnitCount / (float)downloadProgress.totalUnitCount);
        }
    } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
        NSString *downloadPath = request.destPath;
        NSFileManager *filemanager = [NSFileManager defaultManager];
        [filemanager createDirectoryAtPath:downloadPath withIntermediateDirectories:YES attributes:nil error:nil];
        NSString *filePath = [downloadPath stringByAppendingPathComponent:response.suggestedFilename];
        return [NSURL fileURLWithPath:filePath];
    } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
        if (success && !error) {
            YKNetworkResponse *response = [[YKNetworkResponse alloc] init];
            response.isCache = NO;
            response.rawData = @{@"path":filePath.relativePath?:@"", @"code":@200};
            success(response,request);
        }
        if (failure && error) {
            failure(request,NO,nil,error);
        }
    }];
    request.downloadTask = task;
    
    [task resume];
    
    return task;
}

+ (void)cacheWithRequest:(YKNetworkRequest *)request
            successBlock:(successBlockType)successBlock
            failureBlock:(failureBlockType)failureBlock
{
    
    //TODO:添加缓存机制
}

#pragma mark ============ 请求头统一处理 ==========
+ (void)configWithRequest:(YKNetworkRequest *)request
{
    AFHTTPRequestSerializer *requestSerializer;
    
    if (request.paramsType == YKNetworkResponseTypeJSON) {
        requestSerializer = [AFJSONRequestSerializer serializer];
    }else{
        requestSerializer = [AFHTTPRequestSerializer serializer];
    }
    
    
    if (request.header && request.header.count > 0) {
        [request.header enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, NSString * _Nonnull obj, BOOL * _Nonnull stop) {
            [requestSerializer setValue:obj forHTTPHeaderField:key];
        }];
    }
    
    double timeoutInterval = [YKNetworkingConfig defaultConfig].timeoutInterval;
    if (timeoutInterval != 0) {
        requestSerializer.timeoutInterval = timeoutInterval;
    }else
    {
        requestSerializer.timeoutInterval = 60;
    }
    
    //设置请求内容
    if (request.requestSerializerBlock) {
        [AFHTTPSessionManager manager].requestSerializer = request.requestSerializerBlock(requestSerializer);
    }else{
        [AFHTTPSessionManager manager].requestSerializer = requestSerializer;
    }
    
    // 直接支持多种格式的返回
    [AFHTTPSessionManager manager].responseSerializer = [AFCompoundResponseSerializer compoundSerializerWithResponseSerializers:@[
        [AFJSONResponseSerializer serializer],
        [AFImageResponseSerializer serializer],
        [AFHTTPResponseSerializer serializer],
        [AFPropertyListResponseSerializer serializer],
        [AFXMLParserResponseSerializer serializer]
    ]];
}

@end
