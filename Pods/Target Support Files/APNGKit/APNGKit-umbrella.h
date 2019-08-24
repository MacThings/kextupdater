#ifdef __OBJC__
#import <Cocoa/Cocoa.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "APNGKit.h"
#import "png.h"
#import "pnglibconf.h"
#import "pngconf.h"

FOUNDATION_EXPORT double APNGKitVersionNumber;
FOUNDATION_EXPORT const unsigned char APNGKitVersionString[];

