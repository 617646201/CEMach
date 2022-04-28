//
//  CEMachManager.h
//  CEMach
//
//  Created by lzy on 2020/3/2.
//  Copyright © 2020 demo. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

namespace CEMachUtil {

    class CEMachManager{
        public:

        //单利
        static CEMachManager& getInstance() {
            static CEMachManager instance;
            return instance;
        };
        
        //设置动态库白名单,loadDylib()中不会返回白名单中的内容
        void setDylibWhiteList(NSArray * list);
        
        //获取动态库列表
        NSArray * loadDylib();
        
        NSArray * loadALLDylib();
        
        //获取代码MD5
        NSString * getMd5();
        
        //是否注入
        BOOL isInjection();

        //是否越狱
        BOOL isJailbroken();
       
        private:
        //私有化
        CEMachManager() { };
        ~CEMachManager() { };
        CEMachManager(const CEMachManager&);
        CEMachManager& operator=(const CEMachManager&);
        
        NSArray * dylibWhiteList;
    };

}

NS_ASSUME_NONNULL_END
