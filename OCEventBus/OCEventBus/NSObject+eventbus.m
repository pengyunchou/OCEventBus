//
//  NSObject+eventbus.m
//  OCEventBus
//
//  Created by peng on 15/5/19.
//  Copyright (c) 2015年 peng. All rights reserved.
//

#import "NSObject+eventbus.h"

@implementation NSObject (eventbus)
-(void)onEvent:(uint32_t)event cb:(oceventbus_cb_t)block{
    [OCEventBus on:event target:self queue:dispatch_get_main_queue() cb:block];
}
-(void)postEvent:(uint32_t)event obj:(id)obj{
    [OCEventBus post:event object:obj sender:self];
}
-(void)unregisterEvent:(uint32_t)event{
    [OCEventBus unregister:event target:self];
}
@end
