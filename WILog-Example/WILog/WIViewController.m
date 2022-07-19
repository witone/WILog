//
//  WIViewController.m
//  WILog
//
//  Created by zyp on 01/29/2021.
//  Copyright (c) 2021 zyp. All rights reserved.
//

#import "WIViewController.h"
#import <WILog/WILog.h>

@interface WIViewController ()

@end

@implementation WIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    for (int i = 0; i<10; i++) {
        WILogDebug(@"测试日志打印=%d",i);
    }
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        for (int i = 0; i<10; i++) {
            WILogDebug(@"测试queue=%d",i);
        }
    });
}

@end
