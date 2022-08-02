//
//  WILog.m
//  WILog
//
//  Created by zyp on 2022/7/15.
//

#import "WILog.h"

//log文件路径
#define wiLogDefaultDir [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingString:@"/log/"];

#define WIInnerLog(level, fmt, ...)   [WILog log:level format:(fmt), ##__VA_ARGS__];

NSInteger const wiDefaultLogMaxFileSize      = 1024 * 1024 * 2;      // 2 MB

@interface WILogConfig : NSObject

@property (nonatomic,assign) WILogLevel logLevel;
@property (nonatomic,assign) WILogType logType;

@property (nonatomic,strong) NSString *prefixName;
@property (nonatomic,strong) NSString *logDirectory;
@property (nonatomic,assign) NSInteger fileMaxSize;

+(WILogConfig *)defaultConfig;

@end

@implementation WILogConfig

+ (instancetype)defaultConfig {
    static WILogConfig *_wiLogDefaultConfig = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _wiLogDefaultConfig = [[self alloc] init];
    });
    return _wiLogDefaultConfig;
}

-(instancetype)init {
    if (self  = [super init]) {
        self.logType = WILogTypeDefault;
        self.logLevel = WILogLevelDebug;
        self.logDirectory = wiLogDefaultDir;
        self.prefixName = @"WILog";
        self.fileMaxSize = wiDefaultLogMaxFileSize;
    }
    return self;
}

-(void)setLogDirectory:(NSString *)logDirectory {
    if (![_logDirectory isEqualToString:logDirectory]) {
        _logDirectory = logDirectory;
    }
    if (![[NSFileManager defaultManager] fileExistsAtPath:logDirectory]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:logDirectory withIntermediateDirectories:YES attributes:nil error:nil];
    }
}

@end

@interface WILog () {
    NSFileHandle *_currentLogFileHandle;
}

@property (nonatomic, copy) NSString  *currentLogFileName;
@property (nonatomic, copy) NSString  *nextLogFileName;

@end

@implementation WILog

+ (instancetype)shareInstance {
    static WILog *_wiLogInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _wiLogInstance = [[self alloc] init];
    });
    return _wiLogInstance;
}

-(instancetype)init {
    if (self  = [super init]) {
        if ([[WILogConfig defaultConfig] logType] & WILogTypeFile) [self wi_writeToFile:@"\n\n\n"];
    }
    return self;
}

+(void)setPrefixName:(NSString *)prefixName {
    [[WILogConfig defaultConfig] setPrefixName:prefixName];
}

+(void)setLogLevel:(WILogLevel)logLevel {
    [[WILogConfig defaultConfig] setLogLevel:logLevel];
}

+(void)setLogType:(WILogType)logType {
    [[WILogConfig defaultConfig] setLogType:logType];
}

+(void)setFileMaxSize:(NSInteger)fileMaxSize {
    [[WILogConfig defaultConfig] setFileMaxSize:fileMaxSize];
}

+(void)setLogDirectory:(NSString *)logDirectory {
    [[WILogConfig defaultConfig] setLogDirectory:logDirectory];
}

+(NSString *)logDirectory {
    NSString *logDir = [[WILogConfig defaultConfig] logDirectory];
    if (logDir && logDir.length>0) return logDir;
    return wiLogDefaultDir;
}

+(NSString *)currentLogFilePath {
    NSString *filePath = [NSString stringWithFormat:@"%@%@", [[WILogConfig defaultConfig] logDirectory], [self.shareInstance currentLogFileName]];
    return filePath;
}

+(void)exceptionLog:(NSException *)e {
    WIInnerLog(WILogLevelError,@"[Exception]Reason:%@\nName: %@\nStack: %@",e.name,e.reason,e.callStackSymbols.description);
}

+(void)log:(WILogLevel)level format:(NSString *)format, ... {
    if (level >= [[WILogConfig defaultConfig] logLevel]) {
        if (!format) format = @"(null)";
        va_list args;
        va_start(args, format);
        [[self shareInstance] wi_log:level prefix:[[WILogConfig defaultConfig] prefixName] format:format vaList:args];
        va_end(args);
    }
}

+(void)log:(WILogLevel)level prefix:(NSString *)prefix format:(NSString *)format, ... {
    if (level >= [[WILogConfig defaultConfig] logLevel]) {
        if (!format) format = @"(null)";
        va_list args;
        va_start(args, format);
        [[self shareInstance] wi_log:level prefix:prefix format:format vaList:args];
        va_end(args);
    }
}

-(void)wi_log:(WILogLevel)level prefix:(NSString *)prefix format:(NSString *)format vaList:(va_list)args {
    NSString *logLevelStr = @"";
    switch (level) {
        case WILogLevelDebug: logLevelStr = @"debug";  break;
        case WILogLevelInfo:  logLevelStr = @"info";   break;
        case WILogLevelError: logLevelStr = @"error";  break;
        default: logLevelStr = @"debug";  break;
    }
    NSString *formatTmp;
    NSString *timeStr = [[self.class dateFormatter] stringFromDate:[NSDate date]];
    if (prefix && prefix.length) {
        formatTmp = [NSString stringWithFormat:@"%@ [%@][%@]%@\n",timeStr,prefix,logLevelStr,format];
    }else {
        formatTmp = [NSString stringWithFormat:@"%@ [%@]%@\n",timeStr,logLevelStr,format];
    }
    NSString *message = [[NSString alloc] initWithFormat:formatTmp arguments:args];
    if ([[WILogConfig defaultConfig] logType] & WILogTypeDefault) printf("%s", message.UTF8String);
    if ([[WILogConfig defaultConfig] logType] & WILogTypeFile) [self wi_writeToFile:message];
}

-(void)wi_writeToFile:(NSString *)logMessage {//使用NSFileHandle来写入数据
    dispatch_async([self.class wi_operationQueue], ^{//异步串行队列
        if (self->_currentLogFileHandle == nil) {
            self.currentLogFileName = self.nextLogFileName;
            NSString *filePath = [NSString stringWithFormat:@"%@%@", [[WILogConfig defaultConfig] logDirectory], self.currentLogFileName];
            [[NSData new] writeToFile:filePath options:NSDataWritingAtomic error:nil];
            self->_currentLogFileHandle = [NSFileHandle fileHandleForUpdatingAtPath:filePath];
        }
        //[self->_currentLogFileHandle seekToEndOfFile];
        [self->_currentLogFileHandle writeData:[logMessage dataUsingEncoding:NSUTF8StringEncoding]];
        unsigned long long fileSize = [self->_currentLogFileHandle offsetInFile];
        if ([[WILogConfig defaultConfig] fileMaxSize]>0 && fileSize > [[WILogConfig defaultConfig] fileMaxSize]) {
            [self->_currentLogFileHandle closeFile];
            self->_currentLogFileHandle = nil;
        }
    });
}

- (NSString *)nextLogFileName {
    NSString *timeStr = [[self.class dateFormatter] stringFromDate:[NSDate date]];

    _nextLogFileName = [NSString stringWithFormat:@"%@.log", timeStr];
    static int index = 0;

    if ([self.currentLogFileName isEqualToString:_nextLogFileName]) {
        _nextLogFileName = [NSString stringWithFormat:@"%@_%02d.log", timeStr, ++index];
    } else {
        index = 0;
    }

    return _nextLogFileName;
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
