//
//  WeatherController.m
//  WeatherClock
//
//  Created by Igor Fedorov on 7/11/10.
//  Copyright 2010 Flash/Flex, iPhone developer at Postindustria. All rights reserved.
//


#import "WeatherController.h"
#import "CustomWeatherConts.h"
#import "CustomWeatherClient.h"

#import <MapKit/MapKit.h>
#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface WeatherController() <CLLocationManagerDelegate>

@property (nonatomic, strong) WeatherControllerSettingsTableView *settingsController;
@property (nonatomic, strong) SearchPlaceViewController *searchCotroller;
@property (nonatomic, strong) NSMutableDictionary *weatherSettings;
@property (nonatomic, strong) NSMutableArray *weatherCache;
@property (nonatomic, strong) CLLocationManager* locationManager;
@property (nonatomic, strong) CLLocation *currentLocation;
@property (nonatomic, strong) id reverseGeocoder;
@property (nonatomic, strong) NSTimer *scheduledTimer;

- (void)saveToFile;

- (NSString*)dataFilePath;

- (void)removePlaceFromCache:(NSDictionary*)aPlace;

- (int)addPlaceToCache:(NSDictionary*)aPlace;

- (int)placeIdxInCache:(NSDictionary*)aPlace;

- (void)reverseGeocodeWithLocation:(CLLocation*)location;

- (void)releaseRverseGeocoder;

- (void)releaseReachability;

- (void)parseGeocoderPlace:(MKPlacemark*)placemark error:(NSError*)error;

@end

@implementation WeatherController

@synthesize delegate;
@synthesize scheduledPlaceIdx;
@synthesize weatherCache;
@synthesize data = _data;
@synthesize currentLocation;
@synthesize bpcDelegate;
@synthesize locationManager, reverseGeocoder;

#pragma mark - Accesories

- (NSMutableDictionary *)weatherSettings
{
    if (nil == _weatherSettings) {
        if ([[NSFileManager defaultManager] fileExistsAtPath:[self dataFilePath]]) {
            _weatherSettings = [[NSDictionary dictionaryWithContentsOfFile:[self dataFilePath]] mutableCopy];
        }
        if (nil == _weatherSettings) {
            _weatherSettings = [[NSMutableDictionary alloc] init];
        }
    }
    return _weatherSettings;
}

- (NSMutableArray *)weatherCache
{
    if (nil == weatherCache) {
        weatherCache = [self.weatherSettings[kWeatherCache] mutableCopy];
        if (nil == weatherCache) {
			weatherCache = [NSMutableArray array];
        }
    }
    return weatherCache;
}

#pragma mark - Private

- (void)saveToFile {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        [self.weatherSettings setValue:[NSNumber numberWithInt:scheduledPlaceIdx] forKey:kPlaceIdx];
        [self.weatherSettings setValue:self.weatherCache forKey:kWeatherCache];
        [self.weatherSettings writeToFile:[self dataFilePath] atomically:NO];
    });
}

- (NSString*)dataFilePath {
	NSString *documentsDirectory = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
	NSString *filename = [NSString stringWithFormat:@"%@weather_cache.plist", FILE_PREFIX];
	return [documentsDirectory stringByAppendingPathComponent:filename];
}

- (void)removePlaceFromCache:(NSDictionary*)aPlace {
	int remIdx = [self placeIdxInCache:aPlace];
	if (remIdx != NSNotFound) {
		//NSMutableDictionary *remWeather = [self.weatherCache objectAtIndex:remIdx];
		[self.weatherCache removeObjectAtIndex:remIdx];
	}
}

- (int)addPlaceToCache:(NSDictionary*)aPlace {
	int ret = NSNotFound;
	if ([self placeIdxInCache:aPlace] == NSNotFound) {
		NSMutableDictionary *weather = [[NSMutableDictionary alloc] initWithObjectsAndKeys:aPlace, WEATHER_KEY_PLACE,nil];
		[self.weatherCache addObject:weather];
		ret = [self.weatherCache indexOfObject:weather];
	}
	
	return ret;
	
}

- (int)placeIdxInCache:(NSDictionary*)aPlace {
	int ret = NSNotFound;
	for (NSMutableDictionary *weather in self.weatherCache) {
		NSDictionary *place = [weather objectForKey:WEATHER_KEY_PLACE];
		if ([[place objectForKey:PLACE_KEY_ID] isEqualToString:[aPlace objectForKey:PLACE_KEY_ID]]) {
			ret = [self.weatherCache indexOfObject:weather];
			break;
		}
	}
	return ret;
}

- (void)reverseGeocodeWithLocation:(CLLocation*)location
{
    CLGeocoder* geo = [[CLGeocoder alloc] init];
    [geo reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
        //
        dispatch_async(dispatch_get_main_queue(), ^{
            //
            MKPlacemark* placemark = nil;
            if (placemarks.count > 0) {
                placemark = [placemarks objectAtIndex:0];
            }
            //
            [self parseGeocoderPlace:placemark error:error];
        });
        self.reverseGeocoder = geo;
    }];
}

- (void)releaseRverseGeocoder {
    if (self.reverseGeocoder != nil) {
        self.reverseGeocoder = nil;
    }
}

- (void)releaseReachability {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)parseGeocoderPlace:(MKPlacemark*)placemark error:(NSError*)error {
    NSDictionary *currentPlace;
    
    CLLocation* location = nil == placemark ? self.currentLocation : placemark.location;
    
    BOOL isOk = (placemark != nil && error == nil);
    
    NSString *timezoneName = [[NSTimeZone defaultTimeZone] name];
    NSString *countryStr = isOk ? placemark.country : UNKNOWN_LOCATION;
    NSString *cityStr = isOk ? placemark.locality : UNKNOWN_LOCATION;
    NSString *regionStr = isOk ? placemark.administrativeArea : UNKNOWN_LOCATION;
    
    currentPlace = [NSDictionary dictionaryWithObjectsAndKeys:
                    countryStr, PLACE_KEY_COUNTRY,
                    cityStr, PLACE_KEY_CITY,
                    regionStr, PLACE_KEY_REGION,
                    timezoneName, PLACE_KEY_TIMEZONE,
                    [NSNumber numberWithDouble:location.coordinate.latitude], PLACE_KEY_LATITUDE,
                    [NSNumber numberWithDouble:location.coordinate.longitude], PLACE_KEY_LONGITUDE, nil];
    
    if (_data == nil) {
        _data = [NSMutableDictionary dictionary];
    }
    
    [_data setObject:currentPlace forKey:WEATHER_KEY_PLACE];
    
    if (scheduledPlaceIdx == AUTOMATIC_IDX) {
        float lat = [[currentPlace objectForKey:PLACE_KEY_LATITUDE] floatValue];
        float lon = [[currentPlace objectForKey:PLACE_KEY_LONGITUDE] floatValue];
        [WWOProxy requestWeatherDataWithLatitude:lat longitude:lon];
    }
}

- (id)init {
	if ((self = [super init])) {
		[WWOProxy setDelegate:self];
		scheduledPlaceIdx = [self.weatherSettings[kPlaceIdx] intValue];
		
		if ([self.weatherCache count] <= scheduledPlaceIdx) {
			scheduledPlaceIdx = AUTOMATIC_IDX;
		}
	}
	
	//[self performSelector:@selector(startSchedulingWeather) withObject:nil afterDelay:1.0];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:AFNetworkingReachabilityDidChangeNotification object:nil];
	
	return self;
}

- (void) releaseLocationManager {
    if (self.locationManager != nil) {
        [self.locationManager stopUpdatingLocation];
		[self.locationManager setDelegate:nil];
		self.locationManager = nil;
	}
}

- (void)dealloc {
	[self releaseLocationManager];
    
    self.reverseGeocoder = nil;
	[_searchCotroller cancel:nil];
	_searchCotroller = nil;
	_settingsController = nil;
	[self.weatherCache removeAllObjects];
	self.weatherCache = nil;
    self.bpcDelegate = nil;
	_data = nil;
	[WWOProxy end];
}

static WeatherController *sharedController;

+ (WeatherController *)sharedController {
	@synchronized(self) {
		if (!sharedController) {
			sharedController = [[self alloc] init];
		}
	}
	return sharedController;
}

+ (id)alloc {
	@synchronized(self) {
		NSAssert(sharedController == nil, @"Attempted to allocate a second instance of a singleton.");
		return [super alloc];
	}
	return nil;
}

+(void)end {
	[sharedController releaseReachability];
	[sharedController stopSchedulingWeather];
	
    [sharedController releaseLocationManager];
    
	[sharedController releaseRverseGeocoder];
	sharedController = nil;
}

#pragma mark -
#pragma mark WeatherController public methods

- (void)sentMsgToDelegate:(WeatherControllerMessages)msg {
	if ([self.delegate respondsToSelector:@selector(weatherController:endWithMessage:)]){
		[self.delegate weatherController:self endWithMessage:msg];
	}
}

- (void)stopSchedulingWeather {
	if (scheduledPlaceIdx == AUTOMATIC_IDX) {
		[self.locationManager stopUpdatingLocation];
		[self releaseRverseGeocoder];
	}
	if (_scheduledTimer != nil) {
		[_scheduledTimer invalidate];
		_scheduledTimer = nil;
	}
}

- (void)startSchedulingWeather {
	if (_scheduledTimer == nil || ![_scheduledTimer isValid]) {
	} else {
		return;
	}
	
	if (scheduledPlaceIdx != AUTOMATIC_IDX) {
		NSMutableDictionary *weather = [self.weatherCache objectAtIndex:scheduledPlaceIdx];
		NSDate *updDate = [weather objectForKey:@"updated"];
		if (updDate != nil) {
			NSTimeInterval oldSec = -[updDate timeIntervalSinceDate:[NSDate date]];
			int isNeedUpdate = oldSec - WWO_UPDATES_TIMEOUT_SEC;
			if (isNeedUpdate > 0) {
				[self updateWeatherWithScheduledPlace];
			} else {
				NSDate *updateTime = [NSDate dateWithTimeIntervalSinceNow:(WWO_UPDATES_TIMEOUT_SEC + isNeedUpdate)];
				_scheduledTimer = [[NSTimer alloc] initWithFireDate:updateTime
                                                           interval:WWO_UPDATES_TIMEOUT_SEC
                                                             target:self
                                                           selector:@selector(updateWeatherWithScheduledPlace)
                                                           userInfo:nil
                                                            repeats:YES];
				[[NSRunLoop currentRunLoop] addTimer:_scheduledTimer forMode:NSDefaultRunLoopMode];
				_data = weather;
				[self sentMsgToDelegate:wpWeatherIsUpdated];
				//scheduledTimer = [NSTimer scheduledTimerWithTimeInterval:-isNeedUpdate target:self selector:@selector(upadateWeatherWithScheduledPlace) userInfo:nil repeats:YES];
			}
			
		} else {
			[self updateWeatherWithScheduledPlace];
		}
		
		
	} else {
		[self updateWeatherForCurrentLocation];
	}
	
}

- (SearchPlaceViewController*)searchViewController {
	if (_searchCotroller == nil) {
		_searchCotroller = [[SearchPlaceViewController alloc] init];
		[_searchCotroller setDelegate:self];
	}
	
	return _searchCotroller;
}

- (WeatherControllerSettingsTableView*)settingsViewController {
	if (_settingsController == nil) {
		_settingsController = [[WeatherControllerSettingsTableView alloc] init];
	}
	
	NSMutableArray *places = [NSMutableArray array];
	for (NSDictionary *weather in weatherCache) {
		[places addObject:[weather objectForKey:WEATHER_KEY_PLACE]];
	}
	[_settingsController setPlaces:places];
	[_settingsController setDelegate:self];
	return _settingsController;
}

- (void)updateWeatherForCurrentLocation {
	if (self.locationManager != nil) {
		if ([self.locationManager location] != nil) {
			[self reverseGeocodeWithLocation:[self.locationManager location]];
		} else {
			//[self performSelector:@selector(asyncUpdateLocation) withObject:nil afterDelay:0.5];
			[self.locationManager startUpdatingLocation];
		}
		
	} else {
		self.locationManager = [[CLLocationManager alloc] init];
		if ([CLLocationManager locationServicesEnabled]) {
			
			//[self performSelector:@selector(asyncUpdateLocation) withObject:nil afterDelay:0.5];
			
			[self.locationManager setDelegate:self];
			[self.locationManager setDistanceFilter:[[NSNumber numberWithFloat:DISTANCE_ACCURACY/200] doubleValue]];
			[self.locationManager setDesiredAccuracy:kCLLocationAccuracyKilometer];
			[self.locationManager startUpdatingLocation];/**/
			
		} else {
			[self sentMsgToDelegate:wpLocationServicesDisabledError];
		}
	}
}

- (void)updateWeatherWithScheduledPlace {
	NSDictionary *aPlace = [[self.weatherCache objectAtIndex:scheduledPlaceIdx] objectForKey:WEATHER_KEY_PLACE];
	[WWOProxy requestWeatherDataWithLatitude:[[aPlace objectForKey:PLACE_KEY_LATITUDE] floatValue]
								   longitude:[[aPlace objectForKey:PLACE_KEY_LONGITUDE] floatValue]];
}
- (NSString*)getLocationTitle{
    NSString* result=@"";
    if ([self scheduledPlaceIdx] == AUTOMATIC_IDX) {
        result=NSLocalizedString(@"Automatic mode",@"Automatic mode");
    } else {
        NSMutableArray *places = [NSMutableArray array];
        for (NSDictionary *weather in weatherCache) {
            [places addObject:[weather objectForKey:WEATHER_KEY_PLACE]];
        }
        
        NSDictionary *aPlace=[places objectAtIndex:[self scheduledPlaceIdx]];
        result = [NSString stringWithFormat:@"%@, %@", [aPlace objectForKey:PLACE_KEY_COUNTRY], [aPlace objectForKey:PLACE_KEY_CITY]];
        
    }
    return result;
}
- (void)updateWeather {
    if (scheduledPlaceIdx == AUTOMATIC_IDX) {
        [self updateWeatherForCurrentLocation];
    } else {
        [self updateWeatherWithScheduledPlace];
    }
    //    [self startSchedulingWeather];
}

- (void)searchPlacesForQuery:(NSString*)aQuery {
	[WWOProxy requestCitiesByQuery:aQuery];
}

- (void)setPlaceForUpdates:(NSDictionary*)aPlace {
	[self stopSchedulingWeather];
	scheduledPlaceIdx = [self placeIdxInCache:aPlace];
	if (scheduledPlaceIdx == NSNotFound) {
		scheduledPlaceIdx = [self addPlaceToCache:aPlace];
	}
    [self saveToFile];
    
	[self startSchedulingWeather];
}

- (void)startTest {
	[WWOProxy requestCitiesByQuery:@"kiev"];
	[WWOProxy requestCitiesByQuery:@"odessa"];
	[WWOProxy requestCitiesByQuery:@"moscow"];
	[WWOProxy requestCitiesByQuery:@"los angeles"];
	[WWOProxy requestCitiesByQuery:@"washington"];
	[WWOProxy requestCitiesByQuery:@"Kherson"];
	
}

#pragma mark -
#pragma mark SearchPlaceViewControllerDelegate methods

- (void)getPlacesByQuery:(NSString*)aQuery {
	[self searchPlacesForQuery:aQuery];
}

- (void)userChoosePlace:(NSDictionary*)aPlace {
	[self setPlaceForUpdates:aPlace];
	[self settingsViewController];
}

#pragma mark -
#pragma mark WeatherControllerSettingsTableViewDelegate methods

- (void)setCurrentPlace:(NSDictionary*)aPlace {
	[self sentMsgToDelegate:wpWeatherWillUpdate];
	[self setPlaceForUpdates:aPlace];
}

- (void)setAutomaticWeatherMode {
	if (scheduledPlaceIdx != AUTOMATIC_IDX) {
		[self sentMsgToDelegate:wpWeatherWillUpdate];
		[self stopSchedulingWeather];
		scheduledPlaceIdx = AUTOMATIC_IDX;
        [self saveToFile];
		_data = nil;
		[self startSchedulingWeather];
	}
}

- (void)addNewPlace {
	[self sentMsgToDelegate:wpSearchControllerNeedShow];
}

- (void)removePlace:(NSDictionary*)aPlace {
	if (scheduledPlaceIdx == AUTOMATIC_IDX) {
		[self removePlaceFromCache:aPlace];
	} else if (scheduledPlaceIdx == [self placeIdxInCache:aPlace]) {
		[self setAutomaticWeatherMode];
		[self removePlaceFromCache:aPlace];
	} else {
		[self stopSchedulingWeather];
		[self removePlaceFromCache:aPlace];
		[self setCurrentPlace:[_data objectForKey:WEATHER_KEY_PLACE]];
		[self startSchedulingWeather];
	}
	
	[self saveToFile];
}

#pragma mark -
#pragma mark CLLocationManager delegate methods

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    
    CLLocationDistance distance = [self.currentLocation distanceFromLocation:newLocation];
    BOOL requiresUpdate = (nil==self.currentLocation || distance >= DISTANCE_ACCURACY);
    
    if ( requiresUpdate ) {
        self.currentLocation = newLocation;
        [self reverseGeocodeWithLocation:self.currentLocation];
    }
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
	if ([error domain] == kCLErrorDomain) {
		
		// We handle CoreLocation-related errors here
		switch ([error code]) {
				// "Don't Allow" on two successive app launches is the same as saying "never allow". The user
				// can reset this for all apps by going to Settings > General > Reset > Reset Location Warnings.
			case kCLErrorDenied:
				[self sentMsgToDelegate:wpLocationServicesDisabledError];
                [self stopSchedulingWeather];
				break;
			case kCLErrorLocationUnknown:
			default:
				if (_data != nil) {
					NSDate *updDate = [_data objectForKey:@"updated"];
					if (updDate != nil) {
						NSTimeInterval oldSec = -[updDate timeIntervalSinceDate:[NSDate date]];
						int isNeedUpdate = oldSec - WWO_UPDATES_TIMEOUT_SEC;
						if (isNeedUpdate > 0) {
							[self sentMsgToDelegate:wpLocationUnknownError];
						}
						
					} else {
						[self sentMsgToDelegate:wpLocationUnknownError];
					}
				} else {
					[self sentMsgToDelegate:wpLocationUnknownError];
				}
				break;
		}
	}
}

#pragma mark -
#pragma mark WWOProxyDelegate methods

- (void)citySearchServiceReturnError:(NSError *)error {
	[self sentMsgToDelegate:wpSearchServiceError];
}

- (void)weatherProxy:(id)sender transferedData:(NSDictionary*)aData {
	if (scheduledPlaceIdx == AUTOMATIC_IDX) {
		NSMutableDictionary *tmpWeather = [NSMutableDictionary dictionaryWithDictionary:aData];
        id value = [_data objectForKey:WEATHER_KEY_PLACE];
		[tmpWeather setObject:(nil != value ? value : @"") forKey:WEATHER_KEY_PLACE];
		[tmpWeather setObject:[NSDate date] forKey:@"updated"];
		_data = [NSMutableDictionary dictionaryWithDictionary:tmpWeather];
		NSDate *updateTime = [NSDate dateWithTimeIntervalSinceNow:WWO_UPDATES_TIMEOUT_SEC];
		[self stopSchedulingWeather];
		_scheduledTimer = [[NSTimer alloc] initWithFireDate:updateTime
                                                   interval:0
                                                     target:self
                                                   selector:@selector(updateWeatherForCurrentLocation)
                                                   userInfo:nil
                                                    repeats:NO];
		[[NSRunLoop currentRunLoop] addTimer:_scheduledTimer forMode:NSDefaultRunLoopMode];
	} else {
		NSMutableDictionary *weather = [self.weatherCache objectAtIndex:scheduledPlaceIdx];
		[weather addEntriesFromDictionary:aData];
		[weather setObject:[NSDate date] forKey:@"updated"];
		_data = weather;
		
		[self saveToFile];
		[self startSchedulingWeather];
	}
	
	[self sentMsgToDelegate:wpWeatherIsUpdated];
}

- (void)weatherServiceReturnError:(NSError*)error {
	[self sentMsgToDelegate:wpWeatherServicesError];
}

- (void)weatherProxy:(id)sender findedCities:(NSArray*)theCities {
	if (_searchCotroller != nil){
		[_searchCotroller setFoundPlaces:theCities];
	}
}

#pragma mark -
#pragma mark Reachability notifications Handle

-(void)reachabilityChanged:(NSNotification *)notification {
    NSNumber* currentNetworkStatus = notification.userInfo[AFNetworkingReachabilityNotificationStatusItem];
	switch ([currentNetworkStatus integerValue]) {
		case AFNetworkReachabilityStatusUnknown:
		case AFNetworkReachabilityStatusNotReachable:
#ifdef DEBUG
			NSLog(@"NotReachable");
#endif
		case AFNetworkReachabilityStatusReachableViaWWAN:
		case AFNetworkReachabilityStatusReachableViaWiFi:
#ifdef DEBUG
			NSLog(@"ReachableViaWiFi");
#endif
			if (scheduledPlaceIdx == AUTOMATIC_IDX) {
				[self updateWeatherForCurrentLocation];
			} else {
				[self stopSchedulingWeather];
				[self startSchedulingWeather];
			}
			
			break;
	}
}

@end
