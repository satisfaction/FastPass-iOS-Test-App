//
//  NSDictionary+QueryString.m
//  FastPass iOS Test App
//
//  Created by Andy Hite on 3/20/15.
//  Copyright (c) 2015 Andrew Hite. All rights reserved.
//

#import "NSDictionary+QueryString.h"

@implementation NSDictionary (QueryString)

- (NSString *)queryStringRepresentation {
    NSMutableArray *paramArray = [NSMutableArray array];
    
    [self enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        NSString *param = [NSString stringWithFormat:@"%@=%@", key, obj];
        [paramArray addObject:param];
    }];
    
    return [paramArray componentsJoinedByString:@"&"];
}

@end
