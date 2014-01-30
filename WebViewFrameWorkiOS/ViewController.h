//
//  ViewController.h
//  WebViewFrameWorkiOS
//
//  Created by bookair on 1/31/14.
//  Copyright (c) 2014 routeFlags,inc. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString *const FIRST_URL;
extern NSString *const UUID_KEY;

// Using UIWebViewDelegate Protocol
@interface ViewController : UIViewController <UIWebViewDelegate>
@property(strong, nonatomic) UIWebView *webView;

- (NSString *)getUUIDUserDefaults;

- (void)storeUUIDKeychain:(NSString *)storeId;

- (void)storeUUIDUserDefaults:(NSString *)storeId;

- (NSString *)createUUID;

- (NSString *)getUUID;

@end
