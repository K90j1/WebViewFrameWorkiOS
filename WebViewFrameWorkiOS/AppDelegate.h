//
//  AppDelegate.h
//  WebViewFrameWorkiOS
//
//  Created by bookair on 1/31/14.
//  Copyright (c) 2014 routeFlags,inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Security/Security.h>

extern NSString *const CREDENTIAL_USER;
extern NSString *const CREDENTIAL_PASS;
extern NSString *const PROTECT_HOST;
extern NSString *const PROTECT_REALM;
extern NSInteger *const PROTECT_PORT;
extern NSString *const PROTECT_URI;

@class ViewController;
@interface AppDelegate : UIResponder <UIApplicationDelegate>
@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) ViewController *viewController;

- (void)configureCredential;

@end