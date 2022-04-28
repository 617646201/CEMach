//
//  CEMach.m
//  CEMach
//
//  Created by lzy on 2022/4/28.
//

#import "CEMach.h"
#import "CEMachManager.h"

@interface CEMach ()

@property (nonatomic,strong) NSString * appMd5;

@property (nonatomic,assign) BOOL isInjection;

@property (nonatomic,assign) BOOL isJailbroken;

@end

@implementation CEMach

+(instancetype)instance
{
    static CEMach * instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    
    return instance;
}

- (instancetype)init {
    if ((self = [super init]))
    {
        self.appMd5 = @"";
        self.isInjection = NO;
        self.isJailbroken = NO;
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            self.appMd5 = CEMachUtil::CEMachManager::getInstance().getMd5();
            self.isInjection = CEMachUtil::CEMachManager::getInstance().isInjection();
            self.isJailbroken = CEMachUtil::CEMachManager::getInstance().isJailbroken();
        });
    }
    
    return self;
}

+ (NSString *)appMd5 {
    return  [[CEMach instance] appMd5];
}

+ (BOOL)isInjection {
    return  [[CEMach instance] isInjection];
}

+ (BOOL)isJailbroken {
    return  [[CEMach instance] isJailbroken];
}

@end
