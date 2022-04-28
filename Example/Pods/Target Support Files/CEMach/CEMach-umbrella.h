#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "CEMachJailbroken.h"
#import "CEMachManager.h"
#import "CEMachSign.h"

FOUNDATION_EXPORT double CEMachVersionNumber;
FOUNDATION_EXPORT const unsigned char CEMachVersionString[];

