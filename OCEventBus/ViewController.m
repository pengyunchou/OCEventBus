//
//  ViewController.m
//  OCEventBus
//
//  Created by peng on 15/5/19.
//  Copyright (c) 2015年 peng. All rights reserved.
//

#import "ViewController.h"
#import "NSObject+eventbus.h"

typedef enum{
    sample_event_userlogin
}sample_event_t;

@interface ViewController ()
- (IBAction)postEvent:(id)sender;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self onEvent:sample_event_userlogin cb:^(id sender, id ud) {
        NSLog(@"on sample event, object:%@",ud);
    }];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)postEvent:(id)sender {
    [self postEvent:sample_event_userlogin obj:@{@"username":@"hello"}];
}
-(void)dealloc{
    [self unregisterEvent:sample_event_userlogin];
}
@end
