//
//  MMUtil.h
//  mymailru-ios-sdk
//
//  Created by d.taraev on 25.01.16.
//  Copyright © 2016 mail.ru. All rights reserved.
//

#define MM_COLOR        [UIColor colorWithRed:0 / 255 green:122.0f / 255 blue:255.0f / 255 alpha:1.0f]

#import <Foundation/Foundation.h>

@interface MMUtil : NSObject

/**
 Various functions
 */
/**
 Composes a query string from params dictionary
 @param params dictionary of parameters
 @return string with key=value pairs joined by & symbol
 */
+ (NSString *)queryStringFromParams:(NSDictionary *)params;
/**
 Breaks key=value string to dictionary
 @param queryString string with key=value pairs joined by & symbol
 @return Dictionary of parameters
 */
+ (NSDictionary *)explodeQueryString:(NSString *)queryString;
/**
 Substrings a query string from the query string
 @param urlString the complete URL string
 @return string with key=value pairs joined by & symbol
 */
+ (NSString *)paramsStringFromURLString:(NSString *)urlString;

@end
