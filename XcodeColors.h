//
//  XcodeColors.h
//  XcodeColors
//
//  Created by Uncle MiF on 9/13/10.
//  Copyright 2010 Deep IT. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface XcodeColors : NSObject

// Foreground

+(NSColor*)blackColor;
+(NSColor*)redColor;
+(NSColor*)greenColor;
+(NSColor*)yellowColor;
+(NSColor*)blueColor;
+(NSColor*)magentaColor;
+(NSColor*)cyanColor;
+(NSColor*)whiteColor;

// Background

+(NSColor*)blackBackgroundColor;
+(NSColor*)redBackgroundColor;
+(NSColor*)greenBackgroundColor;
+(NSColor*)yellowBackgroundColor;
+(NSColor*)blueBackgroundColor;
+(NSColor*)magentaBackgroundColor;
+(NSColor*)cyanBackgroundColor;
+(NSColor*)whiteBackgroundColor;

// Plugin
+(void)pluginDidLoad:(id)xcodeDirectCompatibility;
-(void)registerLaunchSystemDescriptions;

@end
