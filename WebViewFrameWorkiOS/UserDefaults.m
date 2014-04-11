//
// Created by bookair17 on 4/11/14.
//

#import "UserDefaults.h"
#import "ViewController.h"


@implementation UserDefaults {

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

@end