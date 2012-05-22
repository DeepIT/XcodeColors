//
//  XcodeColors.m
//  XcodeColors
//
//  Created by Uncle MiF on 9/13/10.
//  Copyright 2010 Deep IT. All rights reserved.
//

#import "XcodeColors.h"
#import <objc/runtime.h>

#define XCODE_COLORS "XcodeColors"

// How to apply color formatting to your log statements:
// 
// To set the foreground color:
// Insert the ESCAPE_SEQ into your string, followed by "fg124,12,255;" where r=124, g=12, b=255.
// 
// To set the background color:
// Insert the ESCAPE_SEQ into your string, followed by "bg12,24,36;" where r=12, g=24, b=36.
// 
// To reset the foreground color (to default value):
// Insert the ESCAPE_SEQ into your string, followed by "fg;"
// 
// To reset the background color (to default value):
// Insert the ESCAPE_SEQ into your string, followed by "bg;"
// 
// To reset the foreground and background color (to default values) in one operation:
// Insert the ESCAPE_SEQ into your string, followed by ";"
// 
// 
// Feel free to copy the define statements below into your code.
// <COPY ME>

#define ESCAPE_SEQ_MAC @"\033["
#define ESCAPE_SEQ_IOS @"\xC2\xA0["

#if TARGET_OS_IPHONE
  #define ESCAPE_SEQ ESCAPE_SEQ_IOS
#else
  #define ESCAPE_SEQ ESCAPE_SEQ_MAC
#endif

#define SEQ_RESET_FG  ESCAPE_SEQ @"fg;" // Clear any foreground color
#define SEQ_RESET_BG  ESCAPE_SEQ @"bg;" // Clear any background color
#define SEQ_RESET     ESCAPE_SEQ @";"   // Clear any foreground or background color

// </COPY ME>

static IMP IMP_NSTextStorage_fixAttributesInRange = nil;



@implementation XcodeColors_NSTextStorage

void ApplyANSIColors(NSTextStorage *textStorage, NSRange textStorageRange, NSString *escapeSeq)
{
	NSRange range = [[textStorage string] rangeOfString:escapeSeq options:0 range:textStorageRange];
	if (range.location == NSNotFound)
	{
		// No escape sequence(s) in the string.
		return;
	}
	
	// Architecture:
	// 
	// We're going to split the string into components separated by the given escape sequence.
	// Then we're going to loop over the components, looking for color codes at the beginning of each component.
	// 
	// For example, if the input string is "Hello__fg124,12,12;World" (with __ representing the escape sequence),
	// then our components would be: (
	//   "Hello"
	//   "fg124,12,12;World"
	// )
	// 
	// We would find a color code (rgb 124, 12, 12) for the foreground color in the second component.
	// At that point, the parsed foreground color goes into an attributes dictionary (attrs),
	// and the foreground color stays in effect (for the current component & future components)
	// until it gets cleared via a different foreground color, or a clear sequence.
	// 
	// The attributes are applied to the entire range of the component, and then we move onto the next component.
	// 
	// At the very end, we go back and apply "invisible" attributes (zero font, and clear text)
	// to the escape and color sequences.
	
	
	NSString *affectedString = [[textStorage string] substringWithRange:textStorageRange];
	
	// Split the string into components separated by the given escape sequence.
	
	NSArray *components = [affectedString componentsSeparatedByString:escapeSeq];
	
	NSRange componentRange = textStorageRange;
	componentRange.length = 0;
	
	BOOL firstPass = YES;
	
	NSMutableArray *seqRanges = [NSMutableArray arrayWithCapacity:[components count]];
	NSMutableDictionary *attrs = [NSMutableDictionary dictionaryWithCapacity:2];
	
	for (NSString *component in components)
	{
		if (firstPass)
		{
			// The first component in the array won't need processing.
			// If there was an escape sequence at the very beginning of the string,
			// then the first component in the array will be an empty string.
			// Otherwise the first component is everything before the first escape sequence.
		}
		else
		{
			// componentSeqRange : Range of escape sequence within component, e.g. "fg124,12,12;"
			
			NSColor *color = nil;
			NSUInteger colorCodeSeqLength = 0;
			
			BOOL stop = NO;
			
			BOOL reset = !stop && (stop = [component hasPrefix:@";"]);
			BOOL fg    = !stop && (stop = [component hasPrefix:@"fg"]);
			BOOL bg    = !stop && (stop = [component hasPrefix:@"bg"]);
			
			BOOL resetFg = fg && [component hasPrefix:@"fg;"];
			BOOL resetBg = bg && [component hasPrefix:@"bg;"];
			
			if (reset)
			{
				// Reset attributes
				[attrs removeObjectForKey:NSForegroundColorAttributeName];
				[attrs removeObjectForKey:NSBackgroundColorAttributeName];
				
				// Mark the range of the sequence (escape sequence + reset color sequence).
				NSRange seqRange = (NSRange){
					.location = componentRange.location - [escapeSeq length],
					.length = 1 + [escapeSeq length],
				};
				[seqRanges addObject:[NSValue valueWithRange:seqRange]];
			}
			else if (resetFg || resetBg)
			{
				// Reset attributes
				if (resetFg)
					[attrs removeObjectForKey:NSForegroundColorAttributeName];
				else
					[attrs removeObjectForKey:NSBackgroundColorAttributeName];
				
				// Mark the range of the sequence (escape sequence + reset color sequence).
				NSRange seqRange = (NSRange){
					.location = componentRange.location - [escapeSeq length],
					.length = 3 + [escapeSeq length],
				};
				[seqRanges addObject:[NSValue valueWithRange:seqRange]];
			}
			else if (fg || bg)
			{
				// Looking for something like this: "fg124,22,12;" or "bg17,24,210;".
				// These are the rgb values for the foreground or background.
				
				NSString *str_r = nil;
				NSString *str_g = nil;
				NSString *str_b = nil;
				
				NSRange range_search = NSMakeRange(2, MIN(4, [component length] - 2));
				NSRange range_separator;
				NSRange range_value;
				
				// Search for red separator
				range_separator = [component rangeOfString:@"," options:0 range:range_search];
				if (range_separator.location != NSNotFound)
				{
					// Extract red substring
					range_value.location = range_search.location;
					range_value.length = range_separator.location - range_search.location;
					
					str_r = [component substringWithRange:range_value];
					
					// Update search range
					range_search.location = range_separator.location + range_separator.length;
					range_search.length = MIN(4, [component length] - range_search.location);
					
					// Search for green separator
					range_separator = [component rangeOfString:@"," options:0 range:range_search];
					if (range_separator.location != NSNotFound)
					{
						// Extract green substring
						range_value.location = range_search.location;
						range_value.length = range_separator.location - range_search.location;
						
						str_g = [component substringWithRange:range_value];
						
						// Update search range
						range_search.location = range_separator.location + range_separator.length;
						range_search.length = MIN(4, [component length] - range_search.location);
						
						// Search for blue separator
						range_separator = [component rangeOfString:@";" options:0 range:range_search];
						if (range_separator.location != NSNotFound)
						{
							// Extract blue substring
							range_value.location = range_search.location;
							range_value.length = range_separator.location - range_search.location;
							
							str_b = [component substringWithRange:range_value];
							
							// Mark the length of the entire color code sequence.
							colorCodeSeqLength = range_separator.location + range_separator.length;
						}
					}
				}
				
				if (str_r && str_g && str_b)
				{
					// Parse rgb values and create color
					
					int r = MAX(0, MIN(255, [str_r intValue]));
					int g = MAX(0, MIN(255, [str_g intValue]));
					int b = MAX(0, MIN(255, [str_b intValue]));
					
					color = [NSColor colorWithCalibratedRed:(r/255.0)
					                                  green:(g/255.0)
					                                   blue:(b/255.0)
					                                  alpha:1.0];
					
					if (fg)
					{
						[attrs setObject:color forKey:NSForegroundColorAttributeName];
					}
					else
					{
						[attrs setObject:color forKey:NSBackgroundColorAttributeName];
					}
					
					//NSString *realString = [component substringFromIndex:colorCodeSeqLength];
					
					// Mark the range of the entire sequence (escape sequence + color code sequence).
					NSRange seqRange = (NSRange){
						.location = componentRange.location - [escapeSeq length],
						.length = colorCodeSeqLength + [escapeSeq length],
					};
					[seqRanges addObject:[NSValue valueWithRange:seqRange]];
				}
				else
				{
					// Wasn't able to parse a color code
					
					[attrs removeObjectForKey:NSForegroundColorAttributeName];
					[attrs removeObjectForKey:NSBackgroundColorAttributeName];
					
					NSRange seqRange = (NSRange){
						.location = componentRange.location - [escapeSeq length],
						.length = [escapeSeq length],
					};
					[seqRanges addObject:[NSValue valueWithRange:seqRange]];
				}
			}
		}
		
		componentRange.length = [component length];
		
		[textStorage addAttributes:attrs range:componentRange];
		
		componentRange.location += componentRange.length + [escapeSeq length];
		firstPass = NO;
		
	} // END: for (NSString *component in components)
	
	
	// Now loop over all the discovered sequences, and apply "invisible" attributes to them.
	
	if ([seqRanges count] > 0)
	{
		NSDictionary *clearAttrs =
		    [NSDictionary dictionaryWithObjectsAndKeys:
		        [NSFont systemFontOfSize:0.001], NSFontAttributeName,
		                   [NSColor clearColor], NSForegroundColorAttributeName, nil];
		
		for (NSValue *seqRangeValue in seqRanges)
		{
			NSRange seqRange = [seqRangeValue rangeValue];
			[textStorage addAttributes:clearAttrs range:seqRange];
		}
	}
}

- (void)fixAttributesInRange:(NSRange)aRange
{
	// This method "overrides" the method within NSTextStorage.
	
	// First we invoke the actual NSTextStorage method.
	// This allows it to do any normal processing.
	
	IMP_NSTextStorage_fixAttributesInRange(self, _cmd, aRange);
	
	// Then we scan for our special escape sequences, and apply desired color attributes.
	
	char *xcode_colors = getenv(XCODE_COLORS);
	if (xcode_colors && (strcmp(xcode_colors, "YES") == 0))
	{
		ApplyANSIColors(self, aRange, ESCAPE_SEQ_MAC);
		ApplyANSIColors(self, aRange, ESCAPE_SEQ_IOS);
	}
}

@end

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

@implementation XcodeColors

IMP ReplaceInstanceMethod(Class sourceClass, SEL sourceSel, Class destinationClass, SEL destinationSel)
{
	if (!sourceSel || !sourceClass || !destinationClass)
	{
		NSLog(@"XcodeColors: Missing parameter to ReplaceInstanceMethod");
		return nil;
	}
	
	if (!destinationSel)
		destinationSel = sourceSel;
	
	Method sourceMethod = class_getInstanceMethod(sourceClass, sourceSel);
	if (!sourceMethod)
	{
		NSLog(@"XcodeColors: Unable to get sourceMethod");
		return nil;
	}
	
	IMP prevImplementation = method_getImplementation(sourceMethod);
	
	Method destinationMethod = class_getInstanceMethod(destinationClass, destinationSel);
	if (!destinationMethod)
	{
		NSLog(@"XcodeColors: Unable to get destinationMethod");
		return nil;
	}
	
	IMP newImplementation = method_getImplementation(destinationMethod);
	if (!newImplementation)
	{
		NSLog(@"XcodeColors: Unable to get newImplementation");
		return nil;
	}
	
	method_setImplementation(sourceMethod, newImplementation);
	
	return prevImplementation;
}

+ (void)load
{
	NSLog(@"XcodeColors: %@ (v10)", NSStringFromSelector(_cmd));
	
	char *xcode_colors = getenv(XCODE_COLORS);
	if (xcode_colors && (strcmp(xcode_colors, "YES") != 0))
		return;
	
	IMP_NSTextStorage_fixAttributesInRange =
	    ReplaceInstanceMethod([NSTextStorage class], @selector(fixAttributesInRange:),
							  [XcodeColors_NSTextStorage class], @selector(fixAttributesInRange:));
	
	setenv(XCODE_COLORS, "YES", 0);
}

+ (void)pluginDidLoad:(id)xcodeDirectCompatibility
{
	NSLog(@"XcodeColors: %@", NSStringFromSelector(_cmd));
}

- (void)registerLaunchSystemDescriptions
{
	NSLog(@"XcodeColors: %@", NSStringFromSelector(_cmd));
}

@end
