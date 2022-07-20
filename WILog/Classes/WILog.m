//
//  WILog.m
//  WILog
//
//  Created by zyp on 2022/7/15.
//

#import "WILog.h"

// 定义日志级别
static NSString *wiPrefixName = @"WILog";
static WILogLevel wiLogLevel = WILogLevelDebug;
static WILogType wiLogType = WILogTypeDefault;

//log文件路径
#define wiLogDefaultDir [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingString:@"/log/"];
static NSString *wiLogFilePath = nil;
//log目录路径
static NSString *wiLogDir = nil;

#define WIInnerLog(level, fmt, ...)   [WILog log:level format:(fmt), ##__VA_ARGS__];

@implementation WILog

+(void)setPrefixName:(NSString *)prefixName {
    wiPrefixName = prefixName;
}

+(void)setLogLevel:(WILogLevel)logLevel {
    wiLogLevel = logLevel;
}

+(void)setLogType:(WILogType)logType {
    wiLogType = logType;
}

+(void)setLogDirectory:(NSString *)logDirectory {
    wiLogDir = logDirectory;
}

+(NSString *)logDirectory {
    if (wiLogDir && wiLogDir.length>0) return wiLogDir;
    return wiLogDefaultDir;
}

+(void)initLog:(WILogLevel)level withType:(WILogType)type withDir:(nullable NSString *)logDir {
    wiLogLevel = level;
    wiLogType = type;

    
    if (logDir && logDir.length>0) {
        wiLogDir = logDir;
    }else {
        wiLogDir = wiLogDefaultDir;
    }
    
    if (!wiLogFilePath) {
        //创建log文件夹
        if (![[NSFileManager defaultManager] fileExistsAtPath:wiLogDir]) {
            [[NSFileManager defaultManager] createDirectoryAtPath:wiLogDir withIntermediateDirectories:YES attributes:nil error:nil];
        }

        NSString *fileName = [NSString stringWithFormat:@"wiLog.log"];
        NSString *filePath = [wiLogDir stringByAppendingPathComponent:fileName];
        
        wiLogFilePath = filePath;
#if DEBUG
        NSLog(@"LogPath: %@", wiLogFilePath);
#endif
        //创建log文件
        if(![[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
            BOOL result = [[NSFileManager defaultManager] createFileAtPath:filePath contents:nil attributes:nil];
            if (!result) NSLog(@"创建日志文件失败");
        }else {
            if (wiLogType & WILogTypeFile) [self writeToFile:@"\n\n\n" showTime:NO];
        }
    }
}

+(void)exceptionLog:(NSException *)e {
    WIInnerLog(WILogLevelError,@"[Exception]Reason:%@\nName: %@\nStack: %@",e.name,e.reason,e.callStackSymbols.description);
}

+(void)log:(WILogLevel)level format:(NSString *)format, ... {
    va_list args;
    va_start(args, format);
    [self log:level format:format vaList:args];
    va_end(args);
}

+ (void)log:(WILogLevel)level format:(NSString *)format vaList:(va_list)args {
    if (level >= wiLogLevel) {
        NSString *logLevelStr = @"";
        switch (level) {
            case WILogLevelDebug: logLevelStr = @"debug";  break;
            case WILogLevelInfo:  logLevelStr = @"info";   break;
            case WILogLevelError: logLevelStr = @"error";  break;
            default: logLevelStr = @"debug";  break;
        }
        NSString *formatTmp = [NSString stringWithFormat:@"[%@]%@",logLevelStr,format];
        if (wiPrefixName && wiPrefixName.length) formatTmp = [[NSString stringWithFormat:@"[%@]",wiPrefixName] stringByAppendingString:formatTmp];
        NSString *message = [[NSString alloc] initWithFormat:formatTmp arguments:args];
        if (wiLogType & WILogTypeDefault) NSLog(@"%@",message);
        if (wiLogType & WILogTypeFile) [self writeToFile:message showTime:YES];
    }
}

+(void)writeToFile:(NSString *)logMessage showTime:(BOOL)showTime {//使用NSFileHandle来写入数据
    dispatch_async([self.class wi_operationQueue], ^{//异步串行队列
        NSString *logMessageTmp = logMessage;
        if (showTime) logMessageTmp = [NSString stringWithFormat:@"%@ %@\n", [[self.class dateFormatter] stringFromDate:[NSDate date]],logMessage];
        NSFileHandle *file = [NSFileHandle fileHandleForUpdatingAtPath:wiLogFilePath];
        [file seekToEndOfFile];
        [file writeData:[logMessageTmp dataUsingEncoding:NSUTF8StringEncoding]];
        [file closeFile];
    });
}

+(dispatch_queue_t)wi_operationQueue {
    static dispatch_queue_t wi_operationQueue;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        wi_operationQueue =  dispatch_queue_create("com.wilog.sdk.operationqueue", DISPATCH_QUEUE_SERIAL);
    });
    return wi_operationQueue;
}

+ (NSDateFormatter *)dateFormatter {
    static NSDateFormatter *dateFormatter;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if(!dateFormatter){
            dateFormatter = [NSDateFormatter new];
            dateFormatter.timeZone = [NSTimeZone timeZoneWithName:@"Asia/Shanghai"];
            dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss.SSS";
        }
    });
    return dateFormatter;
}

@end
