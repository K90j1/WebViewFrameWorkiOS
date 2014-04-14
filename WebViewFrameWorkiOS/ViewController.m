//
//  ViewController.m
//  WebViewFrameWorkiOS
//
//  Created by bookair on 1/31/14.
//  Copyright (c) 2014 routeFlags,inc. All rights reserved.
//
#import <StoreKit/StoreKit.h>
#import "ViewController.h"

NSString *const DEFAULTS_KEY = @"sample001";
NSString *const UUID_KEY = @"UUID";

@implementation ViewController{
    NSString *targetUrl;
    NSMutableArray *productIds;
}

@synthesize webView = _webView;

- (id) init {
    self = [super init];
    if (self) {
        NSDictionary *temp = [self getDataEnvironment];
        self.targetUrl = [temp objectForKey:@"TargetUrl"];
        self.productIds = [NSMutableArray arrayWithArray:[temp objectForKey:@"ProductIds"]];
    }
    return self;
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
	NSURL *url = [NSURL URLWithString: self.targetUrl];
	NSMutableURLRequest *mutableURLRequest = [[NSMutableURLRequest alloc]initWithURL: url];
//	[mutableURLRequest setHTTPMethod: @"POST"];
//    [mutableURLRequest setHTTPMethod: @"GET"];
//	NSString *string = [NSString stringWithFormat: @"q=%@", @"Objective-C"];
//	[mutableURLRequest setHTTPBody: [string dataUsingEncoding: NSUTF8StringEncoding]];
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

- (void)webViewDidFinishLoad:(UIWebView *)webViewArg {
//    NSString *body = [self.webViewArg stringByEvaluatingJavaScriptFromString:@"document.body.innerHTML"];
//    NSLog(@"innerHTML=%@", body);
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	// Return YES for supported orientations
	return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}


- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions {
    for (SKPaymentTransaction *transaction in transactions) {
        switch (transaction.transactionState) {
            case SKPaymentTransactionStatePurchased:
                NSLog(@"SKPaymentTransactionStatePurchased");
                [self storeItemStatusUserDefaults:@"buy"];
                [self completeTransaction:transaction];
                break;
            case SKPaymentTransactionStateFailed:
                NSLog(@"SKPaymentTransactionStateFailed");
                if (transaction.error.code != SKErrorPaymentCancelled) {
                    NSLog(@"An Error Encoutered %@", transaction.error.description );
                }
//                [self failedTransaction:transaction];
                break;
            case SKPaymentTransactionStateRestored:
                NSLog(@"SKPaymentTransactionStateRestored");

//                [self restoreTransaction:transaction];
            default:
                break;
        }
    }
}

//SKProductsRequestDelegate protocol method
- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response {
//	self.products = response.products;
    NSLog(@"products = %@", response.products);
    for (SKProduct *product in response.products) {
        NSLog(@"valid product identifier: %@", product.productIdentifier);
        SKPayment *payment = [SKPayment paymentWithProduct:product];
        [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
        [[SKPaymentQueue defaultQueue] addPayment:payment];
    }

    for (NSString *invalidIdentifier in response.invalidProductIdentifiers) {
        NSLog(@"invalidIdentifier = %@", invalidIdentifier);
        // Handle any invalid product identifiers.
    }
//	[self displayStoreUI]; // Custom method
}

// カスタムメソット
- (void)validateProductIdentifiers:(NSArray *)productIdentifiers {
    SKProductsRequest *productsRequest = [[SKProductsRequest alloc]
            initWithProductIdentifiers:[NSSet setWithArray:productIdentifiers]];
    productsRequest.delegate = self;
    [productsRequest start];
}


- (void)fetchProductIdentifiersFromURL {
    NSURL *productUrl = [[NSBundle mainBundle] URLForResource:@"DataEnvironment"
                                                withExtension:@"plist"];
    NSArray *productIdentifiers = [NSArray arrayWithContentsOfURL:productUrl];
    if (!productIdentifiers) {
        /* エラーを処理する */
    }
    NSLog(@"productIdentifiers = %@", productIdentifiers);
    dispatch_queue_t main_queue = dispatch_get_main_queue();
    dispatch_async(main_queue, ^{
        [self validateProductIdentifiers:productIdentifiers];
    });
}

- (void)storeItemStatusUserDefaults:(NSString *)status{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if(status == @"buy"){
        [userDefaults setBool:YES forKey:DEFAULTS_KEY];
        [userDefaults synchronize];
        return;
    }
    [userDefaults setBool:NO forKey:DEFAULTS_KEY];
    [userDefaults synchronize];
    return;
}

- (void)completeTransaction:(SKPaymentTransaction *)transaction{
    SKPaymentQueue *skPaymentQueue = [SKPaymentQueue defaultQueue];
    [skPaymentQueue finishTransaction:transaction];
}

-(NSDictionary *)getDataEnvironment {
    NSString *errorDesc = nil;
    NSPropertyListFormat format;
    NSString *plistPath;
    NSString *rootPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
            NSUserDomainMask, YES) objectAtIndex:0];
    plistPath = [rootPath stringByAppendingPathComponent:@"DataEnvironment.plist"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:plistPath]) {
        plistPath = [[NSBundle mainBundle] pathForResource:@"DataEnvironment" ofType:@"plist"];
    }
    NSData *plistXML = [[NSFileManager defaultManager] contentsAtPath:plistPath];
    NSDictionary *temp = (NSDictionary *)[NSPropertyListSerialization
            propertyListFromData:plistXML
                mutabilityOption:NSPropertyListMutableContainersAndLeaves
                          format:&format
                errorDescription:&errorDesc];
    if (!temp) {
        NSLog(@"Error reading plist: %@, format: %d", errorDesc, format);
    }
    return temp;
}
@end
