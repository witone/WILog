//
//  WILog.h
//  WILog
//
//  Created by BestWeather on 2022/7/15.
//

#import <Foundation/NSObject.h>
#import <Foundation/NSItemProvider.h>
#import <stdarg.h>

NS_ASSUME_NONNULL_BEGIN

#define WILogError(sdk, msg, ...) [WILog log:WILogLevelError sdkName:sdk className:NSStringFromClass(self.class) methodName:NSStringFromSelector(_cmd) message:(msg), ##__VA_ARGS__];
#define WILogInfo(sdk, msg, ...)  [WILog log:WILogLevelInfo sdkName:sdk className:NSStringFromClass(self.class) methodName:NSStringFromSelector(_cmd) message:(msg), ##__VA_ARGS__];
#define WILogDebug(sdk, msg, ...) [WILog log:WILogLevelDebug sdkName:sdk className:NSStringFromClass(self.class) methodName:NSStringFromSelector(_cmd) message:(msg), ##__VA_ARGS__];

#define WILogTagError(sdk, t, msg, ...) [WILog log:WILogLevelError sdkName:sdk tag:t message:(msg), ##__VA_ARGS__];
#define WILogTagInfo(sdk, t, msg, ...)  [WILog log:WILogLevelInfo sdkName:sdk tag:t message:(msg), ##__VA_ARGS__];
#define WILogTagDebug(sdk, t, msg, ...) [WILog log:WILogLevelDebug sdkName:sdk tag:t message:(msg), ##__VA_ARGS__];

typedef NS_ENUM(NSUInteger, WILogLevel) {
    WILogLevelDebug           = 0,//debug
    WILogLevelInfo            = 1,//info
    WILogLevelError           = 2,//error
};

@interface WILog : NSObject

+(void)showInXcode;
+(void)initLog:(WILogLevel)level withPath:(nullable NSString *)logPath;

+(void)exceptionLog:(NSException *)e;

+(void)log:(WILogLevel)level sdkName:(NSString *)sdkName tag:(NSString *)tag message:(NSString *)msg, ... NS_FORMAT_FUNCTION(4,5);

+(void)log:(WILogLevel)level sdkName:(NSString *)sdkName className:(NSString *)className methodName:(NSString *)methodName message:(NSString *)msg, ... NS_FORMAT_FUNCTION(5,6);

@end

NS_ASSUME_NONNULL_END
