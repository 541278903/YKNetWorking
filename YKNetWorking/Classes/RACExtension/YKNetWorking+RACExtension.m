//
//  YKNetWorking+RACExtension.m
//  YKNetWorking
//
//  Created by edward on 2022/9/30.
//

#import "YKNetWorking+RACExtension.h"
#import "YKNetworkRequest.h"
#import "YKNetWorking+BasePrivate.h"

@implementation YKNetWorking (RACExtension)


- (RACSignal<RACTuple *> *)executeSignal
{
    
    __weak typeof(self) weakSelf = self;
    RACSignal *singal = [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
        __strong typeof(weakSelf) strongself = weakSelf;
//        [YKBaseNetWorking requestWithRequest:request progressBlock:^(float progress) {
//            if (request.progressBlock) {
//                request.progressBlock(progress);
//            }
//        } successBlock:^(YKNetworkResponse * _Nonnull response, YKNetworkRequest * _Nonnull request) {\
//            NSError *error = nil;
//            if(strongself.handleResponse && !request.disableHandleResponse)
//            {
//                error = strongself.handleResponse(response,request);
//                if (!error) {
//                    [subscriber sendNext:RACTuplePack(request,response)];
//                }else{
//                    [subscriber sendError:error];
//                }
//            }else{
//                [subscriber sendNext:RACTuplePack(request,response)];
//            }
//            [self saveTask:request response:response isException:(error != nil)];
//            [subscriber sendCompleted];
//        } failureBlock:^(YKNetworkRequest * _Nonnull request, BOOL isCache, id  _Nullable responseObject, NSError * _Nonnull error) {
//            YKNetworkResponse *response = [[YKNetworkResponse alloc] init];
//            if ([strongself handleError:request response:response isCache:isCache error:error]) {
//                if (strongself.handleResponse && responseObject) {
//                    response.code = error.code;
//                    response.rawData = error;
//                    NSError *error = strongself.handleResponse(response,request);
//                    if (error) {
//                        [subscriber sendError:error];
//                    }
//                }else{
//                    [subscriber sendError:error];
//                }
//            }
//            [strongself saveTask:request response:response isException:YES];
//            [subscriber sendCompleted];
//        }];
//        strongself.request = nil;
        
        return nil;
    }];
    return singal;
}

- (RACSignal<RACTuple *> *)uploadDataSignal
{
    __weak typeof(self) weakSelf = self;
    RACSignal *singal = [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
        __strong typeof(weakSelf) strongself = weakSelf;
//        request.task = [YKBaseNetWorking uploadTaskWith:request uploadProgressBlock:^(float progress) {
//            if (request.progressBlock) {
//                request.progressBlock(progress);
//            }
//        } success:^(YKNetworkResponse * _Nonnull response, YKNetworkRequest * _Nonnull request) {
//            NSError *error = nil;
//            if (strongself.handleResponse && !request.disableHandleResponse) {
//                error = strongself.handleResponse(response,request);
//                if (error) {
//                    [subscriber sendError:error];
//                }else{
//                    [subscriber sendNext:RACTuplePack(request,response)];
//                }
//            }else{
//                [subscriber sendNext:RACTuplePack(request,response)];
//            }
//            [strongself saveTask:request response:response isException:(error != nil)];
//            [subscriber sendCompleted];
//        } failure:^(YKNetworkRequest * _Nonnull request, BOOL isCache, id  _Nullable responseObject, NSError * _Nonnull error) {
//            YKNetworkResponse *response = [[YKNetworkResponse alloc] init];
//            if ([strongself handleError:request response:response isCache:isCache error:error]) {
//                if (strongself.handleResponse && responseObject) {
////                    response.rawData = responseObject;
//                    response.code = error.code;
//                    response.rawData = error;
//                    NSError *error = strongself.handleResponse(response,request);
//                    if (error) {
//                        [subscriber sendError:error];
//                    }
//                }else{
//                    [subscriber sendError:error];
//                }
//            }
//            [strongself saveTask:request response:response isException:YES];
//            [subscriber sendCompleted];
//        }];
//
//        strongself.request = nil;
        return nil;
    }];
    return singal;
}


/// 执行下载信号
- (RACSignal<RACTuple *> *)downloadDataSignal
{
//    YKNetworkRequest *request = [self.request copy];
//    BOOL canContinue = [self handleConfigWithRequest:request];
//    if (!canContinue) {
//        self.request = nil;
//        return [RACSignal empty];
//    }
    __weak typeof(self) weakSelf = self;
    RACSignal *singal = [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
        __strong typeof(weakSelf) strongself = weakSelf;
        
//        [YKBaseNetWorking downloadTaskWith:request downloadProgressBlock:^(float progress) {
//            if (request.progressBlock) {
//                request.progressBlock(progress);
//            }
//        } success:^(YKNetworkResponse * _Nonnull response, YKNetworkRequest * _Nonnull request) {
//            NSError *error = nil;
//            if (strongself.handleResponse && !request.disableHandleResponse) {
//                error = strongself.handleResponse(response,request);
//                if (error) {
//                    [subscriber sendError:error];
//                }else{
//                    [subscriber sendNext:RACTuplePack(request,response)];
//                }
//                [strongself saveTask:request response:response isException:(error != nil)];
//                [subscriber sendCompleted];
//            }else{
//
//            }
//        } failure:^(YKNetworkRequest * _Nonnull request, BOOL isCache, id  _Nullable responseObject, NSError * _Nonnull error) {
//            YKNetworkResponse *response = [[YKNetworkResponse alloc] init];
//            if ([strongself handleError:request response:response isCache:isCache error:error]) {
//                if (strongself.handleResponse && responseObject) {
//                    response.code = error.code;
//                    response.rawData = error;
//                    NSError *error = strongself.handleResponse(response,request);
//                    if (error) {
//                        [subscriber sendError:error];
//                    }
//                }else{
//                    [subscriber sendError:error];
//                }
//            }
//            [strongself saveTask:request response:response isException:YES];
//            [subscriber sendCompleted];
//        }];
//
//
//        strongself.request = nil;
        return nil;
    }];
    return singal;
}




@end
