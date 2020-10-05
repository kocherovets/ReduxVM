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

#import "DITranquillity.h"
#import "NSObject+Swizzling.h"
#import "DINSResolver.h"
#import "DIStoryboardBase.h"
#import "UIView+Swizzling.h"

FOUNDATION_EXPORT double DITranquillityVersionNumber;
FOUNDATION_EXPORT const unsigned char DITranquillityVersionString[];

