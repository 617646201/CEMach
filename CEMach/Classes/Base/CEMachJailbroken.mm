//
//  CEMachJailbroken.m
//  CEMach
//
//  Created by lzy on 2020/3/2.
//  Copyright © 2020 demo. All rights reserved.
//

#import "CEMachJailbroken.h"
#import <sys/stat.h>

#ifdef __IPHONE_10_0

static __attribute__((always_inline)) void asm_open(const char *path) {
#ifdef __arm64__
    __asm__("mov x1,x0\n"
            "mov x0, #5\n"
            "mov x2, #0\n"
            "mov w16, #0\n"
            "svc #0x80\n"
            );
#endif
}

static int scvvoid(const char *path){
  asm_open(path);
  int request;
  __asm__(
          "mov %[result], x0\n"
          : [result] "=r" (request)
          );
  return request;
}

#endif

namespace CEMachJailbroken {
    
    #pragma mark - Apps and System check list
    BOOL systemFileIsJailbroken(){
        #if !TARGET_IPHONE_SIMULATOR

        NSArray * pathList = @[
        @"/Applications/Cydia.app",
        @"/Library/MobileSubstrate/MobileSubstrate.dylib",
        @"/Library/MobileSubstrate/DynamicLibraries/afc2dSupport.dylib"
        ];
    
        for (NSString * path in pathList) {
            char* c_path = (char*) [path cStringUsingEncoding:NSUTF8StringEncoding];
            
            FILE *f = fopen(c_path,"r");
            if (f != NULL) {
                fclose(f);
                return YES;
            }
            
            int ret =  open(c_path,O_RDONLY);
            if(ret >= 0){;
                close(ret);
                return YES;
            }
            
            int sret = syscall(5,c_path,O_RDONLY);
            if(sret >= 0){;
                close(sret);
                return YES;
            }
            
            if (@available(iOS 10.0, *)) {
                //内核方式调用open。只有汇编能干掉。如果干掉会改变程序md5
                int scvret = scvvoid(c_path);
                if(scvret > 2){;
                    close(scvret);
                    return YES;
                }
            }
        }
       
        //stat
        struct stat stat_info;
        if (0 == stat("/Applications/Cydia.app", &stat_info)) {
            return YES;
        }
        
        #endif
        return NO;
    }

    BOOL isJailbroken(){
        BOOL systemFile = systemFileIsJailbroken();
        return systemFile;
    }
    
}
