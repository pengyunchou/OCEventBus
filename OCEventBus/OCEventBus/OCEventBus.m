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
static id<OCEventCacheProtocol> cache;

@interface OcEventCacheDefault()
@property NSMutableDictionary *memcacheValues;
@end

@implementation OcEventCacheDefault
-(id)init{
    self=[super init];
    if (self) {
        self.memcacheValues=[NSMutableDictionary dictionary];
        [self checkAndMakeCacheDir];
    }
    return self;
}
-(void)checkAndMakeCacheDir{
    NSString *cacheDir=[self cacheDir];
    NSFileManager *defmgr=[NSFileManager defaultManager];
    if (![defmgr fileExistsAtPath:cacheDir]) {
        [defmgr createDirectoryAtPath:cacheDir withIntermediateDirectories:YES attributes:nil error:nil];
    }
}
-(void)putMem:(uint32_t)key value:(id)v{
    if (v!=nil) {
        self.memcacheValues[@(key)]=v;
    }else{
        [self.memcacheValues removeObjectForKey:@(key)];
    }
}
-(NSString *)makeUserDefaultKey:(uint32_t)key{
    return [NSString stringWithFormat:@"oc_event_cache_%d",key];
}
-(NSString *)cacheDir{
    return [NSString stringWithFormat:@"%@/Library/axeventbus.axcache",NSHomeDirectory()];
}
-(NSString *)makeFilePathKey:(uint32_t)key{
    return [[self cacheDir] stringByAppendingPathComponent:[NSString stringWithFormat:@"axcache_%d",key]];
}
-(void)removeFileKey:(uint32_t)key{
    NSFileManager *fmgr=[NSFileManager defaultManager];
    [fmgr removeItemAtPath:[self makeFilePathKey:key] error:nil];
}
-(void)putUserDefault:(uint32_t)key value:(id)v{
    NSString *keys=[self makeUserDefaultKey:key];
    if (v!=nil) {
        [[NSUserDefaults standardUserDefaults] setObject:v forKey:keys];
    }else{
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:keys];
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
}
-(void)putFile:(uint32_t)key value:(id)v{
    NSData *data=[NSJSONSerialization dataWithJSONObject:v options:0 error:nil];
    if (v!=nil) {
        [data writeToFile:[self makeFilePathKey:key] atomically:YES];
    }else{
        [self removeFileKey:key];
    }
}
-(void)put:(uint32_t)key value:(id)v type:(uint32_t)type{
    switch (type) {
        case OCEventCacheMemory:
            [self putMem:key value:v];
            break;
        case OCEventCacheUserDefault:
            [self putUserDefault:key value:v];
            break;
        case OCEventCacheFile:
            [self putFile:key value:v];
            break;
        default:
            break;
    }
}
-(void)getMem:(uint32_t)key cb:(oceventbus_cache_cb_t)block{
    id v=self.memcacheValues[@(key)];
    if (block) {
        block(v);
    }
}
-(void)getUserDefault:(uint32_t)key cb:(oceventbus_cache_cb_t)block{
    NSString *keys=[self makeUserDefaultKey:key];
    id v=[[NSUserDefaults standardUserDefaults] objectForKey:keys];
    if (block) {
        block(v);
    }
}
-(void)getFile:(uint32_t)key cb:(oceventbus_cache_cb_t)block{
    NSData *data=[NSData dataWithContentsOfFile:[self makeFilePathKey:key]];
    id v=nil;
    if (data!=nil) {
        v=[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
    }
    if (block) {
        block(v);
    }
}
-(void)get:(uint32_t)key type:(uint32_t)type cb:(oceventbus_cache_cb_t)block{
    switch (type) {
        case OCEventCacheMemory:
            [self getMem:key cb:block];
            break;
        case OCEventCacheUserDefault:
            [self getUserDefault:key cb:block];
            break;
        case OCEventCacheFile:
            [self getFile:key cb:block];
            break;
        default:
            break;
    }
}
@end

@implementation OCEventBus
+(void)load{
    cache=[[OcEventCacheDefault alloc] init];
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
+(void)put:(uint32_t)key value:(id)v type:(uint32_t)type{
    [self doinqueue:^{
        [cache put:key value:v type:type];
    }];
}
+(void)get:(uint32_t)key type:(uint32_t)type cb:(oceventbus_cache_cb_t)block{
    [self doinqueue:^{
        [cache get:key type:type cb:block];
    }];
}
@end
