/*
 CHDataStructures.framework -- CHLockable.m
 
 Copyright (c) 2009, Quinn Taylor <http://homepage.mac.com/quinntaylor>
 
 Permission to use, copy, modify, and/or distribute this software for any purpose with or without fee is hereby granted, provided that the above copyright notice and this permission notice appear in all copies.
 
 The software is  provided "as is", without warranty of any kind, including all implied warranties of merchantability and fitness. In no event shall the authors or copyright holders be liable for any claim, damages, or other liability, whether in an action of contract, tort, or otherwise, arising from, out of, or in connection with the software or the use or other dealings in the software.
 */

#import "CHLockable.h"

BOOL kCHGarbageCollectionNotEnabled = YES; // A variable declared extern in Util.h
static BOOL initialized = NO;

@implementation CHLockable

+ (void) initialize {
	if (!initialized) {
		// Discover whether garbage collection is enabled (if running on 10.5).
		// This bit of hackery avoids linking errors via indirect invocation.
		// The check is done here since all our collections extend CHLockable.
		Class gcClass = NSClassFromString(@"NSGarbageCollector");
		if (gcClass != nil) {
			id collector = objc_msgSend(gcClass, @selector(defaultCollector));
			kCHGarbageCollectionNotEnabled = (collector == nil);
		}
		initialized = YES;
	}
}

- (void) dealloc {
	[lock release];
	[super dealloc];
}

// No need for an -init method, since the lock is created lazily (on demand)

// Private method used for creating a lock on-demand and naming it uniquely.
- (void) createLock {
	lock = [[NSLock alloc] init];
#if MAC_OS_X_VERSION_10_5_AND_LATER
	[lock setName:[NSString stringWithFormat:@"NSLock-%@-0x%x", [self class], self]];
#endif
}

#pragma mark -

- (BOOL) tryLock {
	if (lock == nil)
		[self createLock];
	return [lock tryLock];
}

- (void) lock {
	if (lock == nil)
		[self createLock];
	[lock lock];
}

- (BOOL) lockBeforeDate:(NSDate*)limit {
	if (lock == nil)
		[self createLock];
	return [lock lockBeforeDate:limit];
}

- (void) unlock {
	[lock unlock];
}

@end
