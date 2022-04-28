//
//  CEMach.h
//  CEMach
//
//  Created by lzy on 2022/4/28.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface CEMach : NSObject

+ (NSString *)appMd5;

+ (BOOL)isInjection;

+ (BOOL)isJailbroken;

@end

NS_ASSUME_NONNULL_END
