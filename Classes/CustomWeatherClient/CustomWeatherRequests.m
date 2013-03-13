//
//  CustomWeatherRequests.m
//  LifelikeClock2
//
//  Created by Dmitri Petrishin on 12/20/12.
//  Copyright (c) 2012 Postindustria. All rights reserved.
//

#import "WWOProxyRequest.h"
#import "CustomWeatherRequests.h"

@implementation CustomWeatherRequests

#pragma mark - Private

+ (void)getPath:(NSString*)path withParams:(NSDictionary*)params completionBlock:(onCompleteRequest)completionBlock
{
    [[CustomWeatherClient sharedClient] cancelAllHTTPOperationsWithMethod:@"GET" path:path];
    [[CustomWeatherClient sharedClient] getPath:path
                                     parameters:params
                                        success:^(AFHTTPRequestOperation *operation, id responceObject) {
                                            if (completionBlock) {
                                                completionBlock(responceObject, nil);
                                            }
                                        }
                                        failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                            if (completionBlock) {
                                                completionBlock(nil, error);
                                            }
                                        }];
}

+ (NSDictionary*)paramsForProduct:(NSString*)product withLanguage:(NSString*)language
{
    NSDictionary* params = @{
        CLIENT_PARAM:CLIENT,
        PASSWORD_PARAM:PASSWORD,
        PRODUCT_PARAM:product,
        LANGUAGE_PARAM:language
	};
    return params;
}

+ (NSDictionary*)searchParamsWithSearchString:(NSString*)searchString language:(NSString*)language
{
    NSMutableDictionary* params = [[[self class] paramsForProduct:SEARCH withLanguage:language] mutableCopy];
    [params setObject:searchString forKey:SEARCH_PARAM];
    return params;
}

+ (NSDictionary*)weatherParamsForProduct:(NSString*)product withLatitude:(CGFloat)latitude longitude:(CGFloat)longitude language:(NSString*)language
{
    NSMutableDictionary* params = [[[self class] paramsForProduct:product withLanguage:language] mutableCopy];
    [params setObject:[NSString stringWithFormat:@"%.2f", latitude] forKey:LATITUDE_PARAM];
    [params setObject:[NSString stringWithFormat:@"%.2f", longitude] forKey:LONGTITUDE_PARAM];
    return params;
}

#pragma mark - Public

+ (void)cityWithWWORequest:(WWOProxyRequest*)wwoRequest completionBlock:(onCompleteRequest)completionBlock
{
    NSDictionary* params = [[self class] searchParamsWithSearchString:wwoRequest.search language:wwoRequest.language];
    [[self class] getPath:XML_PATH withParams:params completionBlock:completionBlock];
}

+ (void)weatherWithWWORequest:(WWOProxyRequest*)wwoRequest completionBlock:(onCompleteRequest)completionBlock
{
    NSDictionary* params = [[self class] weatherParamsForProduct:CURRENT_CONDITIONS
                                                    withLatitude:wwoRequest.latitude
                                                       longitude:wwoRequest.longitude
                                                        language:wwoRequest.language];
    [[self class] getPath:XML_PATH withParams:params completionBlock:completionBlock];
}

+ (void)detailForecastWithWWORequest:(WWOProxyRequest*)wwoRequest completionBlock:(onCompleteRequest)completionBlock
{
    NSDictionary* params = [[self class] weatherParamsForProduct:DETAILED_FORECAST
                                                    withLatitude:wwoRequest.latitude
                                                       longitude:wwoRequest.longitude
                                                        language:wwoRequest.language];
    [[self class] getPath:XML_PATH withParams:params completionBlock:completionBlock];
    
}

+ (void)extendedForecastWithWWORequest:(WWOProxyRequest*)wwoRequest completionBlock:(onCompleteRequest)completionBlock
{
    NSDictionary* params = [[self class] weatherParamsForProduct:EXPANDED_FORECAST
                                                    withLatitude:wwoRequest.latitude
                                                       longitude:wwoRequest.longitude
                                                        language:wwoRequest.language];
    [[self class] getPath:XML_PATH withParams:params completionBlock:completionBlock];

}

+ (void)astronomyForecastWithWWORequest:(WWOProxyRequest *)wwoRequest completionBlock:(onCompleteRequest)completionBlock
{
    NSDictionary* params = [[self class] weatherParamsForProduct:ASTRONOMY_FORECAST
                                                    withLatitude:wwoRequest.latitude
                                                       longitude:wwoRequest.longitude
                                                        language:wwoRequest.language];
    [[self class] getPath:XML_PATH withParams:params completionBlock:completionBlock];
    
}

@end
