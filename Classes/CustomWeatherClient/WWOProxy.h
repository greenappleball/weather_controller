//
//  WWOProxy.h
//  WeatherClock
//
//  Created by Igor Fedorov on 7/11/10.
//  Copyright 2010 Flash/Flex, iPhone developer at Postindustria. All rights reserved.
//

#import <Foundation/Foundation.h>


@protocol WWOProxyDelegate;
@interface WWOProxy : NSObject

@property (nonatomic, assign) id <WWOProxyDelegate> delegate;

+ (NSDictionary*)iconsMapping;

//
// Request available Weather data as 3 hourly, Day and Night and 24 hour interval
//
+ (void)requestWeatherDataWithCity:(NSString*)aCity andCountry:(NSString*)aCountry;

//
// Request available Weather data as 3 hourly, Day and Night and 24 hour interval
//
+ (void)requestWeatherDataWithLatitude:(float)aLatitude longitude:(float)aLongitude;

//
// The City search method feed request
//
+ (void)requestCitiesByQuery:(NSString*)queryString;

//
// Set delegate
//
+ (void)setDelegate:(id<WWOProxyDelegate>)aDelegate;

//
// Release instance
//
+ (void)end;

@end

@protocol WWOProxyDelegate <NSObject>

//
// Rise when weahter service return error
//

- (void)weatherServiceReturnError:(NSError*)error;

//
// Rise when city search service return error
//

-(void)citySearchServiceReturnError:(NSError*)error;

@optional

//
// Rise when proxy get new data
//
- (void)weatherProxy:(id)sender transferedData:(NSDictionary*)aData;

//
// Rise when cities search is complete
//
- (void)weatherProxy:(id)sender findedCities:(NSArray*)theCities;

@end