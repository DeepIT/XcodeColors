//
//  XcodeColors.m
//  XcodeColors
//
//  Created by Uncle MiF on 9/13/10.
//  Copyright 2010 Deep IT. All rights reserved.
//

#import "XcodeColors.h"
#import "MethodReplace.h"

#define XCODE_COLORS "XcodeColors"

#define LC_SEQ_MAC @"\033["
#define LC_SEQ_IOS @"\xC2\xA0["

BOOL isLogTextView(NSTextView* textView)
{
	if (!textView)
		return NO;
	NSString * textViewClass = NSStringFromClass([textView class]);
	// Xcode Debuger View
	if ([textViewClass isEqualToString:@"IDEConsoleTextView"]/* Xcode 4 */ || 
					[textViewClass isEqualToString:@"PBXTtyText"]/* Xcode 3 */)
		return YES;	
	return NO;
}

BOOL isLogTextStorage(NSAttributedString * textStorage)
{
	id textView = nil;
	if ([textStorage respondsToSelector:@selector(layoutManagers)])
	{
		id layoutManagers = [(NSTextStorage*)textStorage layoutManagers];
		if ([layoutManagers count])
		{
			id layoutManager = [layoutManagers objectAtIndex:0];
			if ([layoutManager respondsToSelector:@selector(firstTextView)])
				textView = [layoutManager firstTextView];
		}
	}
	
	return isLogTextView(textView);
}

static IMP imp_ts_fixAttributesInRange = nil;

@interface XcodeColors_NSTextStorage : NSTextStorage

-(void)fixAttributesInRange:(NSRange)aRange;

@end

@implementation XcodeColors_NSTextStorage

NSString* SeqReplacementWithLenght(NSUInteger length)
{
	if (!length)
		return @"";
	NSMutableString * res = [NSMutableString string];
	while(length--)
		[res appendString:@"\x1D"];// Logical Group Separator
	return res;
}

void ApplyANSIColors(NSTextStorage * textStorage, NSRange range, NSString * seq)
{
	NSString * affectedString = [[textStorage string] substringWithRange:range];
	if ([affectedString rangeOfString:seq].location != NSNotFound)
	{
		NSArray * components = [affectedString componentsSeparatedByString:seq];
		NSRange componentRange = range;
		componentRange.length = 0;
		BOOL firstPass = YES;
		NSMutableArray * clearSEQ = [NSMutableArray array];
		NSMutableDictionary * attrs = [NSMutableDictionary dictionary];
		for (NSString * component in components)
		{
			if (!firstPass)
			{
				NSString * realString = component;
				static NSString * ctrlSEQ[] = { 
					// Foreground LCL_*
					@"0;30m"/*black*/,@"0;31m"/*red*/,@"0;32m"/*green*/,@"0;33m"/*yellow*/,@"0;34m"/*blue*/,@"0;35m"/*magenta*/,@"0;36m"/*cyan*/,@"0;37m"/*white*/,
					
					// Background LBCL_*
					@"0;40m"/*black*/,@"0;41m"/*red*/,@"0;42m"/*green*/,@"0;43m"/*yellow*/,@"0;44m"/*blue*/,@"0;45m"/*magenta*/,@"0;46m"/*cyan*/,@"0;47m"/*white*/,

					@"0m"/*nothing*/,@"00m"/*nothing*/};
				int i;
				for (i = 0; i < sizeof(ctrlSEQ)/sizeof(ctrlSEQ[0]); i++)
				{
					if ([component rangeOfString:ctrlSEQ[i]].location != NSNotFound)
					{
						switch(i)
						{
							case 0:
								[attrs setObject:[XcodeColors blackColor] forKey:NSForegroundColorAttributeName];
								break;
							case 1:
								[attrs setObject:[XcodeColors redColor] forKey:NSForegroundColorAttributeName];
								break;
							case 2:
								[attrs setObject:[XcodeColors greenColor] forKey:NSForegroundColorAttributeName];
								break;
							case 3:
								[attrs setObject:[XcodeColors yellowColor] forKey:NSForegroundColorAttributeName];
								break;
							case 4:
								[attrs setObject:[XcodeColors blueColor] forKey:NSForegroundColorAttributeName];
								break;
							case 5:
								[attrs setObject:[XcodeColors magentaColor] forKey:NSForegroundColorAttributeName];
								break;
							case 6:
								[attrs setObject:[XcodeColors cyanColor] forKey:NSForegroundColorAttributeName];
								break;
							case 7:
								[attrs setObject:[XcodeColors whiteColor] forKey:NSForegroundColorAttributeName];
								break;
								
							case 8:
								[attrs setObject:[XcodeColors blackBackgroundColor] forKey:NSBackgroundColorAttributeName];
								break;
							case 9:
								[attrs setObject:[XcodeColors redBackgroundColor] forKey:NSBackgroundColorAttributeName];
								break;
							case 10:
								[attrs setObject:[XcodeColors greenBackgroundColor] forKey:NSBackgroundColorAttributeName];
								break;
							case 11:
								[attrs setObject:[XcodeColors yellowBackgroundColor] forKey:NSBackgroundColorAttributeName];
								break;
							case 12:
								[attrs setObject:[XcodeColors blueBackgroundColor] forKey:NSBackgroundColorAttributeName];
								break;
							case 13:
								[attrs setObject:[XcodeColors magentaBackgroundColor] forKey:NSBackgroundColorAttributeName];
								break;
							case 14:
								[attrs setObject:[XcodeColors cyanBackgroundColor] forKey:NSBackgroundColorAttributeName];
								break;
							case 15:
								[attrs setObject:[XcodeColors whiteBackgroundColor] forKey:NSBackgroundColorAttributeName];
								break;
								
							default:
								[attrs removeObjectForKey:NSForegroundColorAttributeName];
								[attrs removeObjectForKey:NSBackgroundColorAttributeName];
						}
						realString = [component substringFromIndex:[ctrlSEQ[i] length]];
						[clearSEQ addObject:[NSValue valueWithRange:NSMakeRange(componentRange.location - [seq length],[ctrlSEQ[i] length] + [seq length])]];
						break;
					}
				}
			}
			componentRange.length = [component length];
			[textStorage addAttributes:attrs range:componentRange];
			componentRange.location += componentRange.length + [seq length];
			firstPass = NO;
		}
		
		for (NSValue * clearValue in clearSEQ)
		{
			NSRange range = [clearValue rangeValue];
			[textStorage replaceCharactersInRange:range withString:SeqReplacementWithLenght(range.length)];
		}
	}
}

-(void)fixAttributesInRange:(NSRange)aRange// NSTextStorage
{	
	imp_ts_fixAttributesInRange(self,_cmd,aRange);

	if (getenv(XCODE_COLORS) && !strcmp(getenv(XCODE_COLORS),"YES") && isLogTextStorage(self))
	{
		ApplyANSIColors(self,aRange,LC_SEQ_MAC);
		ApplyANSIColors(self,aRange,LC_SEQ_IOS);
	}
}

@end

@implementation XcodeColors

+(void)pluginDidLoad:(id)xcodeDirectCompatibility
{
	/* nothing */
	NSLog(@"%s",__PRETTY_FUNCTION__);
}

-(void)registerLaunchSystemDescriptions
{
	/* nothing */
	NSLog(@"%s",__PRETTY_FUNCTION__);
}

+(void)load
{
	NSLog(@"%s,v,8",__PRETTY_FUNCTION__);
	if (getenv(XCODE_COLORS) && !strcmp(getenv(XCODE_COLORS), "YES"))
		return;

	imp_ts_fixAttributesInRange = ReplaceInstanceMethod(NSTextStorage,fixAttributesInRange:,XcodeColors_NSTextStorage);
	
	setenv(XCODE_COLORS, "YES", 0);
}

+(NSString*)defaultColorKeyByName:(NSString*)colorName
{
	return [NSString stringWithFormat:@"ColorLog_%@",colorName];
}

+(NSColor*)defaultColorWithName:(NSString*)colorName defaultColor:(NSColor*)color
{
	NSUserDefaults * pref = [NSUserDefaults standardUserDefaults];
	id defColor = [pref objectForKey:[self defaultColorKeyByName:colorName]];
	if (!defColor)
	{
		if (!color)
			return nil;
		[pref setObject:[NSArchiver archivedDataWithRootObject:color] forKey:[self defaultColorKeyByName:colorName]];
		return color;
	}
	if ([defColor isKindOfClass:[NSData class]])
		defColor = [NSUnarchiver unarchiveObjectWithData:defColor];
	if ([defColor isKindOfClass:[NSColor class]])
		return defColor;
	if ([defColor isKindOfClass:[NSString class]])
	{
		NSArray * components = [defColor componentsSeparatedByString:@","];
		if ([components count] == 4)
		{   
			return [NSColor 
					colorWithDeviceRed:[[components objectAtIndex:0] floatValue]
					green:[[components objectAtIndex:1] floatValue]
					blue:[[components objectAtIndex:2] floatValue]
					alpha:[[components objectAtIndex:3] floatValue]];
		}
		if ([components count] == 1)
		{
			SEL sel = NSSelectorFromString(defColor);
			if (sel && [NSColor respondsToSelector:sel])
				return [NSColor performSelector:sel];
		}
	}
	return color;
}

// Foreground

+(NSColor*)blackColor
{
	return [self defaultColorWithName:@"blackColor" defaultColor:[NSColor blackColor]];
}

+(NSColor*)redColor
{
	return [self defaultColorWithName:@"redColor" defaultColor:
									[NSColor colorWithCalibratedRed:0x89/255.0 green:0x2A/255.0 blue:0x27/255.0 alpha:0xFF/255.0]/* 892A27 */
									];
}

+(NSColor*)greenColor
{
	return [self defaultColorWithName:@"greenColor" defaultColor:
									[NSColor colorWithCalibratedRed:0x1A/255.0 green:0x89/255.0 blue:0x3B/255.0 alpha:0xFF/255.0]/* 1A893B */
									];
}

+(NSColor*)yellowColor
{
	return [self defaultColorWithName:@"yellowColor" defaultColor:
									[NSColor colorWithCalibratedRed:0xD8/255.0 green:0xD2/255.0 blue:0x53/255.0 alpha:0xFF/255.0]/* D8D253 */
									];
}

+(NSColor*)blueColor
{
	return [self defaultColorWithName:@"blueColor" defaultColor:
									[NSColor colorWithCalibratedRed:0x41/255.0 green:0x87/255.0 blue:0xD8/255.0 alpha:0xFF/255.0]/* 4187D8 */
									];
}

+(NSColor*)magentaColor
{
	return [self defaultColorWithName:@"magentaColor" defaultColor:
									[NSColor colorWithCalibratedRed:0xC2/255.0 green:0x5E/255.0 blue:0xD8/255.0 alpha:0xFF/255.0]/* C25ED8 */
									];
}

+(NSColor*)cyanColor
{
	return [self defaultColorWithName:@"cyanColor" defaultColor:
									[NSColor colorWithCalibratedRed:0x3F/255.0 green:0xC6/255.0 blue:0xD8/255.0 alpha:0xFF/255.0]/* 3FC6D8 */
									];
}

+(NSColor*)whiteColor
{
	return [self defaultColorWithName:@"whiteColor" defaultColor:
									[NSColor colorWithCalibratedRed:0xCC/255.0 green:0xCB/255.0 blue:0xC9/255.0 alpha:0xFF/255.0]/* CCCBC9 */
									];
}

// Background

+(NSColor*)blackBackgroundColor
{
	return [self defaultColorWithName:@"blackBackgroundColor" defaultColor:[NSColor blackColor]];
}

+(NSColor*)redBackgroundColor
{
	return [self defaultColorWithName:@"redBackgroundColor" defaultColor:
									[NSColor colorWithCalibratedRed:0xCC/255.0 green:0x8B/255.0 blue:0x8D/255.0 alpha:0xFF/255.0]/* CC8B8D */
									];
}

+(NSColor*)greenBackgroundColor
{
	return [self defaultColorWithName:@"greenBackgroundColor" defaultColor:
									[NSColor colorWithCalibratedRed:0xAA/255.0 green:0xCC/255.0 blue:0xAD/255.0 alpha:0xFF/255.0]/* AACCAD */
									];
}

+(NSColor*)yellowBackgroundColor
{
	return [self defaultColorWithName:@"yellowBackgroundColor" defaultColor:
									[NSColor colorWithCalibratedRed:0xCC/255.0 green:0xBC/255.0 blue:0x91/255.0 alpha:0xFF/255.0]/* CCBC91 */
									];
}

+(NSColor*)blueBackgroundColor
{
	return [self defaultColorWithName:@"blueBackgroundColor" defaultColor:
									[NSColor colorWithCalibratedRed:0xA9/255.0 green:0xC0/255.0 blue:0xCC/255.0 alpha:0xFF/255.0]/* A9C0CC */
									];
}

+(NSColor*)magentaBackgroundColor
{
	return [self defaultColorWithName:@"magentaBackgroundColor" defaultColor:
									[NSColor colorWithCalibratedRed:0xCC/255.0 green:0xB1/255.0 blue:0xC0/255.0 alpha:0xFF/255.0]/* CCB1C0 */
									];
}

+(NSColor*)cyanBackgroundColor
{
	return [self defaultColorWithName:@"cyanBackgroundColor" defaultColor:
									[NSColor colorWithCalibratedRed:0xB3/255.0 green:0xCA/255.0 blue:0xCC/255.0 alpha:0xFF/255.0]/* B3CACC */
									];
}

+(NSColor*)whiteBackgroundColor
{
	return [self defaultColorWithName:@"whiteBackgroundColor" defaultColor:[NSColor whiteColor]];
}

@end
