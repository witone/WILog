//
//  WILog.h
//  WILog
//
//  Created by zyp on 2022/7/15.
//

#import <Foundation/NSObject.h>
#import <Foundation/NSItemProvider.h>
#import <stdarg.h>

NS_ASSUME_NONNULL_BEGIN

#define WILogError(fmt, ...)            [WILog log:WILogLevelError format:(fmt), ##__VA_ARGS__];
#define WILogInfo(fmt, ...)             [WILog log:WILogLevelInfo format:(fmt), ##__VA_ARGS__];
#define WILogDebug(fmt, ...)            [WILog log:WILogLevelDebug format:(fmt), ##__VA_ARGS__];

#define WILogPrefixError(p,fmt, ...)    [WILog log:WILogLevelError prefix:p format:(fmt), ##__VA_ARGS__];
#define WILogPrefixInfo(p,fmt, ...)     [WILog log:WILogLevelInfo prefix:p format:(fmt), ##__VA_ARGS__];
#define WILogPrefixDebug(p,fmt, ...)    [WILog log:WILogLevelDebug prefix:p format:(fmt), ##__VA_ARGS__];

typedef NS_ENUM(NSUInteger, WILogLevel) {
    WILogLevelDebug           = 0,//debug
    WILogLevelInfo            = 1,//info
    WILogLevelError           = 2,//error
};

typedef NS_OPTIONS(NSUInteger, WILogType){
    WILogTypeNone             = (1 << 0),//0...00001 不打印日志
    WILogTypeDefault          = (1 << 1),//0...00010 NSLog日志输出
    WILogTypeFile             = (1 << 2),//0...00100 File文件输出
};

@interface WILog : NSObject

//默认WILog
+(void)setPrefixName:(NSString *)prefixName;
//默认全类型输出
+(void)setLogLevel:(WILogLevel)logLevel;
//默认WILogTypeDefault
+(void)setLogType:(WILogType)logType;

+(NSString *)currentLogFilePath;

+(void)initLog:(WILogLevel)level withType:(WILogType)type withDir:(nullable NSString *)logDir;

+(void)exceptionLog:(NSException *)e;

+(void)log:(WILogLevel)level format:(NSString *)format, ... NS_FORMAT_FUNCTION(2,3);
+(void)log:(WILogLevel)level prefix:(NSString *)prefix format:(NSString *)format, ... NS_FORMAT_FUNCTION(3,4);

@end

NS_ASSUME_NONNULL_END
