# OCEventBus
an eventbus implementation for ios developer
#usage
1. import library
```objc
#import "NSObject+eventbus.h"
```
2. create event types
```objc
typedef enum{
    sample_event_user_login,
    sample_event_user_logout
} sample_event_t;
```

3. register event listenner
```objc
[self onEvent:sample_event_user_login cb:^(id sender,id ud){
    NSLog(@"sample event useradata:%@",ud);
}
``
4. post event 
```objc
[self postEvent:sample_event_user_login obj:nil];
```
5. unregister

```objc
[self unregisterEvent:sample_event_userlogin];
```
