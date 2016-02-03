//
//  MMError.m
//  mymailru-ios-sdk
//
//  Created by d.taraev on 29.01.16.
//  Copyright © 2016 mail.ru. All rights reserved.
//

#import "MMError.h"

@implementation MMError

+ (instancetype)errorWithCode:(NSInteger)errorCode
{
    MMError *error = [MMError new];
    error.errorCode = errorCode;
    return error;
}

@end
