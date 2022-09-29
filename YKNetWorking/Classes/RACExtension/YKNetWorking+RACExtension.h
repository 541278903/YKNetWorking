//
//  YKNetWorking+RACExtension.h
//  YKNetWorking
//
//  Created by edward on 2022/9/30.
//


#import "YKNetWorking.h"
#import "RACSignal+networking.h"


NS_ASSUME_NONNULL_BEGIN




@interface YKNetWorking (RACExtension)


/**
 *执行请求信号
 *执行信号返回一个RACTuple的信号量
 *@warning 该信号量仍然需要配合mapWithRawData或mapArrayWithSomething
 */
- (RACSignal<RACTuple *> *)executeSignal;

/**
 *执行上传信号
 *执行信号返回一个RACTuple的信号量
 *@warning 该信号量仍然需要配合mapWithRawData或mapArrayWithSomething
 */
- (RACSignal<RACTuple *> *)uploadDataSignal;


/**
 *执行下载信号
 *执行信号返回一个RACTuple的信号量
 *@warning 该信号量仍然需要配合mapWithRawData或mapArrayWithSomething
 */
- (RACSignal<RACTuple *> *)downloadDataSignal;


@end

NS_ASSUME_NONNULL_END
