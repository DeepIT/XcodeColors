//
//  XcodeColors.h
//  XcodeColors
//
//  Created by Uncle MiF on 9/13/10.
//  Copyright 2010 Deep IT. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface XcodeColors_NSTextStorage : NSTextStorage

- (void)fixAttributesInRange:(NSRange)aRange;

@end

@interface XcodeColors : NSObject

+ (void)pluginDidLoad:(id)xcodeDirectCompatibility;
- (void)registerLaunchSystemDescriptions;

@end
