//
//  CustomWeatherClient.m
//  LifelikeClock2
//
//  Created by Dmitri Petrishin on 12/20/12.
//  Copyright (c) 2012 Postindustria. All rights reserved.
//

#import "CustomWeatherClient.h"


static CustomWeatherClient* _sharedClient = nil;

@implementation CustomWeatherClient

+ (CustomWeatherClient*)sharedClient
{
    @synchronized(self) {
        if (nil == _sharedClient) {
            _sharedClient = [[[self class] alloc] initWithBaseURL:[NSURL URLWithString:CW_API_DOMAIN]];
            [_sharedClient setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
                if (AFNetworkReachabilityStatusNotReachable == status) {
                    [_sharedClient cancelAllHTTPOperationsWithMethod:nil path:nil];
                    [_sharedClient.operationQueue cancelAllOperations];
                }
            }];
        }
    }
    
    return _sharedClient;
}

- (void)end
{
    _sharedClient = nil;
}

- (id)initWithBaseURL:(NSURL *)url {
    self = [super initWithBaseURL:url];
    if (self) {
    }
    return self;
}

@end
