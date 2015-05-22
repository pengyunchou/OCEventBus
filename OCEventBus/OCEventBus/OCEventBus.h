//
//  OCEventBus.h
//  OCEventBus
//
//  Created by peng on 15/5/19.
//  Copyright (c) 2015年 peng. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef void (^oceventbus_cb_t)(id sender,id ud);
typedef void (^oceventbus_cache_cb_t)(id ud);


@protocol OCEventCacheProtocol <NSObject>
-(void)put:(uint32_t)key value:(id)v type:(uint32_t)type;
-(void)get:(uint32_t)key type:(uint32_t)type cb:(oceventbus_cache_cb_t)block;
@end

typedef enum{
    OCEventCacheMemory,
    OCEventCacheUserDefault,
    OCEventCacheFile
} OCEventCacheDefaultType;

@interface OcEventCacheDefault : NSObject<OCEventCacheProtocol>

@end

@interface OCEventBus : NSObject
+(void)post:(uint32_t)event object:(id)obj sender:(id)sender;
+(void)on:(uint32_t)event target:(id)target queue:(dispatch_queue_t)queue cb:(oceventbus_cb_t)block;
+(void)unregister:(uint32_t)event target:(id)target;
+(void)setCacheProtocol:(id<OCEventCacheProtocol>)cacheprotocol;
+(void)put:(uint32_t)key value:(id)v type:(uint32_t)type;
+(void)get:(uint32_t)key type:(uint32_t)type cb:(oceventbus_cache_cb_t)block;
@end
