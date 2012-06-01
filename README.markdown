XcodeColors allows you to use colors in the Xcode debugging console.  
It's designed to aid in the debugging process. For example:
- Make error messages stand out by printing them out in red.
- Use different colors for logically separate parts of your code.

You're not limited to a restricted color palate.  
You can specify, in your source code, the exact RGB values you'd like to use.  
You can specify foreground and/or background color(s).

XcodeColors is a simple plugin for Xcode 3 & 4.  

***

### XcodeColors installation instructions for Xcode 4:

There are 2 ways to accomplish this:

1. **Simple install using precompiled xcode plugin**
    - Download the XcodeColors.xcplugin.zip file from the downloads page  
        https://github.com/robbiehanson/XcodeColors/downloads
    - Unzip the downloaded file, which will give you the "XcodeColors.xcplugin" folder.  
        Note that finder will likely not display the ".xcplugin" extension. This is normal.  
        If you want you can verify the extension is there via Finder's "get info" or via the Terminal.
    - Copy this folder to "~/Library/Application Support/Developer/Shared/Xcode/Plug-ins/XcodeColors.xcplugin"  
        You might need to create the "Plug-ins" folder if it doesn't already exist. If so, double-check your spelling.
    - Quit Xcode (if it's running)
    - Launch Xcode.
    - Want to see it in action?  
        The repository contains an Xcode project with a TestXcodeColors target.  
        You can run this target to see XcodeColors in action.

2. **Compile from source**
    - Download or clone the repository.  
    - Compile the XcodeColors target for Release (not Debug).  
        When you do this, the Xcode plugin is automatically copied to the proper location.  
        This is done via the xcb-install.pl install script that is run as part of an Xcode build phase.  
        Validate the plugin was copied to "~/Library/Application Support/Developer/Shared/Xcode/Plug-ins/XcodeColors.xcplugin"  
    - Quit Xcode (if it's running)
    - Launch Xcode.
    - Now compile and run the TestXcodeColors target (debug or release, doesn't matter).  
        This will test your installation, and you should see colors in your Xcode console.

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
    setenv("XcodeColors", "YES", 0); // Enables XcodeColors (you obviously have to install it too)
    
    setenv("XcodeColors", "NO", 0); // Disables XcodeColors
    ```

- Using XcodeColors

    The following is copied from the top of the XcodeColors.m file:

    ```objective-c
    // How to apply color formatting to your log statements:
    // 
    // To set the foreground color:
    // Insert the ESCAPE into your string, followed by "fg124,12,255;" where r=124, g=12, b=255.
    // 
    // To set the background color:
    // Insert the ESCAPE into your string, followed by "bg12,24,36;" where r=12, g=24, b=36.
    // 
    // To reset the foreground color (to default value):
    // Insert the ESCAPE into your string, followed by "fg;"
    // 
    // To reset the background color (to default value):
    // Insert the ESCAPE into your string, followed by "bg;"
    // 
    // To reset the foreground and background color (to default values) in one operation:
    // Insert the ESCAPE into your string, followed by ";"
    
    #define XCODE_COLORS_ESCAPE_MAC @"\033["
    
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
