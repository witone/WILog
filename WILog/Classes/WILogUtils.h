//
//  WILogUtils.h
//  WILog
//
//  Created by zyp on 01/29/2021.
//  Copyright (c) 2021 zyp. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

#define WILogSave(tag, msg, bSave) [WILogUtils log:tag strMsg:msg isSave:bSave]

#define WILogError(sdkName, msg) [WILogUtils logError:sdkName class:NSStringFromClass(self.class) method:NSStringFromSelector(_cmd) message:msg];
#define WILogInfo(sdkName, msg) [WILogUtils logInfo:sdkName class:NSStringFromClass(self.class) method:NSStringFromSelector(_cmd) message:msg];
#define WILogDebug(sdkName, msg) [WILogUtils logDebug:sdkName class:NSStringFromClass(self.class) method:NSStringFromSelector(_cmd) message:msg];

#define WILogTagError(sdkName, t, msg) [WILogUtils logError:sdkName tag:t message:msg];
#define WILogTagInfo(sdkName, t, msg) [WILogUtils logInfo:sdkName tag:t message:msg];
#define WILogTagDebug(sdkName, t, msg) [WILogUtils logDebug:sdkName tag:t message:msg];

@interface WILogUtils : NSObject

+(void)initLogWithPath:(nullable NSString *)logPath;

+(void)exceptionLog:(NSException *)e;

+(void)logError:(NSString *)sdkName tag:(NSString *)tag message:(NSString *)msg;
+(void)logInfo:(NSString *)sdkName tag:(NSString *)tag message:(NSString *)msg;
+(void)logDebug:(NSString *)sdkName tag:(NSString *)tag message:(NSString *)msg;

+(void)logError:(NSString *)sdkName class:(NSString *)className method:(NSString *)methodName message:(NSString *)msg;
+(void)logInfo:(NSString *)sdkName class:(NSString *)className method:(NSString *)methodName message:(NSString *)msg;
+(void)logDebug:(NSString *)sdkName class:(NSString *)className method:(NSString *)methodName message:(NSString *)msg;

@end

NS_ASSUME_NONNULL_END
