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
    sample_event_userlogin,
    sample_event_userlogout
}sample_event_t;
typedef enum{
    qood_config_user_info=0x000001
}qood_configs;
@interface ViewController ()
- (IBAction)postEvent:(id)sender;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"%@",[@"~/Library" stringByExpandingTildeInPath]);
    [self onEvent:sample_event_userlogin cb:^(id sender, id ud) {
        NSLog(@"on sample event, object:%@",ud);
    }];
    [self onEvent:sample_event_userlogout cb:^(id sender, id ud) {
        NSLog(@"on sample event, object:%@",ud);
    }];
    [self putFile:qood_config_user_info value:@{@"username":@"userid"}];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)postEvent:(id)sender {
    [self getFile:qood_config_user_info complete:^(id ud) {
       [self postEvent:sample_event_userlogin obj:ud];
    }];
}
-(void)dealloc{
    [self unregisterEvent:sample_event_userlogin];
    [self unregisterEvent:sample_event_userlogout];
}
- (IBAction)event2BtnClicked:(id)sender {
    [self postEvent:sample_event_userlogout obj:@{@"type":@"logout"}];
}
@end
