//
//  CustomWeatherClient.h
//  LifelikeClock2
//
//  Created by Dmitri Petrishin on 12/20/12.
//  Copyright (c) 2012 Postindustria. All rights reserved.
//

#import "AFHTTPClient.h"
#import "CustomWeatherConts.h"

@interface CustomWeatherClient : AFHTTPClient

+ (CustomWeatherClient*)sharedClient;
- (void)end;

@end
