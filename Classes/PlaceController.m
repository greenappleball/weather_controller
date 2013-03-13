//
//  PlaceController.m
//  LifelikeClock2
//
//  Created by Dmitri Petrishin on 3/13/13.
//  Copyright (c) 2013 Postindustria. All rights reserved.
//

#import "PlaceController.h"
#import "CustomWeatherConts.h"

#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>


@interface PlaceController () <CLLocationManagerDelegate>

@property(strong, nonatomic)	CLLocationManager *locationManager;
@property(strong, nonatomic)	CLGeocoder *reverseGeocoder;

@end


@implementation PlaceController

#pragma mark - Actions

- (NSDictionary*)placeWithPlacemark:(MKPlacemark*)placemark {
	
    BOOL isPlacemark = placemark != nil;
    CLLocation *currentLocation = [self.locationManager location];
    NSString* city = isPlacemark ? placemark.subLocality : UNKNOWN_LOCATION;
    NSString* country = isPlacemark ? placemark.country : UNKNOWN_LOCATION;
    
    NSDictionary *currentPlace = @{
                                   PLACE_KEY_CITY : city,
                                   PLACE_KEY_COUNTRY : country,
                                   PLACE_KEY_LATITUDE : [NSNumber numberWithDouble:currentLocation.coordinate.latitude],
                                   PLACE_KEY_LONGITUDE : [NSNumber numberWithDouble:currentLocation.coordinate.longitude]
                                   };
    return currentPlace;
}

- (void)mapPlacemarks:(NSArray*)placemarks withError:(NSError*)error
{
    NSMutableArray* places = [[NSMutableArray alloc] init];
    for (MKPlacemark* placemark in placemarks) {
        [places addObject:[self placeWithPlacemark:placemark]];
    }
	
//    self.foundPlaces = places;
    
    // TODO:
    if (nil == error) {
    } else {
        if ([self.delegate respondsToSelector:@selector(weatherController:endWithMessage:)]){
            //            [self.delegate weatherController:self endWithMessage:wpLocationUnknownError];
        }
    }
}

#pragma mark - Test

- (void)asyncUpdateLocation {
	NSNumber *lat = [NSNumber numberWithFloat:55.630f];
	NSNumber *lon = [NSNumber numberWithFloat:37.600f];
	CLLocation *location = [[CLLocation alloc] initWithLatitude:[lat doubleValue] longitude:[lon doubleValue]];
	[self locationManager:self.locationManager didUpdateToLocation:location fromLocation:nil];
}

#pragma mark -

- (void)reverseGeocodeWithLocation:(CLLocation*)location
{
    __weak __typeof(&*self)pointer = self;
	self.reverseGeocoder = [[CLGeocoder alloc] init];
    [self.reverseGeocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
        [pointer mapPlacemarks:placemarks withError:error];
    }];
    
}

- (void)releaseRverseGeocoder {
	if (self.reverseGeocoder != nil) {
		[self.reverseGeocoder cancelGeocode];
		self.reverseGeocoder = nil;
	}
}

- (void)updateWeatherForCurrentLocation {
	if (self.locationManager != nil) {
		if ([self.locationManager location] != nil) {
			[self reverseGeocodeWithLocation:[self.locationManager location]];
		} else {
			//NSLog(@"kherson location");
			//[self performSelector:@selector(asyncUpdateLocation) withObject:nil afterDelay:0.5];
			[self.locationManager startUpdatingLocation];
		}
		
	} else {
		self.locationManager = [[CLLocationManager alloc] init];
		if ([CLLocationManager locationServicesEnabled]) {
            [self.locationManager setDelegate:self];
            [self.locationManager setDesiredAccuracy:kCLLocationAccuracyKilometer];
            [self.locationManager startUpdatingLocation];
			
		} else {
			if ([self.delegate respondsToSelector:@selector(weatherController:endWithMessage:)]){
				// TODO: [delegate weatherController:self endWithMessage:wpLocationServicesDisabledError];
			}
		}
	}
}

#pragma mark - Public

- (void)currentPlaceWithBlock:(void (^)(NSDictionary* place))block
{
    if (block) {
        block(@{});
    }
}

- (void)placesByQuery:(NSString*)query withBlock:(void (^)(NSDictionary* place))block
{
    if (block) {
        block(@{});
    }
}

#pragma mark - CLLocationManager delegate methods

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
	[manager stopUpdatingLocation];
	[self reverseGeocodeWithLocation:newLocation];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
	[self.locationManager stopUpdatingLocation];
//	[self removeProgressVeiw];
//	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:[error localizedDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
//	[alertView show];
}

//#pragma mark -
//#pragma mark MKReverseGeocoderDelegate methods
//
//- (void)reverseGeocoder:(MKReverseGeocoder *)geocoder didFindPlacemark:(MKPlacemark *)placemark {
//
//	NSDictionary *currentPlace;
//	CLLocation *currentLocation;
//	currentLocation = [self.locationManager location];
//
//	if (placemark != nil) {
//		currentPlace = [NSDictionary dictionaryWithObjectsAndKeys:
//						placemark.country, PLACE_KEY_COUNTRY,
//						placemark.subLocality, PLACE_KEY_CITY,
//						[NSNumber numberWithDouble:currentLocation.coordinate.latitude], PLACE_KEY_LATITUDE,
//						[NSNumber numberWithDouble:currentLocation.coordinate.longitude], PLACE_KEY_LONGITUDE, nil];
//	} else {
//		currentPlace = [NSDictionary dictionaryWithObjectsAndKeys:
//						UNKNOWN_LOCATION, PLACE_KEY_COUNTRY,
//						UNKNOWN_LOCATION, PLACE_KEY_CITY,
//						[NSNumber numberWithDouble:currentLocation.coordinate.latitude], PLACE_KEY_LATITUDE,
//						[NSNumber numberWithDouble:currentLocation.coordinate.longitude], PLACE_KEY_LONGITUDE, nil];
//	}
//	//[currentLocation release];
//	[self removeProgressVeiw];
//	self.findedPlaces = [NSArray arrayWithObject:currentPlace];
//}
//
//- (void)reverseGeocoder:(MKReverseGeocoder *)geocoder didFailWithError:(NSError *)error {
//	[self removeProgressVeiw];
//	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:[error localizedDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
//	[alertView show];
//	[alertView release];
//
//	if ([self.delegate respondsToSelector:@selector(weatherController:endWithMessage:)]){
//		// TODO: [self.delegate weatherController:self endWithMessage:wpLocationUnknownError];
//	}
//}

@end
