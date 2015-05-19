//
//  OCEventBus.m
//  OCEventBus
//
//  Created by peng on 15/5/19.
//  Copyright (c) 2015年 peng. All rights reserved.
//

#import "OCEventBus.h"

@interface OCEventBusListenner : NSObject
@property (nonatomic,strong)id target;
@property (nonatomic,strong)dispatch_queue_t queue;
@property (nonatomic,strong)oceventbus_cb_t cb;
@end
@implementation OCEventBusListenner
@end

static NSMutableDictionary *listenners;
static dispatch_queue_t lisqueue;
@implementation OCEventBus
+(void)load{
    listenners=[NSMutableDictionary dictionary];
    lisqueue=dispatch_queue_create("ocevnetbus.queue", DISPATCH_QUEUE_SERIAL);
}
+(void)doinqueue:(void(^)())block{
    dispatch_async(lisqueue, block);
}
+(void)post:(uint32_t)event object:(id)obj sender:(id)sender{
    [self doinqueue:^{
        NSMutableDictionary *observers=listenners[@(event)];
        if (observers!=nil) {
            for (NSNumber *key in observers) {
                OCEventBusListenner *lis=observers[key];
                dispatch_async(lis.queue, ^{
                    if (lis.cb) {
                        lis.cb(sender,obj);
                    }
                });
            }
        }
    }];
}
+(void)on:(uint32_t)event target:(id)target queue:(dispatch_queue_t)queue cb:(oceventbus_cb_t)block{
    [self doinqueue:^{
        NSMutableDictionary *observers=listenners[@(event)];
        if (observers==nil) {
            observers=[NSMutableDictionary dictionary];
            listenners[@(event)]=observers;
        }
        NSUInteger hash=[target hash];
        if ([observers objectForKey:@(hash)]) {//aready exist
            return ;
        }else{
            OCEventBusListenner *lis=[[OCEventBusListenner alloc] init];
            lis.queue=queue;
            lis.target=target;
            lis.cb=block;
            observers[@(hash)]=lis;
        }
    }];
}
+(void)unregister:(uint32_t)event target:(id)target{
    [self doinqueue:^{
        NSMutableDictionary *observers=listenners[@(event)];
        if (observers!=nil) {
            NSUInteger hash=[target hash];
            [observers removeObjectForKey:@(hash)];
        }
    }];
}
@end
