//
//  WWOProxy.m
//  WeatherClock
//
//  Created by Igor Fedorov on 7/11/10.
//  Copyright 2010 Flash/Flex, iPhone developer at Postindustria. All rights reserved.
//

#import "WWOProxy.h"
#import "WWOProxyRequest.h"

#import "CustomWeatherConts.h"

@interface WWOProxy () <WWOProxyRequestDelegate>
	
@property (nonatomic, retain) NSString *language;
@property (nonatomic, readonly) NSDictionary *iconsMapping;
@property (nonatomic, retain) NSMutableArray *activeRequests;

@end



@interface WWOProxy(Private)

+ (WWOProxy *)sharedProxy;

- (void)addRequest:(WWOProxyRequest*)newRequest;

- (void)removeRequest:(WWOProxyRequest*)oldRequest;

//
// Rise when request completed
//
- (void)requestCompleted:(WWOProxyRequest*)aRequest;

- (void)requestWeatherDataWithLatitude:(float)aLatitude longitude:(float)aLongitude;

- (void)requestCitiesByQuery:(NSString*)queryString;

- (void)requestWeatherDetailForcastWithDelegate:(WWOProxyRequest*)requestDelegate;

- (void)requestWeatherExtededForcastWithDelegate:(WWOProxyRequest*)requestDelegate;

- (void)requestWeatherAstronomyForcastWithDelegate:(WWOProxyRequest*)requestDelegate;

@end

@implementation WWOProxy(Private)

static WWOProxy* sharedProxy;

+ (WWOProxy *)sharedProxy {
	@synchronized(self) {
		if (!sharedProxy) {
			sharedProxy = [[self alloc] init];
		}
	}
	return sharedProxy;
}

- (BOOL)isExistRequestByType:(WWOProxyRequestType)requestType
{
    BOOL isExist = NO;
	for (WWOProxyRequest* req in self.activeRequests) {
		if (req.type == requestType) {
            isExist = YES;
			break;
		}
	}
    return isExist;
}

- (void)addRequest:(WWOProxyRequest*)newRequest {
    BOOL isRequestExist = [self isExistRequestByType:newRequest.type];
    if (!isRequestExist) {
        [self.activeRequests addObject:newRequest];
    }
}

- (void)removeRequest:(WWOProxyRequest*)oldRequest {
	[self.activeRequests removeObject:oldRequest];
}

- (void)requestCompleted:(WWOProxyRequest*)aRequest {
	if (aRequest.state == prCompleted) {
		switch (aRequest.type) {
			case prCitiesRequest:
			{
				NSArray *result = (NSArray*)aRequest.data;
				
				if ([self.delegate respondsToSelector:@selector(weatherProxy:findedCities:)]) {
					[self.delegate weatherProxy:self findedCities:result];
				}
			}
				break;
			case prWeatherByLocRequest:
			case prWeatherByCityRequest:
				if ([self.delegate respondsToSelector:@selector(weatherProxy:transferedData:)]) {
					NSDictionary *result = (NSDictionary*)aRequest.data;
					[self.delegate weatherProxy:self transferedData:result];
				}
				break;
			default:
				break;
		}
        [self removeRequest:aRequest];
		
	} else if (aRequest.state != prError && aRequest.type == prWeatherByLocRequest) {
		switch (aRequest.state) {
			case prWeatherCurrentConditionComplete:
				[self requestWeatherAstronomyForcastWithDelegate:aRequest];
				break;
			case prWeatherAstronomyForcastComplete:
				[self requestWeatherExtededForcastWithDelegate:aRequest];
				break;
			case prWeatherExtendedForcastComplete:
				[self requestWeatherDetailForcastWithDelegate:aRequest];
				break;
			default:
				break;
		}
	} else {
		switch (aRequest.type) {
			case prCitiesRequest:
				if ([self.delegate respondsToSelector:@selector(citySearchServiceReturnError:)]) {
					[self.delegate citySearchServiceReturnError:aRequest.requestError];
				}
				break;
			case prWeatherByLocRequest:
			case prWeatherByCityRequest:
				if ([self.delegate respondsToSelector:@selector(weatherServiceReturnError:)]) {
					[self.delegate weatherServiceReturnError:aRequest.requestError];
				}
				break;
			default:
				break;
		}
		
		[self removeRequest:aRequest];
	}
	
}

- (void)requestWeatherAstronomyForcastWithDelegate:(WWOProxyRequest*)requestDelegate {
	
    [requestDelegate getWeatherAstronomyForecast];
}

- (void)requestWeatherDetailForcastWithDelegate:(WWOProxyRequest*)requestDelegate {
	
    [requestDelegate getWeatherDetailForecast];
}

- (void)requestWeatherExtededForcastWithDelegate:(WWOProxyRequest*)requestDelegate {
	
    [requestDelegate getWeatherExtendedForecast];
}

- (void)requestWeatherDataWithLatitude:(float)aLatitude longitude:(float)aLongitude {
    WWOProxyRequestType type = prWeatherByLocRequest;
    BOOL isRequestExist = [self isExistRequestByType:type];
    if (!isRequestExist) {
        WWOProxyRequest *requestDelegate = [[WWOProxyRequest alloc] initWithDelegate:self];
        requestDelegate.type = type;
        requestDelegate.longitude = aLongitude;
        requestDelegate.latitude = aLatitude;
        requestDelegate.language = self.language;
        [self addRequest:requestDelegate];
        [requestDelegate getWeather];
    }
}

- (void)requestCitiesByQuery:(NSString*)queryString {
    WWOProxyRequestType type = prCitiesRequest;
    BOOL isRequestExist = [self isExistRequestByType:type];
    if (!isRequestExist) {
        WWOProxyRequest *requestDelegate = [[WWOProxyRequest alloc] initWithDelegate:self];
        requestDelegate.type = type;
        requestDelegate.language = self.language;
        [self addRequest:requestDelegate];
        [requestDelegate searchCitiesByName:queryString];
    }
}

@end


@implementation WWOProxy

@synthesize delegate;
@synthesize language;
@synthesize iconsMapping;

#pragma mark -
#pragma mark WWOProxy memory usage methods

+ (id)alloc {
	@synchronized(self) {
		NSAssert(sharedProxy == nil, @"Attempted to allocate a second instance of a singleton.");
		return [super alloc];
	}
	return nil;
}

+(void)end {
	sharedProxy = nil;
}

#pragma mark -
#pragma mark WWOProxy public static methods

+ (NSDictionary*)iconsMapping {
	return [[WWOProxy sharedProxy] iconsMapping];
}

+ (void)requestWeatherDataWithCity:(NSString*)aCity andCountry:(NSString*)aCountry {
}

+ (void)requestWeatherDataWithLatitude:(float)aLatitude longitude:(float)aLongitude; {
	[[WWOProxy sharedProxy] requestWeatherDataWithLatitude:aLatitude longitude:aLongitude];
}

+ (void)requestCitiesByQuery:(NSString*)queryString {
	[[WWOProxy sharedProxy] requestCitiesByQuery:queryString];
}

+ (void)setDelegate:(id<WWOProxyDelegate>)aDelegate {
	[[WWOProxy sharedProxy] setDelegate:aDelegate];
}

#pragma mark -
#pragma mark WWOProxy public methods

- (id)init {
	
	if ((self = [super init])) {
		NSArray *prefLoc = [NSBundle preferredLocalizationsFromArray:[[NSBundle mainBundle] localizations]];
		self.language = [[prefLoc objectAtIndex:0] lowercaseString];
		NSString *plistPath = [[NSBundle mainBundle] pathForResource:ICONS_MAPPING_FILE ofType:@"plist"];
		iconsMapping = [[NSDictionary alloc] initWithContentsOfFile:plistPath];
	}
	
	return self;
}

- (void)dealloc {
	self.language = nil;
	while ([[self activeRequests] count] > 0) {
		[sharedProxy removeRequest:[self.activeRequests objectAtIndex:0]];
	}
	if (self.activeRequests != nil) {
		_activeRequests = nil;
	}
	iconsMapping = nil;
}

- (NSMutableArray*)activeRequests {
	if (_activeRequests == nil) {
		_activeRequests = [[NSMutableArray alloc] init];
	}
	return _activeRequests;
}


#pragma mark - WWOProxyRequestDelegate

- (void)didCompleteWWORequest:(WWOProxyRequest *)wwoRequest
{
    [self requestCompleted:wwoRequest];
}

@end
