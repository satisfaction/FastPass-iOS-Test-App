//
//  ViewController.m
//  FastPass iOS Test App
//
//  Created by Andy Hite on 3/20/15.
//  Copyright (c) 2015 Andrew Hite. All rights reserved.
//

#import "ViewController.h"

#import <BDBOAuth1Manager/BDBOAuth1RequestOperationManager.h>
#import <BDBOAuth1Manager/NSString+BDBOAuth1Manager.h>
#import <BDBOAuth1Manager/NSDictionary+BDBOAuth1Manager.h>

static NSString *const kOAuthProtocol = @"https";
static NSString *const kOAuthHost = @"dev.gsfn.us";
static NSString *const kOAuthConsumerKey = @"hssewhwk32i1";
static NSString *const kOAuthConsumerSecret = @"97ffsfe2ryqspj1ye345li6g3x3eu0ua";

@interface BDBOAuth1RequestSerializer ()

- (NSString *)OAuthSignatureForMethod:(NSString *)method
                            URLString:(NSString *)URLString
                           parameters:(NSDictionary *)parameters
                                error:(NSError *__autoreleasing *)error;

- (NSString *)OAuthAuthorizationHeaderForMethod:(NSString *)method
                                      URLString:(NSString *)URLString
                                     parameters:(NSDictionary *)parameters
                                          error:(NSError *__autoreleasing *)error;

@end

@interface NSDictionary (QueryString)
- (NSString *)queryStringRepresentation;
@end

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
    NSURL *fastpassUrl = [self fastPassUrlForCommunity];
    NSString *communityUrlWithFastpass = [NSString stringWithFormat:@"%@?fastpass=%@", @"https://c.dev.gsfn.us/fastpass-enabled", [[fastpassUrl absoluteString] bdb_URLEncode]];
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:communityUrlWithFastpass]];
}

- (NSURL *)fastPassUrlForCommunity {
    NSURL *baseURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@://%@", kOAuthProtocol, kOAuthHost]];
    
    NSDictionary *parameters = @{
                                 @"community": @"fastpass-enabled",
                                 @"email": @"test@foobar.com",
                                 @"name": @"testfoobar",
                                 @"uid": @"testfoobar"
                                 };

    BDBOAuth1RequestOperationManager *manager = [[BDBOAuth1RequestOperationManager alloc] initWithBaseURL:baseURL consumerKey:kOAuthConsumerKey consumerSecret:kOAuthConsumerSecret];
    
    NSString *header = [manager.requestSerializer OAuthAuthorizationHeaderForMethod:@"GET" URLString:[[NSURL URLWithString:@"/fastpass" relativeToURL:baseURL] absoluteString] parameters:parameters error:nil];
    
    NSString *authorizationHeader = [[header stringByReplacingOccurrencesOfString:@"\"" withString:@""] stringByReplacingOccurrencesOfString:@"OAuth " withString:@""];
    
    NSMutableDictionary *authorizationKeyValuePairs = [[NSMutableDictionary alloc] init];
    
    for (NSString *authorizationHeaderValue in [authorizationHeader componentsSeparatedByString:@", "]) {
        NSArray *keyValuePair = [authorizationHeaderValue componentsSeparatedByString:@"="];
        [authorizationKeyValuePairs setObject:[keyValuePair objectAtIndex:1] forKey:[keyValuePair objectAtIndex:0]];
    }
    
    [authorizationKeyValuePairs addEntriesFromDictionary:parameters];
    
    NSURL *fastpassURL = [[NSURL URLWithString:[NSString stringWithFormat:@"/fastpass?%@", [authorizationKeyValuePairs queryStringRepresentation]] relativeToURL:baseURL] absoluteURL];
    
    return fastpassURL;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
