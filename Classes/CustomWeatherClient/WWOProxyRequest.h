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

@property (nonatomic, strong) NSString* language;
@property (nonatomic, assign) float longitude;
@property (nonatomic, assign) float latitude;
@property (nonatomic, strong) NSString* search;

@property (nonatomic, readonly) id data;
@property (nonatomic, readonly) WWOProxyRequestState state;
@property (nonatomic, assign) WWOProxyRequestType type;
@property (nonatomic, readonly) NSError *requestError;

@property (nonatomic, weak) id <WWOProxyRequestDelegate> delegate;

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