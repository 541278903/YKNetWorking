//
//  RACSignal+networking.h
//  YK_BaseMediator
//
//  Created by edward on 2020/11/10.
//  Copyright © 2020 Edward. All rights reserved.
//

#import <ReactiveObjC/ReactiveObjC.h>

NS_ASSUME_NONNULL_BEGIN

@interface RACSignal (networking)
//获取成功回调的信息
- (RACSignal *)mapWithRawData;

- (RACSignal *(^)(NSString *someThing,Class clazz))mapArrayWithSomething;

@end

NS_ASSUME_NONNULL_END
