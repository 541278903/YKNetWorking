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
        
        
        __weak typeof(strongself) wSelf = strongself;
        [strongself executeRequest:^(YKNetworkResponse * _Nonnull response, YKNetworkRequest * _Nonnull request, NSError * _Nullable error) {
            __strong typeof(wSelf) sSelf = wSelf;
            
            if (error) {
                [subscriber sendError:error];
            }else {
                [subscriber sendNext:RACTuplePack(request,response)];
            }
            [subscriber sendCompleted];
            
        }];
        
        return nil;
    }];
    return singal;
}

- (RACSignal<RACTuple *> *)uploadDataSignal
{
    __weak typeof(self) weakSelf = self;
    RACSignal *singal = [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
        __strong typeof(weakSelf) strongself = weakSelf;
        
        __weak typeof(strongself) wSelf = strongself;
        [strongself executeUploadRequest:^(YKNetworkResponse * _Nonnull response, YKNetworkRequest * _Nonnull request, NSError * _Nullable error) {
            __strong typeof(wSelf) sSelf = wSelf;
            if (error) {
                [subscriber sendError:error];
            }else {
                [subscriber sendNext:RACTuplePack(request,response)];
            }
            [subscriber sendCompleted];
        }];
        
        
        return nil;
    }];
    return singal;
}


/// 执行下载信号
- (RACSignal<RACTuple *> *)downloadDataSignal
{
    __weak typeof(self) weakSelf = self;
    RACSignal *singal = [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
        __strong typeof(weakSelf) strongself = weakSelf;
        __weak typeof(strongself) wSelf = strongself;
        [strongself executeDownloadRequest:^(YKNetworkResponse * _Nonnull response, YKNetworkRequest * _Nonnull request, NSError * _Nullable error) {
            __strong typeof(wSelf) sSelf = wSelf;
            if (error) {
                [subscriber sendError:error];
            }else {
                [subscriber sendNext:RACTuplePack(request,response)];
            }
            [subscriber sendCompleted];
        }];
        return nil;
    }];
    return singal;
}




@end
