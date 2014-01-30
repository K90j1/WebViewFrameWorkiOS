//
//  ViewController.m
//  WebViewFrameWorkiOS
//
//  Created by bookair on 1/31/14.
//  Copyright (c) 2014 routeFlags,inc. All rights reserved.
//

#import "ViewController.h"

NSString *const FIRST_URL = @"https://www.google.com/search";
NSString *const UUID_KEY = @"UUID";

@implementation ViewController

@synthesize webView = _webView;

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle
// Implement viewDidLoad to do additional setup after loading the view.
- (void)viewDidLoad {
	[super viewDidLoad];
	// Set WebView Environment
	CGRect rect = self.view.bounds;
	self.webView = [[UIWebView alloc] initWithFrame:rect];
	self.webView.delegate = self;
	[self.view addSubview:self.webView];

//    NSLog(@"UUID=%@", [self getUUID]);
	// Set Up Request URL
	NSURL *url = [NSURL URLWithString: FIRST_URL];
	NSMutableURLRequest *mutableURLRequest = [[NSMutableURLRequest alloc]initWithURL: url];
	[mutableURLRequest setHTTPMethod: @"POST"];
	NSString *string = [NSString stringWithFormat: @"q=%@", @"Objective-C"];
	[mutableURLRequest setHTTPBody: [string dataUsingEncoding: NSUTF8StringEncoding]];
	[self.webView loadRequest: mutableURLRequest];
}

- (BOOL)webView:(UIWebView *)webViewArg shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
	NSString *url = [[[request URL] standardizedURL] absoluteString];
	NSLog(@"url=%@", url);
//	if ([url isEqualToString:FIRST_URL]) {
//		[self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:FIRST_URL]]];
//	}
	return YES;
}

- (NSString *)getUUIDKeychain {
	// Set Up Query
	NSMutableDictionary *query = [NSMutableDictionary dictionary];
	[query setObject:(__bridge id)kSecClassKey forKey:(__bridge id)kSecClass];
	[query setObject:[NSNumber numberWithBool:YES] forKey:(__bridge id)kSecReturnData];
	[query setObject:(id)UUID_KEY forKey:(__bridge id)kSecAttrApplicationTag];
	CFTypeRef persistKey;
	OSStatus osStatus = SecItemCopyMatching((__bridge CFDictionaryRef) query, &persistKey);
	if (osStatus != noErr) {
		NSLog(@"ERROR getUUIDKeychain result = %ld query = %@", osStatus, query);
		return nil;
	}
	NSData *passwordData = (__bridge_transfer NSData *) persistKey;
	return [[NSString alloc] initWithBytes:[passwordData bytes]
									length:[passwordData length] encoding:NSUTF8StringEncoding];
}

- (void)storeUUIDKeychain:(NSString *)storeId {
	// Set Up Query
	NSMutableDictionary *query = [NSMutableDictionary dictionary];
	// atag
	[query setObject:(id)UUID_KEY forKey:(__bridge id)kSecAttrApplicationTag];
	// class
	[query setObject:(__bridge id)kSecClassKey forKey:(__bridge id)kSecClass];
	// pdmn
	[query setObject:(__bridge id)kSecAttrAccessibleWhenUnlocked forKey:(__bridge id)kSecAttrAccessible];
	// r_Data
	[query setObject:[NSNumber numberWithBool:YES] forKey:(__bridge id)kSecReturnData];
	// removing item if it exists
	SecItemDelete((__bridge CFDictionaryRef)query);
	// v_Data
	[query setObject:(id)[storeId dataUsingEncoding:NSUTF8StringEncoding] forKey:(__bridge id)kSecValueData];
	CFTypeRef persistKey;
	OSStatus osStatus = SecItemAdd((__bridge CFDictionaryRef)query, &persistKey);
	if(osStatus) {
		NSLog(@"ERROR storeUUIDKeychain result = %ld query = %@", osStatus, query);
	}
}

- (void)storeUUIDUserDefaults:(NSString *)storeId {
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	[userDefaults setObject:storeId forKey:UUID_KEY];
	[userDefaults synchronize];
}

- (NSString *)getUUIDUserDefaults {
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	NSString *uuidString = [userDefaults stringForKey:UUID_KEY];
	return uuidString;
}

- (NSString *)createUUID {
	CFUUIDRef uuidRef = CFUUIDCreate(kCFAllocatorDefault);
	NSString *uuidString = (__bridge_transfer NSString *) CFUUIDCreateString(kCFAllocatorDefault, uuidRef);
	CFRelease(uuidRef);
	return uuidString;
}

- (NSString *)getUUID {
	// Looking for UUID on UserDefault
	NSString *uuidString = [self getUUIDUserDefaults];
	if ([uuidString length] > 0) {
		NSLog(@"Found %@ on UserDefaults", uuidString);
		return uuidString;
	}
	// Looking for UUID on Keychain
	uuidString = [self getUUIDKeychain];
	if ([uuidString length] > 0) {
		NSLog(@"Found %@ on Keychain", uuidString);
		return uuidString;
	}
	// Create to Set new UUID
	uuidString = [self createUUID];
	[self storeUUIDKeychain:uuidString];
	[self storeUUIDUserDefaults:uuidString];
	return uuidString;
}

- (void)webViewDidFinishLoad:(UIWebView *)webViewArg {
//    NSString *body = [self.webViewArg stringByEvaluatingJavaScriptFromString:@"document.body.innerHTML"];
//    NSLog(@"innerHTML=%@", body);
}


- (void)viewDidUnload {
	[super viewDidUnload];
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	// Return YES for supported orientations
	return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

@end
