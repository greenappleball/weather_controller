//
//  WeatherController.h
//  WeatherClock
//
//  Created by Igor Fedorov on 7/11/10.
//  Copyright 2010 Flash/Flex, iPhone developer at Postindustria. All rights reserved.
//

#import "WWOProxy.h"
#import "SearchPlaceViewController.h"
#import "BackPlaceViewControllerDelegate.h"
#import "WeatherControllerSettingsTableView.h"

typedef enum {
	wpInternetConnectionError,
	wpLocationServicesDisabledError,
	wpLocationUnknownError,
	wpWeatherServicesError,
	wpWeatherNOError,
	wpWeatherWillUpdate,
	wpWeatherUpdateLocation,
	wpSearchControllerNeedShow,
	wpWeatherIsUpdated,
	wpSearchServiceError
}WeatherControllerMessages;

@protocol WeatherControllerDelegate;
@protocol BackPlaceViewControllerDelegate;

@interface WeatherController : NSObject <CLLocationManagerDelegate, WWOProxyDelegate, WeatherControllerSettingsTableViewDelegate, SearchPlaceViewControllerDelegate> {
	
	int scheduledPlaceIdx;
	
	NSTimer *scheduledTimer;
	
	WeatherControllerSettingsTableView *settingsController;
	SearchPlaceViewController *searchCotroller;
}

@property (nonatomic, strong) NSMutableDictionary *data;
@property (nonatomic, readwrite) int scheduledPlaceIdx;
@property (nonatomic, weak) id <WeatherControllerDelegate> delegate;
@property (nonatomic, weak) id <BackPlaceViewControllerDelegate> bpcDelegate;

+ (WeatherController*)sharedController;

+ (void)end;

- (WeatherControllerSettingsTableView*)settingsViewController;

- (SearchPlaceViewController*)searchViewController;

//
// Search methods, may be needs separately controller
//
- (void)updateWeatherForCurrentLocation;
- (void)updateWeatherWithScheduledPlace;
- (void)updateWeather;

- (void)searchPlacesForQuery:(NSString*)aQuery;

//
// Weather cache methods
//

- (void)setPlaceForUpdates:(NSDictionary*)aPlace;

- (void)stopSchedulingWeather;

- (void)startSchedulingWeather;

- (NSString*)getLocationTitle;

- (void)sentMsgToDelegate:(WeatherControllerMessages)msg;

@end

@protocol WeatherControllerDelegate <NSObject>

- (void) weatherController:(id)sender endWithMessage:(WeatherControllerMessages)msg;
@end