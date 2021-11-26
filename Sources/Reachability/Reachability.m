/*

 File: Reachability.m
 Abstract: Basic demonstration of how to use the SystemConfiguration Reachablity APIs.

 This file lifted from: https://gist.github.com/darkseed/1182373

 Version: 2.2 - ARCified

 Disclaimer: IMPORTANT:  This Apple software is supplied to you by Apple Inc.
 ("Apple") in consideration of your agreement to the following terms, and your
 use, installation, modification or redistribution of this Apple software
 constitutes acceptance of these terms.  If you do not agree with these terms,
 please do not use, install, modify or redistribute this Apple software.

 In consideration of your agreement to abide by the following terms, and subject
 to these terms, Apple grants you a personal, non-exclusive license, under
 Apple's copyrights in this original Apple software (the "Apple Software"), to
 use, reproduce, modify and redistribute the Apple Software, with or without
 modifications, in source and/or binary forms; provided that if you redistribute
 the Apple Software in its entirety and without modifications, you must retain
 this notice and the following text and disclaimers in all such redistributions
 of the Apple Software.
 Neither the name, trademarks, service marks or logos of Apple Inc. may be used
 to endorse or promote products derived from the Apple Software without specific
 prior written permission from Apple.  Except as expressly stated in this notice,
 no other rights or licenses, express or implied, are granted by Apple herein,
 including but not limited to any patent rights that may be infringed by your
 derivative works or by other works in which the Apple Software may be
 incorporated.

 The Apple Software is provided by Apple on an "AS IS" basis.  APPLE MAKES NO
 WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION THE IMPLIED
 WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS FOR A PARTICULAR
 PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND OPERATION ALONE OR IN
 COMBINATION WITH YOUR PRODUCTS.

 IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL OR
 CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE
 GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION, MODIFICATION AND/OR
 DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED AND WHETHER UNDER THEORY OF
 CONTRACT, TORT (INCLUDING NEGLIGENCE), STRICT LIABILITY OR OTHERWISE, EVEN IF
 APPLE HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

 Copyright (C) 2010 Apple Inc. All Rights Reserved.

 */

#import "TargetConditionals.h"

#import "Reachability.h"

#if TARGET_OS_IOS || TARGET_OS_TV || TARGET_OS_OSX

#import <sys/socket.h>
#import <netinet/in.h>
#import <netinet6/in6.h>
#import <arpa/inet.h>
#import <ifaddrs.h>
#import <netdb.h>

#import <SystemConfiguration/SystemConfiguration.h>
#import <CoreFoundation/CoreFoundation.h>

static void printReachabilityFlags(SCNetworkReachabilityFlags flags, const char *comment) {
    #if kShouldPrintReachabilityFlags
    NSLog(@"Reachability Flag Status: %c%c %c%c%c%c%c%c%c %s\n",
        #if TARGET_OS_IPHONE
          (flags & kSCNetworkReachabilityFlagsIsWWAN)                ? 'W' : '-',
        #else
          '-',
        #endif
          (flags & kSCNetworkReachabilityFlagsReachable)            ? 'R' : '-',
          (flags & kSCNetworkReachabilityFlagsTransientConnection)  ? 't' : '-',
          (flags & kSCNetworkReachabilityFlagsConnectionRequired)   ? 'c' : '-',
          (flags & kSCNetworkReachabilityFlagsConnectionOnTraffic)  ? 'C' : '-',
          (flags & kSCNetworkReachabilityFlagsInterventionRequired) ? 'i' : '-',
          (flags & kSCNetworkReachabilityFlagsConnectionOnDemand)   ? 'D' : '-',
          (flags & kSCNetworkReachabilityFlagsIsLocalAddress)       ? 'l' : '-',
          (flags & kSCNetworkReachabilityFlagsIsDirect)             ? 'd' : '-',
          comment
          );
    #endif
}

static void reachabilityCallback(SCNetworkReachabilityRef target, SCNetworkReachabilityFlags flags, void *info) {
#pragma unused (target, flags)
    NSCAssert(info != NULL, @"info was NULL in reachabilityCallback");
    NSCAssert([(__bridge NSObject *) info isKindOfClass:[Reachability class]], @"info was wrong class in reachabilityCallback");

    NSLog(@"Callback");

    // We're on the main RunLoop, so an NSAutoreleasePool is not necessary, but is added defensively
    // in case someone uses the Reachablity object in a different thread.
    @autoreleasepool {
        Reachability *reachability = (__bridge Reachability *)info;
        // Post a notification to notify the client that the network reachability changed.
        if (reachability.didChangeHandler != nil) {
            reachability.didChangeHandler(reachability);
        }
    }
}

@implementation Reachability {
    SCNetworkReachabilityRef _reachabilityRef;
}

- (BOOL)start {
    BOOL retVal = NO;
    SCNetworkReachabilityContext context = {0, (__bridge void *)self, NULL, NULL, NULL};

    if (SCNetworkReachabilitySetCallback(_reachabilityRef, reachabilityCallback, &context) &&
        SCNetworkReachabilityScheduleWithRunLoop(_reachabilityRef, CFRunLoopGetMain(), kCFRunLoopDefaultMode)) {
        retVal = YES;
    }

    return retVal;
}

- (void)cancel {
    if (_reachabilityRef != NULL) {
        SCNetworkReachabilityUnscheduleFromRunLoop(_reachabilityRef, CFRunLoopGetMain(), kCFRunLoopDefaultMode);
    }
}

- (void)dealloc {
    [self cancel];

    if (_reachabilityRef != NULL) {
        CFRelease(_reachabilityRef);
    }
}

+ (Reachability *)reachabilityWithHostname:(NSString *)hostname {
    Reachability *retVal = NULL;
    SCNetworkReachabilityRef reachability = SCNetworkReachabilityCreateWithName(NULL, [hostname UTF8String]);

    if (reachability != NULL) {
        retVal = [[self alloc] init];

        if (retVal != NULL) {
            retVal->_reachabilityRef = reachability;
        }
        else {
            CFRelease(reachability);
        }
    }

    return retVal;
}

#pragma mark Network Flag Handling

- (NetworkStatus)localWiFiStatusForFlags:(SCNetworkReachabilityFlags)flags {
    printReachabilityFlags(flags, "localWiFiStatusForFlags");

    BOOL retVal = NetworkStatusNotReachable;

    if ((flags & kSCNetworkReachabilityFlagsReachable) && (flags & kSCNetworkReachabilityFlagsIsDirect)) {
        retVal = NetworkStatusReachableViaWiFi;
    }

    return retVal;
}

- (NetworkStatus)networkStatusForFlags:(SCNetworkReachabilityFlags)flags {
    printReachabilityFlags(flags, "networkStatusForFlags");

    if ((flags & kSCNetworkReachabilityFlagsReachable) == 0) {
        // if target host is not reachable
        return NetworkStatusNotReachable;
    }

    NetworkStatus retVal = NetworkStatusNotReachable;

    if ((flags & kSCNetworkReachabilityFlagsConnectionRequired) == 0) {
        // if target host is reachable and no connection is required
        //  then we'll assume (for now) that your on Wi-Fi
        retVal = NetworkStatusReachableViaWiFi;
    }


    if ((((flags & kSCNetworkReachabilityFlagsConnectionOnDemand ) != 0) ||
         (flags & kSCNetworkReachabilityFlagsConnectionOnTraffic) != 0)) {
        // ... and the connection is on-demand (or on-traffic) if the
        //     calling application is using the CFSocketStream or higher APIs

        if ((flags & kSCNetworkReachabilityFlagsInterventionRequired) == 0) {
            // ... and no [user] intervention is needed
            retVal = NetworkStatusReachableViaWiFi;
        }
    }

    #if TARGET_OS_IPHONE
    if ((flags & kSCNetworkReachabilityFlagsIsWWAN) == kSCNetworkReachabilityFlagsIsWWAN) {
        // ... but WWAN connections are OK if the calling application
        //     is using the CFNetwork (CFSocketStream?) APIs.
        retVal = NetworkStatusReachableViaWWAN;
    }
    #endif

    return retVal;
}

- (NetworkStatus)currentStatus {
    NSAssert(_reachabilityRef != NULL, @"currentNetworkStatus called with NULL reachabilityRef");

    NetworkStatus retVal = NetworkStatusNotReachable;
    SCNetworkReachabilityFlags flags;

    if (SCNetworkReachabilityGetFlags(_reachabilityRef, &flags)) {
        retVal = [self networkStatusForFlags:flags];
    }

    return retVal;
}

- (BOOL)connectionRequired {
    NSAssert(_reachabilityRef != NULL, @"connectionRequired called with NULL reachabilityRef");

    SCNetworkReachabilityFlags flags;

    if (SCNetworkReachabilityGetFlags(_reachabilityRef, &flags)) {
        return (flags & kSCNetworkReachabilityFlagsConnectionRequired);
    }

    return NO;
}

@end

#else

@implementation Reachability

+ (Reachability*)reachabilityWithHostname:(NSString *)hostname {
    return NULL;
}

- (BOOL)start {
    return  NO;
}

- (void)cancel {}

@end

#endif
