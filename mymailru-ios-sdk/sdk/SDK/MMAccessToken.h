//
//  MMAccessToken.h
//  mymailru-ios-sdk
//
//  Created by d.taraev on 20.01.16.
//  Copyright © 2016 mail.ru. All rights reserved.
//

#import "MMObject.h"

/**
 Presents My Mail.ru API access token that is used for API methods and other stuff.
 */
@interface MMAccessToken : MMObject

/// The string token for use in request parameters
@property(nonatomic, readonly, copy) NSString *accessToken;

/// The string refresh token for use if the tocken is expired
@property(nonatomic, readonly, copy) NSString *refreshToken;

/// Current user id for this token
@property(nonatomic, readonly, copy) NSString *userId;

/// Time when token expires
@property(nonatomic, readonly, assign) NSInteger expiresIn;

/// Indicates time of token creation
@property(nonatomic, readonly, assign) NSTimeInterval created;

//- (void)updateTokenInformationWithParams:(NSDictionary *)params;

/**
 Retrieve token from key-value query string
 @param urlString string that contains URL-query part with token. E.g. access_token=ffffff&expires_in=0...
 @return parsed token
 */
+ (instancetype)tokenFromUrlString:(NSString *)urlString;

/**
 Retrieve token from user defaults. Token must be saved to defaults with saveTokenToDefaults method
 @param defaultsKey path to file with saved token
 @return parsed token
 */
+ (instancetype)savedToken:(NSString *)defaultsKey;

/**
 Save token into user defaults by specified key
 @param defaultsKey key for defaults
 */
- (void)saveTokenToDefaults:(NSString *)defaultsKey;

/// Return YES if token has expired
- (BOOL)isExpired;

/**
 Remove token from storage
 */
+ (void)delete:(NSString *)service;

@end

@interface MMAccessTokenMutable : MMAccessToken
@property(nonatomic, readwrite, copy) NSString *accessToken;
@property(nonatomic, readwrite, copy) NSString *refreshToken;
@property(nonatomic, readwrite, copy) NSString *userId;
@property(nonatomic, readwrite, assign) NSInteger expiresIn;
@end