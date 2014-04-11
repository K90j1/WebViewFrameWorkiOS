//
// Created by bookair17 on 4/11/14.
//

#import <Foundation/Foundation.h>


@interface UserDefaults : NSObject

- (NSString *)getUUIDKeychain;
- (void)storeUUIDKeychain:(NSString *)storeId;
- (void)storeUUIDUserDefaults:(NSString *)storeId;
- (NSString *)getUUIDUserDefaults;
- (NSString *)createUUID;
- (NSString *)getUUID;

@end