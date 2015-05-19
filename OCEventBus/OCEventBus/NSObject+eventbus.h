//
//  NSObject+eventbus.h
//  OCEventBus
//
//  Created by peng on 15/5/19.
//  Copyright (c) 2015年 peng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OCEventBus.h"
@interface NSObject (eventbus)
-(void)onEvent:(uint32_t)event cb:(oceventbus_cb_t)block;
-(void)postEvent:(uint32_t)event obj:(id)obj;
-(void)unregisterEvent:(uint32_t)event;
@end
