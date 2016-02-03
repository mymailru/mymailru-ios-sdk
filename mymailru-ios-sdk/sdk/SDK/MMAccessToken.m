//
//  MMAccessToken.m
//  mymailru-ios-sdk
//
//  Created by d.taraev on 20.01.16.
//  Copyright © 2016 mail.ru. All rights reserved.
//

#import "MMAccessToken.h"
#import "MMApiConst.h"
#import "MMUtil.h"
#import "MMSdk.h"

static NSString *const ACCESS_TOKEN = @"access_token";
static NSString *const REFRESH_TOKEN = @"refresh_token";
static NSString *const EXPIRES_IN = @"expires_in";
static NSString *const USER_ID = @"x_mailru_vid";
static NSString *const CREATED = @"created";
static NSString *const PERMISSIONS = @"permissions";

@interface MMAccessToken () {
@protected
    NSString *_accessToken;
    NSString *_refreshToken;
    NSString *_userId;
    NSInteger _expiresIn;
    NSTimeInterval _created;
}
@property(nonatomic, readwrite, copy) NSString *accessToken;
@end

@implementation MMAccessToken

+ (instancetype)tokenFromUrlString:(NSString *)urlString {
    return [[self alloc] initWithUrlString:urlString];
}

- (instancetype)initWithMMAccessToken:(MMAccessToken *)token {
    if (self = [super init]) {
        _accessToken = [token.accessToken copy];
        _refreshToken = [token.refreshToken copy];
        _expiresIn = token.expiresIn;
        _userId = [token.userId copy];
        _created = token.created;
    }
    return self;
}

- (instancetype)initWithUrlString:(NSString *)urlString {
    
    self = [super init];
    if (self) {
        
        NSDictionary *parameters = [MMUtil explodeQueryString:urlString];
        _accessToken = [parameters[ACCESS_TOKEN] copy];
        _refreshToken = [parameters[REFRESH_TOKEN] copy];
        _expiresIn = [parameters[EXPIRES_IN] integerValue];
        _userId = [parameters[USER_ID] copy];
        _created = [[NSDate new] timeIntervalSince1970];
//        [self checkIfExpired];
    }
    
    return self;
}

+ (instancetype)savedToken:(NSString *)defaultsKey {
    NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:defaultsKey];
    if (data) {
        MMAccessToken *token = [self tokenFromUrlString:[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:defaultsKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [self save:defaultsKey data:token];
        return token;
    }
    return [self load:defaultsKey];
}

//- (void)updateTokenInformationWithParams:(NSDictionary *)params
//{
//    self.accessToken = params[@"access_token"];
//    self.refreshToken = params[@"refresh_token"];
//    self.userId = params[@"x_mailru_vid"];
//    NSString *expiresIn = params[@"expires_in"];
//    self.expirationDate = [NSDate dateWithTimeIntervalSinceNow:[expiresIn doubleValue]];
//    [self cacheTokenInformation];
//}

//-(void)cacheTokenInformation {
//    NSMutableDictionary *info = [NSMutableDictionary dictionary];
//    info[kMMAccessToken] = self.accessToken ?: @"";
//    info[kMMRefreshToken] = self.refreshToken ?: @"";
//    info[kMMExpirationDate] = self.expirationDate ?: @"";
//    info[kMMUserId] = self.userId ?: @"";
////    [MMRTokenCache cacheTokenInformation:info];
//}

#pragma mark - Expire

- (BOOL)isExpired {
    return self.expiresIn > 0 && self.expiresIn + self.created < [[NSDate new] timeIntervalSince1970];
}

- (void)checkIfExpired {
    if (self.accessToken && self.isExpired) {
        [self notifyTokenExpired];
    }
}

- (void)saveTokenToDefaults:(NSString *)defaultsKey {
    [[self class] save:defaultsKey data:[self copy]];
}

- (id)copy {
    return [[MMAccessToken alloc] initWithMMAccessToken:self];
}

- (id)mutableCopy {
    return [[MMAccessTokenMutable alloc] initWithMMAccessToken:self];
}



/**
 Simple keychain requests
 Source: http://stackoverflow.com/a/5251820/1271424
 */

+ (NSMutableDictionary *)getKeychainQuery:(NSString *)service {
    return [@{(__bridge id) kSecClass : (__bridge id) kSecClassGenericPassword,
              (__bridge id) kSecAttrService : service,
              (__bridge id) kSecAttrAccount : service,
              (__bridge id) kSecAttrAccessible : (__bridge id) kSecAttrAccessibleAfterFirstUnlock} mutableCopy];
}

+ (void)save:(NSString *)service data:(MMAccessToken *)token {
    NSMutableDictionary *keychainQuery = [self getKeychainQuery:service];
    SecItemDelete((__bridge CFDictionaryRef) keychainQuery);
    keychainQuery[(__bridge id) kSecValueData] = [NSKeyedArchiver archivedDataWithRootObject:token];
    SecItemAdd((__bridge CFDictionaryRef) keychainQuery, NULL);
}

+ (MMAccessToken *)load:(NSString *)service {
    id ret = nil;
    NSMutableDictionary *keychainQuery = [self getKeychainQuery:service];
    keychainQuery[(__bridge id) kSecReturnData] = (id) kCFBooleanTrue;
    keychainQuery[(__bridge id) kSecMatchLimit] = (__bridge id) kSecMatchLimitOne;
    CFDataRef keyData = NULL;
    if (SecItemCopyMatching((__bridge CFDictionaryRef) keychainQuery, (CFTypeRef *) &keyData) == noErr) {
        @try {
            ret = [NSKeyedUnarchiver unarchiveObjectWithData:(__bridge NSData *) keyData];
        }
        @catch (NSException *e) {
            NSLog(@"Unarchive of %@ failed: %@", service, e);
        }
        @finally {}
    }
    if (keyData) {
        CFRelease(keyData);
    }
    return ret;
}

+ (void)delete:(NSString *)service {
    NSMutableDictionary *keychainQuery = [self getKeychainQuery:service];
    SecItemDelete((__bridge CFDictionaryRef) keychainQuery);
}

@end

@implementation MMAccessTokenMutable
@dynamic accessToken, refreshToken, expiresIn, userId;

- (void)setAccessToken:(NSString *)accessToken {
    _accessToken = [accessToken copy];
}

- (void)setRefreshToken:(NSString *)refreshToken
{
    _refreshToken = [refreshToken copy];
}

- (void)setExpiresIn:(NSInteger)expiresIn {
    _expiresIn = expiresIn;
}

- (void)setUserId:(NSString *)userId {
    _userId = [userId copy];
}

@end
