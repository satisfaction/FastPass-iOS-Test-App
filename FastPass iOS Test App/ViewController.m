//
//  ViewController.m
//  FastPass iOS Test App
//
//  Created by Andy Hite on 3/20/15.
//  Copyright (c) 2015 Andrew Hite. All rights reserved.
//

#import "ViewController.h"

#import <AFOAuth1Client/AFOAuth1Client.h>

static NSString *const kOAuthProtocol = @"https";
static NSString *const kOAuthHost = @"staging.getsatisfaction.com";
static NSString *const kOAuthConsumerKey = @"ud65x2rfld83";
static NSString *const kOAuthConsumerSecret = @"3fk3tadpigapxrkuz5r3jgp6lamb8zlo";

@interface AFOAuth1Client ()

- (NSMutableURLRequest *)requestWithMethod:(NSString *)method
                                      path:(NSString *)path
                                parameters:(NSDictionary *)parameters;

@end

@implementation NSDictionary (QueryString)

- (NSString *) toQueryString {
    NSMutableArray *parts = [NSMutableArray array];
    for (id key in self) {
        id value = [self objectForKey: key];
        NSString *part = [NSString stringWithFormat: @"%@=%@", key, value];
        [parts addObject: part];
    }
    return [parts componentsJoinedByString: @"&"];
}

@end

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [button setTitle:@"Launch Community" forState:UIControlStateNormal];
    [button setFrame:CGRectMake(0.0, 0.0, 200.0, 60.0)];
    [button setCenter:self.view.center];
    [button setBackgroundColor:[UIColor purpleColor]];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(openCommunityInBrowser:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    
}

- (void)openCommunityInBrowser:(id)sender {
    [[UIApplication sharedApplication] openURL:[self fastPassUrlForCommunity]];
}

- (NSURL *)fastPassUrlForCommunity {
    NSURL *baseURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@://%@", kOAuthProtocol, kOAuthHost]];
    
    NSDictionary *parameters = @{
                                 @"community": @"the_satisfactory",
                                 @"email": @"qa+1426798655373@getsatisfaction.com",
                                 @"name": @"qa1426798655373",
                                 @"uid": @"qa1426798655373"
                                 };
    
    AFOAuth1Client *oauth = [[AFOAuth1Client alloc] initWithBaseURL:baseURL key:kOAuthConsumerKey secret:kOAuthConsumerSecret];
    [oauth setStringEncoding:NSISOLatin2StringEncoding];
    
    NSMutableURLRequest *request = [oauth requestWithMethod:@"GET" path:@"/fastpass" parameters:parameters];
    
    NSString *authorizationHeader = [[[request valueForHTTPHeaderField:@"Authorization"] stringByReplacingOccurrencesOfString:@"\"" withString:@""] stringByReplacingOccurrencesOfString:@"OAuth " withString:@""];
    
    NSMutableDictionary *authorizationKeyValuePairs = [[NSMutableDictionary alloc] init];
    
    for (NSString *authorizationHeaderValue in [authorizationHeader componentsSeparatedByString:@", "]) {
        NSArray *keyValuePair = [authorizationHeaderValue componentsSeparatedByString:@"="];
        [authorizationKeyValuePairs setObject:[keyValuePair objectAtIndex:1] forKey:[keyValuePair objectAtIndex:0]];
    }
    
    [authorizationKeyValuePairs addEntriesFromDictionary:parameters];
    
    NSLog(@"%@", [NSString stringWithFormat:@"%@://%@/fastpass?%@", kOAuthProtocol, kOAuthHost, [authorizationKeyValuePairs toQueryString]]);
    
    return [NSURL URLWithString:[NSString stringWithFormat:@"%@://%@/fastpass?%@", kOAuthProtocol, kOAuthHost, [authorizationKeyValuePairs toQueryString]]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
