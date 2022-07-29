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
    CFAbsoluteTime startNSLog = CFAbsoluteTimeGetCurrent();
    for (int i = 0; i<5000; i++) {
        NSLog(@"测试=%d",i);
    }
    CFAbsoluteTime endNSLog = CFAbsoluteTimeGetCurrent();
    
    CFAbsoluteTime startPrintf = CFAbsoluteTimeGetCurrent();
    for (int i = 0; i<5000; i++) {
        AppLogDebug(@"测试=%d",i);
    }
    CFAbsoluteTime endPrintf = CFAbsoluteTimeGetCurrent();
    
    NSLog(@"NSLog time: %lf, printf time: %lf", endNSLog - startNSLog, endPrintf - startPrintf);
}

@end
