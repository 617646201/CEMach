//
//  CEMachManager.m
//  CEMach
//
//  Created by lzy on 2020/3/2.
//  Copyright © 2020 demo. All rights reserved.
//

#import "CEMachManager.h"
#import "CEMachSign.h"
#import "CEMachJailbroken.h"

namespace CEMachUtil {

    //设置动态库白名单,loadDylib()中不会返回白名单中的内容
    void CEMachManager::setDylibWhiteList(NSArray * list){
        this->dylibWhiteList = list;
    }
    
    //获取动态库列表
    NSArray * CEMachManager::loadDylib(){
        NSMutableArray * list = [CEMachSign::loadDylib() mutableCopy];
        
        if(this->dylibWhiteList.count > 0){
            for (int i = 0;i < list.count;i++) {
                NSString * dylibName = list[i];
                if([this->dylibWhiteList containsObject:dylibName.lastPathComponent]){
                    [list removeObject:dylibName];
                    i--;
                }
            }
        }
        return list;
    }

    NSArray * loadALLDylib(){
        return CEMachSign::loadDylib();
    }
    
    //获取代码MD5
    NSString * CEMachManager::getMd5(){
        return CEMachSign::getMd5();
    }

    //是否注入
    BOOL CEMachManager::isInjection(){
        NSArray * libs = CEMachSign::loadDylib();
        for (NSString * lib in libs) {
            if ([lib containsString:@".dylib"]) {
                if([this->dylibWhiteList containsObject:lib.lastPathComponent]){
                    continue ;
                }

                if (![lib containsString:@"/usr/lib"]) {
                    return YES;
                }
            }
        }
        return NO;
    }

    //是否越狱
    BOOL CEMachManager::isJailbroken(){
        return CEMachJailbroken::isJailbroken();
    }
}
