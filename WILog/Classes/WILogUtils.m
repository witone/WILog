//
//  WILogUtils.m
//  WILog
//
//  Created by zyp on 01/29/2021.
//  Copyright (c) 2021 zyp. All rights reserved.
//

#import "WILogUtils.h"

#if __has_include(<CocoaLumberjack/CocoaLumberjack.h>)
#import <CocoaLumberjack/CocoaLumberjack.h>

#if DEBUG
static const int ddLogLevel = DDLogLevelVerbose;// 定义日志级别
#else
static const int ddLogLevel = DDLogFlagInfo;// 定义日志级别
#endif

#define WILogInnerError(frmt, ...)   LOG_MAYBE(NO,                LOG_LEVEL_DEF, DDLogFlagError,   0, nil, __PRETTY_FUNCTION__, frmt, ##__VA_ARGS__)
#define WILogInnerInfo(frmt, ...)    LOG_MAYBE(LOG_ASYNC_ENABLED, LOG_LEVEL_DEF, DDLogFlagInfo,    0, nil, __PRETTY_FUNCTION__, frmt, ##__VA_ARGS__)
#define WILogInnerDebug(frmt, ...)   LOG_MAYBE(LOG_ASYNC_ENABLED, LOG_LEVEL_DEF, DDLogFlagDebug,   0, nil, __PRETTY_FUNCTION__, frmt, ##__VA_ARGS__)

#else

#if DEBUG
#define WILogInnerError(frmt, ...)   NSLog(frmt, ##__VA_ARGS__)
#define WILogInnerInfo(frmt, ...)    NSLog(frmt, ##__VA_ARGS__)
#define WILogInnerDebug(frmt, ...)   NSLog(frmt, ##__VA_ARGS__)
#else
#define WILogInnerError(frmt, ...)
#define WILogInnerInfo(frmt, ...)
#define WILogInnerDebug(frmt, ...)
#endif

#endif

@implementation WILogUtils

+ (void)initLogWithPath:(nullable NSString *)logPath {
#if __has_include(<CocoaLumberjack/CocoaLumberjack.h>)
    //[DDLog addLogger:[DDASLLogger sharedInstance]];//打印到系统
#if DEBUG
    [DDLog addLogger:[DDTTYLogger sharedInstance]];//打印到xcode
#endif

    DDFileLogger *fileLogger;
    if (logPath && logPath.length>0) {
        fileLogger = [[DDFileLogger alloc] initWithLogFileManager:[[DDLogFileManagerDefault alloc]initWithLogsDirectory:logPath]];
    }else {
        fileLogger = [[DDFileLogger alloc] init];
    }
    
    fileLogger.rollingFrequency = 60 * 60 * 24; // 24 hour rolling
    fileLogger.logFileManager.maximumNumberOfLogFiles = 3;
    fileLogger.maximumFileSize = 1024 *1024;
    WILogInnerDebug(@"Log Path:%@",fileLogger.currentLogFileInfo.description);

    [DDLog addLogger:fileLogger];
#else
    WILogInnerDebug(@"not use CocoaLumberjack Log");
#endif
    //添加crash采集
    //NSSetUncaughtExceptionHandler(&uncaughtExceptionHandler);
}

+(void)exceptionLog:(NSException *)e {
    WILogInnerError(@"[Exception]Reason:%@\nName: %@\nStack: %@",e.name,e.reason,e.callStackSymbols.description);
}

+(void)logError:(NSString *)sdkName tag:(NSString *)tag message:(NSString *)msg {
    WILogInnerError(@"[%@][error][%@] %@",sdkName,tag, msg);
}

+(void)logInfo:(NSString *)sdkName tag:(NSString *)tag message:(NSString *)msg {
    WILogInnerInfo(@"[%@][info][%@] %@",sdkName,tag, msg);
}

+(void)logDebug:(NSString *)sdkName tag:(NSString *)tag message:(NSString *)msg {
    WILogInnerDebug(@"[%@][debug][%@] %@",sdkName,tag, msg);
}

+(void)logError:(NSString *)sdkName class:(NSString *)className method:(NSString *)methodName message:(NSString *)msg {
    WILogInnerError(@"[%@][error][%@][%@] %@",sdkName,className,methodName, msg);
}

+(void)logInfo:(NSString *)sdkName class:(NSString *)className method:(NSString *)methodName message:(NSString *)msg {
    WILogInnerInfo(@"[%@][info][%@][%@] %@",sdkName,className,methodName, msg);
}

+(void)logDebug:(NSString *)sdkName class:(NSString *)className method:(NSString *)methodName message:(NSString *)msg {
    WILogInnerDebug(@"[%@][debug][%@][%@] %@",sdkName,className,methodName, msg);
}

//会拦截友盟crash上报，暂时不用该逻辑
void uncaughtExceptionHandler(NSException *exception) {
    NSString *reason = [exception reason];//出现异常的原因
    NSString *name = [exception name];//异常名称
    NSArray *stackArray = [exception callStackSymbols];//异常的堆栈信息
    NSString *exceptionInfo = [NSString stringWithFormat:@"Exceptionreason：%@\nExceptionname：%@\nExceptionstack：%@",name,reason,stackArray];
    NSLog(@"[CrashInfo]%@",exceptionInfo);
    
    NSMutableArray* tmpArr=[NSMutableArray arrayWithArray:stackArray];
    [tmpArr insertObject:reason atIndex:0];
    
    //保存到本地--当然你可以在下次启动的时候，上传这个log
    [exceptionInfo writeToFile:[NSString stringWithFormat:@"%@/Documents/error.log",NSHomeDirectory()] atomically:YES encoding:NSUTF8StringEncoding error:nil];
}

@end
