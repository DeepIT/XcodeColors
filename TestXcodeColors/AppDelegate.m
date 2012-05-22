#import "AppDelegate.h"

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

@implementation AppDelegate

@synthesize window = _window;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	NSLog(@"If you don't see colors below, make sure you follow the installation instructions in the README.");
	
	NSLog(ESCAPE_SEQ @"fg0,0,255;" @"Blue text" SEQ_RESET);
	
	NSLog(ESCAPE_SEQ @"bg220,0,0;" @"Red background" SEQ_RESET);
	
	NSLog(ESCAPE_SEQ @"fg0,0,255;" ESCAPE_SEQ @"bg220,0,0;" @"Blue text on red background" SEQ_RESET);
	
	NSLog(ESCAPE_SEQ @"fg209,57,168;" @"You can supply your own RGB values!" SEQ_RESET);
}

@end
