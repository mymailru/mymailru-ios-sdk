//
//  MMUtil.m
//  mymailru-ios-sdk
//
//  Created by d.taraev on 25.01.16.
//  Copyright © 2016 mail.ru. All rights reserved.
//

#import "MMUtil.h"

@implementation MMUtil

static NSString *const kCharactersToBeEscapedInQueryString = @":/?&=;+!@#$()',*";

+ (NSString *)escapeString:(NSString *)value
{
    return (__bridge_transfer NSString *) CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (__bridge CFStringRef) value, NULL, (__bridge CFStringRef) kCharactersToBeEscapedInQueryString, CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding));
}

+ (NSString *)queryStringFromParams:(NSDictionary *)params
{
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:params.count];
    for (NSString *key in params) {
        if ([params[key] isKindOfClass:[NSString class]])
            [array addObject:[NSString stringWithFormat:@"%@=%@", key, [self escapeString:params[key]]]];
        else
            [array addObject:[NSString stringWithFormat:@"%@=%@", key, params[key]]];
    }
    return [array componentsJoinedByString:@"&"];
}

+ (NSDictionary *)explodeQueryString:(NSString *)queryString
{
    NSArray *keyValuePairs = [queryString componentsSeparatedByString:@"&"];
    NSMutableDictionary *parameters = [NSMutableDictionary new];
    for (NSString *keyValueString in keyValuePairs) {
        NSArray *keyValueArray = [keyValueString componentsSeparatedByString:@"="];
        parameters[keyValueArray[0]] = keyValueArray[1];
    }
    return parameters;
}

+ (NSString *)paramsStringFromURLString:(NSString *)urlString
{
    NSRange range = [urlString rangeOfString:@"?"];
    return [urlString substringFromIndex:(range.location + 1)];
}

@end
