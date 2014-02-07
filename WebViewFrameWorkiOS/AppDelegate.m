//
//  AppDelegate.m
//  WebViewFrameWorkiOS
//
//  Created by bookair on 1/31/14.
//  Copyright (c) 2014 routeFlags,inc. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewController.h"

NSString *const CREDENTIAL_USER = @"userName";
NSString *const CREDENTIAL_PASS = @"password";
NSString *const PROTECT_HOST = @"google.co.jp";
NSInteger *const PROTECT_PORT = 80;
NSString *const PROTECT_URI = @"http";
NSString *const PROTECT_REALM = @"BASIC AUTHRICATION";

@implementation AppDelegate

@synthesize window = _window;
@synthesize viewController = _viewController;


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // viewController
    self.viewController = [[ViewController alloc] init];
    self.window.rootViewController = self.viewController;
    [self.window makeKeyAndVisible];
	[self configureCredential];
	return YES;
}

// For Basic Auth
- (void)configureCredential {
	NSURLCredential *urlCredential =
			[NSURLCredential credentialWithUser:CREDENTIAL_USER password:CREDENTIAL_PASS persistence:NSURLCredentialPersistenceForSession];
	NSURLCredentialStorage *urlCredentialStorage = [NSURLCredentialStorage sharedCredentialStorage];
	NSURLProtectionSpace *protectionSpace = [[NSURLProtectionSpace alloc] initWithHost:PROTECT_HOST
																				  port:PROTECT_PORT
																			  protocol:PROTECT_URI
																				 realm:PROTECT_REALM
																  authenticationMethod:NSURLAuthenticationMethodDefault];
	[urlCredentialStorage setCredential:urlCredential forProtectionSpace:protectionSpace];
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}


#pragma mark - Core Data stack

#pragma mark - Application's Documents directory

/**
 Returns the URL to the application's Documents directory.
 */
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

@end
