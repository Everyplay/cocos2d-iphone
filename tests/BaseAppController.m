//
//  AppController.m
//  cocos2d-ios
//
//  Created by Ricardo Quesada on 12/17/11.
//  Copyright (c) 2011 Sapus Media. All rights reserved.
//

#import "BaseAppController.h"

// CLASS IMPLEMENTATIONS
#ifdef __CC_PLATFORM_IOS

#import <UIKit/UIKit.h>

#import "cocos2d.h"
@implementation BaseAppController

@synthesize window=window_, navController=navController_, director=director_;

-(id) init
{
	if( (self=[super init]) ) {
		useRetinaDisplay_ = YES;
	}
	
	return self;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	// Main Window
	window_ = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	
	// Director
	director_ = (CCDirectorIOS*)[CCDirector sharedDirector];
	[director_ setDisplayStats:NO];
	[director_ setAnimationInterval:1.0/60];
	
	// GL View
	CCGLView *__glView = [CCGLView viewWithFrame:[window_ bounds]
									 pixelFormat:kEAGLColorFormatRGB565
									 depthFormat:0 /* GL_DEPTH_COMPONENT24_OES */
							  preserveBackbuffer:NO
									  sharegroup:nil
								   multiSampling:NO
								 numberOfSamples:0
						  ];
	
	[director_ setView:__glView];
	[director_ setDelegate:self];
	director_.wantsFullScreenLayout = YES;

	// Retina Display ?
	[director_ enableRetinaDisplay:useRetinaDisplay_];
	
	// Navigation Controller
	navController_ = [[UINavigationController alloc] initWithRootViewController:director_];
	navController_.navigationBarHidden = YES;

	// AddSubView doesn't work on iOS6
//	[window_ addSubview:navController_.view];
	[window_ setRootViewController:navController_];

	[window_ makeKeyAndVisible];

	// Initialize Everyplay SDK with our client id and secret.
	// These can be created at https://developers.everyplay.com
	[Everyplay setClientId:@"b459897317dc88c80b4515e380e1378022f874d2" clientSecret:@"f1a162969efb1c27aac6977f35b34127e68ee163" redirectURI:@"https://m.everyplay.com/auth"];

	// Register class responsible for EveryplayDelegate and
	// view controller used
	[Everyplay initWithDelegate:self andParentViewController:[CCDirector sharedDirector]];

	// For quick testing, let's auto-record for a few seconds
	//
	// When integrating against your game, call startRecording and stopRecording
	// methods from [[Everyplay sharedInstance] capture] instead
	[[[Everyplay sharedInstance] capture] autoRecordForSeconds:10 withDelay:2];

	return YES;
}

- (void)everyplayShown {
	NSLog(@"everyplayShown");
	[[CCDirector sharedDirector] pause];
}

- (void)everyplayHidden {
	NSLog(@"everyplayHidden");
	[[CCDirector sharedDirector] resume];
}

- (void)everyplayRecordingStopped {
	NSLog(@"everyplayRecordingStopped");

	// Set metadata for the ongoing or last active recording
	[[Everyplay sharedInstance] mergeSessionDeveloperData:@{@"score" : @42, @"level_name" : @"cocos2d-iphone 2.x"}];
	// Bring up Everyplay video player
	[[Everyplay sharedInstance] playLastRecording];
}

// getting a call, pause the game
-(void) applicationWillResignActive:(UIApplication *)application
{
	if( [navController_ visibleViewController] == director_ )
		[director_ pause];
}

// call got rejected
-(void) applicationDidBecomeActive:(UIApplication *)application
{
	if( [navController_ visibleViewController] == director_ )
		[director_ resume];
}

-(void) applicationDidEnterBackground:(UIApplication*)application
{
	if( [navController_ visibleViewController] == director_ )
		[director_ stopAnimation];
}

-(void) applicationWillEnterForeground:(UIApplication*)application
{
	if( [navController_ visibleViewController] == director_ )
		[director_ startAnimation];
}

// application will be killed
- (void)applicationWillTerminate:(UIApplication *)application
{
	CC_DIRECTOR_END();
}

// purge memory
- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application
{
	[director_ purgeCachedData];
}

// next delta time will be zero
-(void) applicationSignificantTimeChange:(UIApplication *)application
{
	[director_ setNextDeltaTimeZero:YES];
}

- (void) dealloc
{
	[window_ release];
	[navController_ release];

	[super dealloc];
}
@end

#elif defined(__CC_PLATFORM_MAC)

@implementation BaseAppController

@synthesize window=window_, glView=glView_, director = director_;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	director_ = (CCDirectorMac*) [CCDirector sharedDirector];

	[director_ setDisplayStats:YES];

	[director_ setView:glView_];

	// Center window
	[self.window center];																		\
	
//	[director setProjection:kCCDirectorProjection2D];

	// Enable "moving" mouse event. Default no.
	[window_ setAcceptsMouseMovedEvents:NO];

	// EXPERIMENTAL stuff.
	// 'Effects' don't work correctly when autoscale is turned on.
	[director_ setResizeMode:kCCDirectorResize_NoScale]; // kCCDirectorResize_AutoScale
}

- (BOOL) applicationShouldTerminateAfterLastWindowClosed: (NSApplication *) theApplication
{
	return YES;
}

- (IBAction)toggleFullScreen: (id)sender
{
	CCDirectorMac *director = (CCDirectorMac*) [CCDirector sharedDirector];
	[director setFullScreen: ! [director isFullScreen] ];
}

@end

#endif // __CC_PLATFORM_MAC


