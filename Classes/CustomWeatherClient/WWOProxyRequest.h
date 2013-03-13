//
//  WWOProxyRequest.h
//  LifelikeClock2
//
//  Created by Dmitri Petrishin on 12/20/12.
//  Copyright (c) 2012 Postindustria. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
	prCitiesRequest,
	prWeatherByLocRequest,
	prWeatherByCityRequest
} WWOProxyRequestType;

typedef enum {
	prUnknown,
	prWeatherAstronomyForcastComplete,
	prWeatherCurrentConditionComplete,
	prWeatherExtendedForcastComplete,
	prCompleted,
	prError
} WWOProxyRequestState;


@protocol WWOProxyRequestDelegate;
@interface WWOProxyRequest : NSObject

@property (nonatomic, retain) NSString* language;
@property (nonatomic, readwrite) float longitude;
@property (nonatomic, readwrite) float latitude;
@property (nonatomic, retain) NSString* search;

@property (nonatomic, retain) id data;
@property (nonatomic, readonly) WWOProxyRequestState state;
@property (nonatomic, assign) WWOProxyRequestType type;
@property (nonatomic, retain) NSError *requestError;

@property (nonatomic, assign) id <WWOProxyRequestDelegate> delegate;

//
// initialize request delegate with target and complete selector
//
- (id)initWithDelegate:(id <WWOProxyRequestDelegate>)delegate;

//
// request of weather
//
- (void)getWeather;

//
// request of detail
//
- (void)getWeatherDetailForecast;

//
// request of extended
//
- (void)getWeatherExtendedForecast;

//
// request of astronomy
//
- (void)getWeatherAstronomyForecast;

//
// request of city
//
- (void)searchCitiesByName:(NSString*)name;

@end

@protocol WWOProxyRequestDelegate <NSObject>

- (void)didCompleteWWORequest:(WWOProxyRequest*)wwoRequest;

@end