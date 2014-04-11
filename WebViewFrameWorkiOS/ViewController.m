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
    NSURL *productUrl = [[NSBundle mainBundle] URLForResource:@"productIds"
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

@end
