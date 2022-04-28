//
//  CEMachSign.m
//  CEMach
//
//  Created by lzy on 2020/3/2.
//  Copyright © 2020 demo. All rights reserved.
//

#import "CEMachSign.h"
#import <mach-o/dyld.h>
#import <CommonCrypto/CommonDigest.h>

#ifdef __LP64__
typedef struct mach_header_64 mach_header_t;
typedef struct segment_command_64 segment_command_t;
typedef struct section_64 section_t;
typedef struct nlist_64 nlist_t;
typedef uint64_t local_addr;
#define LC_SEGMENT_ARCH_DEPENDENT LC_SEGMENT_64
#else
typedef struct mach_header mach_header_t;
typedef struct segment_command segment_command_t;
typedef struct section section_t;
typedef struct nlist nlist_t;
typedef uint32_t local_addr;
#define LC_SEGMENT_ARCH_DEPENDENT LC_SEGMENT
#endif

typedef struct _section_info_t{
    section_t *section;
    local_addr addr;
}section_info_t;

typedef struct _segment_info_t{
    segment_command_t *segment;
    local_addr addr;
}segment_info_t;

namespace CEMachSign {

    class CESMachOParser{
        public:
            void* base;
            long slide;
        public:
            CESMachOParser();
            CESMachOParser(const char* base);
            CESMachOParser(void* base, local_addr slide);
            
            /**
             find mach-o load command load dylib name
             @return array of dylibs
             */
            NSArray* find_load_dylib();
            
            /**
             get mach-o segment
             @param segname segment name
             @return segment struct
             */
            segment_info_t* find_segment(const char* segname);
            
            /**
             get mach-o section
             @param segname segment name
             @param secname section name
             @return section struct
             */
            section_info_t* find_section(const char* segname,const char* secname);
            
            /**
             get md5 value from text in memory
             @return md5 string
             */
            NSString* get_text_data_md5();
        private:
            local_addr vm2real(local_addr vmaddr);
    };

#pragma mark - CEMachOParser
CESMachOParser::CESMachOParser(){
    this->base = (void*)_dyld_get_image_header(0);
    this->slide = _dyld_get_image_vmaddr_slide(0);
}

CESMachOParser::CESMachOParser(void* base,local_addr slide){
    this->base = base;
    this->slide = slide;
}

CESMachOParser::CESMachOParser(const char* name){
    unsigned imgCount = _dyld_image_count();
    for (unsigned i = 0; i < imgCount; i++) {
        const char *imgName = _dyld_get_image_name(i);
        if(strstr(imgName,name)){
            this->base = (void*)_dyld_get_image_header(i);
            this->slide = _dyld_get_image_vmaddr_slide(i);
            return;
        }
    }
}

local_addr CESMachOParser::vm2real(local_addr vmaddr){
    return this->slide + vmaddr;
}

#pragma mark - 获取加载的动态库
NSArray* CESMachOParser::find_load_dylib(){
    NSMutableArray* array = [[NSMutableArray alloc] init];;
    mach_header_t *header = (mach_header_t*)base;
    segment_command_t *cur_seg_cmd;
    uintptr_t cur = (uintptr_t)this->base + sizeof(mach_header_t);
    for (uint i = 0; i < header->ncmds; i++,cur += cur_seg_cmd->cmdsize) {
        cur_seg_cmd = (segment_command_t*)cur;
        if(cur_seg_cmd->cmd == LC_LOAD_DYLIB || cur_seg_cmd->cmd == LC_LOAD_WEAK_DYLIB){
            dylib_command *dylib = (dylib_command*)cur_seg_cmd;
            char* name = (char*)((uintptr_t)dylib + dylib->dylib.name.offset);
            NSString* dylibName = [NSString stringWithUTF8String:name];
            [array addObject:dylibName];
        }
    }
    return [array copy];
}

#pragma mark -查找某个段
segment_info_t* CESMachOParser::find_segment(const char *segname){
    mach_header_t *header = (mach_header_t*)base;
    segment_command_t *cur_seg_cmd;
    uintptr_t cur = (uintptr_t)this->base + sizeof(mach_header_t);
    for (uint i = 0; i < header->ncmds; i++,cur += cur_seg_cmd->cmdsize) {
        cur_seg_cmd = (segment_command_t*)cur;
        if(cur_seg_cmd->cmd == LC_SEGMENT_ARCH_DEPENDENT){
            if(!strcmp(segname,cur_seg_cmd->segname)){
                segment_info_t *cur_segment_info = new segment_info_t();
                cur_segment_info->segment = cur_seg_cmd;
                cur_segment_info->addr = this->vm2real(cur_seg_cmd->vmaddr);
                return cur_segment_info;
            }
        }
    }
    return nullptr;
}

#pragma mark -查找某个节
section_info_t* CESMachOParser::find_section(const char *segname, const char *secname){
    mach_header_t *header = (mach_header_t*)base;
    segment_command_t *cur_seg_cmd;
    uintptr_t cur = (uintptr_t)this->base + sizeof(mach_header_t);
    for (uint i = 0; i < header->ncmds; i++,cur += cur_seg_cmd->cmdsize) {
        cur_seg_cmd = (segment_command_t*)cur;
        if(cur_seg_cmd->cmd != LC_SEGMENT_ARCH_DEPENDENT){
            continue;
        }
        if(!strcmp(segname,cur_seg_cmd->segname)){
            for (uint j = 0; j < cur_seg_cmd->nsects; j++) {
                section_t *sect = (section_t *)(cur + sizeof(segment_command_t)) + j;
                if(!strcmp(secname, sect->sectname)){
                    section_info_t *cur_section_info = new section_info_t();
                    cur_section_info->section = sect;
                    cur_section_info->addr = this->vm2real(sect->addr);
                    return cur_section_info;
                }
            }
        }
    }
    return nullptr;
}

#pragma mark - 获取运行代码md5
NSString* CESMachOParser::get_text_data_md5(){
    NSMutableString *result = [NSMutableString string];
    section_info_t *section = this->find_section("__TEXT", "__text");
    local_addr startAddr =  section->addr;
    unsigned char hash[CC_MD5_DIGEST_LENGTH];
    CC_MD5((const void *)startAddr, (CC_LONG)section->section->size, hash);
    for (int i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
        [result appendFormat:@"%02x",hash[i]];
    }
    return [result copy];
}

#pragma mark - CESecurityMach
NSArray * loadDylib(){
        CESMachOParser * mo = new CESMachOParser();
        return mo->find_load_dylib();
}

NSString * getMd5(){
    CESMachOParser * mo = new CESMachOParser();
    return mo->get_text_data_md5();
}

void findsg(NSString * str){
    CESMachOParser *mo = new CESMachOParser();
    mo->find_segment([str UTF8String]);
}

}
