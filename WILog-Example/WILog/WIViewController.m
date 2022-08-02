//
//  WIViewController.m
//  WILog
//
//  Created by zyp on 01/29/2021.
//  Copyright (c) 2021 zyp. All rights reserved.
//

#import "WIViewController.h"
#import <WILog/WILog.h>

@interface WIViewController ()<UIDocumentInteractionControllerDelegate>

@property(nonatomic,strong) UIButton *testLogBtn;
@property(nonatomic,strong) UIButton *showLogBtn;

@property (nonatomic, strong) UIDocumentInteractionController *documentInteractionController;

@end

@implementation WIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    {
        UIButton *btn = [[UIButton alloc]initWithFrame:CGRectMake(10, WIStatusBarHeight(), wiScreenWidth - 20, 40)];
        btn.backgroundColor = UIColor.grayColor;
        [btn setClipsToBounds:YES];
        [btn.layer setCornerRadius:3];
        [btn.titleLabel setFont:[UIFont systemFontOfSize:16]];
        [btn setTitle:@"打印日志" forState:UIControlStateNormal];
        [btn setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(testLog) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:btn];
    }
    
    {
        UIButton *btn = [[UIButton alloc]initWithFrame:CGRectMake(10, WIStatusBarHeight()+50, wiScreenWidth - 20, 40)];
        btn.backgroundColor = UIColor.grayColor;
        [btn setClipsToBounds:YES];
        [btn.layer setCornerRadius:3];
        [btn.titleLabel setFont:[UIFont systemFontOfSize:16]];
        [btn setTitle:@"显示日志" forState:UIControlStateNormal];
        [btn setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(showFileLog) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:btn];
    }
}

-(void)testPrintLog {
    AppLogError(@"这是一个error日志");
    AppLogDebug(@"这是一个debug日志");
    AppLogInfo(@"这是一个info日志");

    AppLogTagError(@"测试tag", @"这是一个error日志");
    AppLogTagDebug(@"测试tag", @"这是一个debug日志");
    AppLogTagInfo( @"测试tag", @"这是一个info日志");
}

- (void)testLog {
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

- (void)showFileLog {
    if (![WILog currentLogFilePath]) {
        return;
    }
    
    //由文件路径初始化UIDocumentInteractionController
    UIDocumentInteractionController *documentInteractionController  = [UIDocumentInteractionController interactionControllerWithURL:[NSURL fileURLWithPath:[WILog currentLogFilePath]]];
    self.documentInteractionController = documentInteractionController;
    documentInteractionController.delegate = self;
    
//    //显示分享文档界面
//    [documentInteractionController  presentOptionsMenuFromRect:[UIScreen mainScreen].bounds inView:[UIApplication sharedApplication].keyWindow.rootViewController.view animated:YES];
    
    //直接显示预览界面
    [documentInteractionController  presentPreviewAnimated:YES];
}

#pragma mark - UIDocumentInteractionControllerDelegate
//在哪个控制器显示预览界面
-(UIViewController *)documentInteractionControllerViewControllerForPreview:(UIDocumentInteractionController *)controller {
    return self;
}

@end
