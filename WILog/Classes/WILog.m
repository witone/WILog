//
//  WILog.m
//  WILog
//
//  Created by BestWeather on 2022/7/15.
//

#import "WILog.h"

static int ddLogLevel = 0;// 定义日志级别

#if __has_include(<CocoaLumberjack/CocoaLumberjack.h>)
#import <CocoaLumberjack/CocoaLumberjack.h>

#define WILogInnerError(frmt, ...)   DDLogError(frmt, ##__VA_ARGS__)
#define WILogInnerInfo(frmt, ...)    DDLogInfo(frmt, ##__VA_ARGS__)
#define WILogInnerDebug(frmt, ...)   DDLogDebug(frmt, ##__VA_ARGS__)

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

#define WILogInner(sdk,level,frmt, ...)                                                 \
        switch (level) {                                                                \
            case WILogLevelError:                                                       \
                WILogInnerError((@"[%@][error]" frmt),sdk, ##__VA_ARGS__);break;        \
            case WILogLevelInfo:                                                        \
                WILogInnerInfo((@"[%@][info]" frmt),sdk, ##__VA_ARGS__);break;          \
            default:                                                                    \
                WILogInnerDebug((@"[%@][debug]" frmt),sdk, ##__VA_ARGS__);break;        \
        }

@implementation WILog

+(void)showInXcode {
#if __has_include(<CocoaLumberjack/CocoaLumberjack.h>)
    //[DDLog addLogger:[DDASLLogger sharedInstance]];//打印到系统
    if (@available(iOS 10.0, *)){
        [DDLog addLogger:[DDOSLogger sharedInstance]];
    }else {
        [DDLog addLogger:[DDTTYLogger sharedInstance]];//打印到xcode
    }
#endif
}

+(void)initLog:(WILogLevel)level withPath:(nullable NSString *)logPath {
#if __has_include(<CocoaLumberjack/CocoaLumberjack.h>)

    switch (level) {
        case WILogLevelError:
            ddLogLevel = DDLogLevelError;
            break;
        case WILogLevelInfo:
            ddLogLevel = DDLogLevelInfo;
            break;
        default:
            ddLogLevel = DDLogLevelVerbose;
            break;
    }

    DDFileLogger *fileLogger;
    if (logPath && logPath.length>0) {
        fileLogger = [[DDFileLogger alloc] initWithLogFileManager:[[DDLogFileManagerDefault alloc]initWithLogsDirectory:logPath]];
    }else {
        fileLogger = [[DDFileLogger alloc] init];
    }
    
    fileLogger.rollingFrequency = 60 * 60 * 24; // 24 hour rolling
    fileLogger.logFileManager.maximumNumberOfLogFiles = 5;
    fileLogger.maximumFileSize = 1024 *1024;
    [DDLog addLogger:fileLogger];
    WILogInnerDebug(@"Base CocoaLumberjack Log Path:%@",fileLogger.currentLogFileInfo.description);
#else
    WILogInnerDebug(@"Base NSLog");
#endif
    //添加crash采集
    //NSSetUncaughtExceptionHandler(&uncaughtExceptionHandler);
}

+(void)exceptionLog:(NSException *)e {
    WILogInnerError(@"[Exception]Reason:%@\nName: %@\nStack: %@",e.name,e.reason,e.callStackSymbols.description);
}

+(void)log:(WILogLevel)level sdkName:(NSString *)sdkName tag:(NSString *)tag message:(NSString *)msg, ... {
    va_list args;
    va_start(args, msg);
    NSString *message = [[NSString alloc] initWithFormat:msg arguments:args];
    va_end(args);
    WILogInner(sdkName, level, @"[%@] %@",tag,message);
}

+(void)log:(WILogLevel)level sdkName:(NSString *)sdkName className:(NSString *)className methodName:(NSString *)methodName message:(NSString *)msg, ... {
    va_list args;
    va_start(args, msg);
    NSString *message = [[NSString alloc] initWithFormat:msg arguments:args];
    va_end(args);
    WILogInner(sdkName, level, @"[%@][%@] %@",className,methodName, message);
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
