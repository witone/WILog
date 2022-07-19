//
//  WILog.m
//  WILog
//
//  Created by BestWeather on 2022/7/15.
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
        NSString *fileName = [NSString stringWithFormat:@"wiLog.log"];
        NSString *filePath = [wiLogDir stringByAppendingPathComponent:fileName];
        
        wiLogFilePath = filePath;
#if DEBUG
        NSLog(@"LogPath: %@", wiLogFilePath);
#endif
        //创建log文件
        if([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
            //NSString *initString = @"log初始化。。。\n";
            //[initString writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
        } else {
            [[NSFileManager defaultManager] createFileAtPath:filePath contents:nil attributes:nil];
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
            case WILogLevelDebug: logLevelStr = @"DEBUG";  break;
            case WILogLevelInfo:  logLevelStr = @"INFO ";  break;
            case WILogLevelError: logLevelStr = @"ERROR";  break;
            default: logLevelStr = @"DEBUG";  break;
        }
        NSString *formatTmp = [NSString stringWithFormat:@"[%@]%@",logLevelStr,format];
        if (wiPrefixName && wiPrefixName.length) formatTmp = [[NSString stringWithFormat:@"[%@]",wiPrefixName] stringByAppendingString:formatTmp];
        NSString *message = [[NSString alloc] initWithFormat:formatTmp arguments:args];
        if (wiLogType & WILogTypeDefault) NSLog(@"%@",message);
        if (wiLogType & WILogTypeFile) {
            dispatch_async([self.class wi_operationQueue], ^{//异步串行队列
                NSString *logMessage = [NSString stringWithFormat:@"%@ %@\n", [[self.class dateFormatter] stringFromDate:[NSDate date]],message];
                //使用NSFileHandle来写入数据
                NSFileHandle *file = [NSFileHandle fileHandleForUpdatingAtPath:wiLogFilePath];
                [file seekToEndOfFile];
                [file writeData:[logMessage dataUsingEncoding:NSUTF8StringEncoding]];
                [file closeFile];
            });
        }
    }
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
