//
//  CustomWeatherRequests.h
//  LifelikeClock2
//
//  Created by Dmitri Petrishin on 12/20/12.
//  Copyright (c) 2012 Postindustria. All rights reserved.
//

#import "CustomWeatherClient.h"
#import <Foundation/Foundation.h>


typedef void (^onCompleteRequest)(id responseData, NSError* error);

@class WWOProxyRequest;
@interface CustomWeatherRequests : NSObject

+ (void)cityWithWWORequest:(WWOProxyRequest*)wwoRequest completionBlock:(onCompleteRequest)completionBlock;
+ (void)weatherWithWWORequest:(WWOProxyRequest*)wwoRequest completionBlock:(onCompleteRequest)completionBlock;
+ (void)detailForecastWithWWORequest:(WWOProxyRequest*)wwoRequest completionBlock:(onCompleteRequest)completionBlock;
+ (void)extendedForecastWithWWORequest:(WWOProxyRequest*)wwoRequest completionBlock:(onCompleteRequest)completionBlock;
+ (void)astronomyForecastWithWWORequest:(WWOProxyRequest*)wwoRequest completionBlock:(onCompleteRequest)completionBlock;

@end
