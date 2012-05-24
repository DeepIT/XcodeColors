XcodeColors is an easy-to-use plugin for Xcode 3 & 4.  
This project is designed to enable colorizing debugger console output.

***

### XcodeColors installation instructions for Xcode 4:

1. Compile the XcodeColors target for Release (not Debug).

    When you do this, the Xcode plugin is automatically copied to the proper location.  
    This is done via the install script, run by xcb-install.pl via an Xcode build phase.

2. Quit Xcode.

3. Add the following code to ~/.gdbinit:

    ```shell
    define xcodecolors
    attach Xcode
    p (char)[[NSBundle bundleWithPath:@"~/Library/Application Support/SIMBL/Plugins/XcodeColors.bundle"] load]
    detach
    end
    ```

    But what about LLDB? Relax, it also works for LLDB.

4.  Launch Xcode

5. Open the Terminal.

    Run gdb (Type gdb then hit enter).  
    You'll get a gdb command prompt.  
    Run xcodecolors (Type xcodecolors then hit enter).  
    It should look something like this in the Terminal:

    ```shell
    ~ $ gdb
    (gdb) xcodecolors
    Attaching to process ...
    Reading symbols for shared libraries ...
    .. done
    0x00007fff84d242fa in mach_msg_trap ()
    $1 = 1 '\001'
    (gdb) quit
    ```

    This step is required only once after Xcode start.

5. You're done!

    Want to see it in action?  
    Run the TestXcodeColors target in this project.


### XcodeColors installation instructions for Xcode 3:

Wow, you're still running Xcode 3?  

See this page for installation instructions:  
http://deepitpro.com/en/articles/XcodeColors/info/index.shtml

***

### How to use XcodeColors

-  Testing to see if XcodeColors is installed and enabled:

    ```objective-c
    char *xcode_colors = getenv(XCODE_COLORS);
    if (xcode_colors && (strcmp(xcode_colors, "YES") == 0))
    {
        // XcodeColors is installed and enabled!
    }
    ```

-  Enabling / Disabling XcodeColors

    ```objective-c
    setenv(XCODE_COLORS, "YES", 0); // Enables XcodeColors (you obviously have to install it too)
    
    setenv(XCODE_COLORS, "NO", 0); // Disables XcodeColors
    ```

- Using XcodeColors

    The following is copied from the top of the XcodeColors.m file:

    ```objective-c
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
    
    #define XCODE_COLORS_ESCAPE_MAC @"\033["
    #define XCODE_COLORS_ESCAPE_IOS @"\xC2\xA0["
    
    #if TARGET_OS_IPHONE
      #define XCODE_COLORS_ESCAPE  XCODE_COLORS_ESCAPE_IOS
    #else
      #define XCODE_COLORS_ESCAPE  XCODE_COLORS_ESCAPE_MAC
    #endif
    
    #define XCODE_COLORS_RESET_FG  XCODE_COLORS_ESCAPE @"fg;" // Clear any foreground color
    #define XCODE_COLORS_RESET_BG  XCODE_COLORS_ESCAPE @"bg;" // Clear any background color
    #define XCODE_COLORS_RESET     XCODE_COLORS_ESCAPE @";"   // Clear any foreground or background color
    ```
    
    Then feel free to colorize your log statements however you see fit!  
    Here's an example to get you started:
    
    ```objective-c
    NSLog(XCODE_COLORS_ESCAPE @"fg0,0,255;" @"Blue text" XCODE_COLORS_RESET);
    
    NSLog(XCODE_COLORS_ESCAPE @"bg220,0,0;" @"Red background" XCODE_COLORS_RESET);
    
    NSLog(XCODE_COLORS_ESCAPE @"fg0,0,255;"
          XCODE_COLORS_ESCAPE @"bg220,0,0;"
          @"Blue text on red background"
          XCODE_COLORS_RESET);
    
    NSLog(XCODE_COLORS_ESCAPE @"fg209,57,168;" @"You can supply your own RGB values!" XCODE_COLORS_RESET);
    ```

***

### CocoaLumberjack

The [CocoaLumberjack](https://github.com/robbiehanson/CocoaLumberjack) framework natively supports XcodeColors!  
Lumberjack is a fast & simple, yet powerful & flexible logging framework for Mac and iOS.

From it's GitHub page:

> [Lumberjack] is similar in concept to other popular logging frameworks such as log4j,
> yet is designed specifically for Objective-C, and takes advantage of features such as
> multi-threading, grand central dispatch (if available), lockless atomic operations,
> and the dynamic nature of the Objective-C runtime.
> 
> In most cases it is an order of magnitude faster than NSLog.

It's super easy to use XcodeColors with Lumberjack!

And if color isn't available (e.g. XcodeColors isn't installed), then the framework just automatically does the right thing. So if you install XcodeColors on your machine, and enable colors in your team project, your teammates (without XcodeColors... yet) won't suffer, or even notice.

Plus Lumberjack colors automatically work if you run your application from within a terminal! (E.g. Terminal.app, not Xcode) If your terminal supports color (xterm-color or xterm-256color) like the Terminal.app in Lion, then Lumberjack automatically maps your color customizations to the closest available color supported by the shell!

```objective-c
// Standard lumberjack initialization
[DDLog addLogger:[DDTTYLogger sharedInstance]];

// And then enable colors
[[DDTTYLogger sharedInstance] setColorsEnabled:YES];

// Check out default colors:
// Error : Red
// Warn  : Orange

DDLogError(@"Paper jam");                              // Red
DDLogWarn(@"Toner is low");                            // Orange
DDLogInfo(@"Warming up printer (pre-customization)");  // Default (black)
DDLogVerbose(@"Intializing protcol x26");              // Default (black)

// Now let's do some customization:
// Info  : Pink

#if TARGET_OS_IPHONE
UIColor *pink = [UIColor colorWithRed:(255/255.0) green:(58/255.0) blue:(159/255.0) alpha:1.0];
#else
NSColor *pink = [NSColor colorWithCalibratedRed:(255/255.0) green:(58/255.0) blue:(159/255.0) alpha:1.0];
#endif

[[DDTTYLogger sharedInstance] setForegroundColor:pink backgroundColor:nil forFlag:LOG_FLAG_INFO];

DDLogInfo(@"Warming up printer (post-customization)"); // Pink !
```
