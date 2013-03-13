//
//  WWOProxyRequest.m
//  LifelikeClock2
//
//  Created by Dmitri Petrishin on 12/20/12.
//  Copyright (c) 2012 Postindustria. All rights reserved.
//

#import "TBXML.h"
#import "WWOProxy.h"
#import "NSString+HTML.h"
#import "WWOProxyRequest.h"
#import "WeatherDataProxy.h"
#import "CustomWeatherConts.h"
#import "CustomWeatherRequests.h"


#pragma mark - Private declarations

@interface WWOProxyRequest ()

@end


#pragma mark - Implementation

@implementation WWOProxyRequest

@synthesize data;
@synthesize state;
@synthesize type;
@synthesize requestError;
@synthesize longitude;
@synthesize latitude;

#pragma mark -

- (void)dealloc {
	self.data = nil;
	self.requestError = nil;
    self.delegate = nil;
}

#pragma mark - Private

- (void)handleByResponse:(id)response error:(NSError*)error
{
    if (nil == error) {
        [self requestFinished:response];
    } else {
        [self requestFailed:error];
    }
}

#pragma mark - Public

- (id)initWithDelegate:(id <WWOProxyRequestDelegate>)delegate
{
	if ((self = [super init])) {
		_delegate = delegate;
		state = prUnknown;
	}
	
	return self;
}

- (void)getWeather
{
    __weak __typeof(&*self)weakSelf = self;
    [CustomWeatherRequests weatherWithWWORequest:weakSelf completionBlock:^(id responseData, NSError *error) {
        [weakSelf handleByResponse:responseData error:error];
    }];
}

- (void)getWeatherDetailForecast
{
    __weak __typeof(&*self)weakSelf = self;
    [CustomWeatherRequests detailForecastWithWWORequest:weakSelf completionBlock:^(id responseData, NSError *error) {
        [weakSelf handleByResponse:responseData error:error];
    }];
}

- (void)getWeatherExtendedForecast
{
    __weak __typeof(&*self)weakSelf = self;
    [CustomWeatherRequests extendedForecastWithWWORequest:weakSelf completionBlock:^(id responseData, NSError *error) {
        [weakSelf handleByResponse:responseData error:error];
    }];
}

- (void)getWeatherAstronomyForecast
{
    __weak __typeof(&*self)weakSelf = self;
    [CustomWeatherRequests astronomyForecastWithWWORequest:weakSelf completionBlock:^(id responseData, NSError *error) {
        [weakSelf handleByResponse:responseData error:error];
    }];
}

- (void)searchCitiesByName:(NSString*)name
{
    __weak __typeof(&*self)weakSelf = self;
    self.search = [name stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    [CustomWeatherRequests cityWithWWORequest:weakSelf completionBlock:^(id responseData, NSError *error) {
        [weakSelf handleByResponse:responseData error:error];
    }];
}

#pragma mark - Parcing

- (NSArray*)parseCitiesFromXML:(TBXMLElement*)xmlRoot {
	if (xmlRoot == nil || ![[TBXML elementName:xmlRoot] isEqualToString:CW_CITYLIST_XML]) {
		return nil;
	}
	NSMutableArray *ret = [NSMutableArray array];
	TBXMLElement *city = xmlRoot->firstChild;
	NSNumberFormatter * f = [[NSNumberFormatter alloc] init];
	[f setNumberStyle:NSNumberFormatterDecimalStyle];
	while (city != nil) {
		NSString *timezoneName;
		timezoneName = [TBXML valueOfAttributeNamed:CW_CITY_XML_A_TIMEZONE_ID forElement:city];
		if (timezoneName == nil || [timezoneName isEqualToString:@""]) {
			timezoneName = [[NSTimeZone abbreviationDictionary] objectForKey:
							[TBXML valueOfAttributeNamed:CW_CITY_XML_A_TIMEZONE_CODE forElement:city]];
		}
		if (timezoneName == nil ||
			[[NSTimeZone knownTimeZoneNames] indexOfObjectIdenticalTo:timezoneName] == NSNotFound) {
			timezoneName = [[NSTimeZone defaultTimeZone] name];
		}
		NSString *city_id = [TBXML valueOfAttributeNamed:CW_CITY_XML_A_ID forElement:city];
		NSString *name = [[TBXML valueOfAttributeNamed:CW_CITY_XML_A_NAME forElement:city] stringByDecodingHTMLEntities];
		if ([name isEqualToString:@""]) {
			name = UNKNOWN_LOCATION;
		}
		NSString *country = [[TBXML valueOfAttributeNamed:CW_CITY_XML_A_COUNTRY_NAME forElement:city] stringByDecodingHTMLEntities];
		NSString *region = [[TBXML valueOfAttributeNamed:CW_CITY_XML_A_STATE_NAME forElement:city] stringByDecodingHTMLEntities];
		if ([region isEqualToString:@""]) {
			region = UNKNOWN_LOCATION;
		}
		NSNumber *aLongtitude = [NSNumber numberWithFloat:[[TBXML valueOfAttributeNamed:CW_CITY_XML_A_LONGTITUDE forElement:city] floatValue]];
		NSNumber *aLatitude = [NSNumber numberWithFloat:[[TBXML valueOfAttributeNamed:CW_CITY_XML_A_LATITUDE forElement:city] floatValue]];
		[ret addObject:[NSDictionary dictionaryWithObjectsAndKeys:
						city_id, PLACE_KEY_ID,
						[name stringByConvertingHTMLToPlainText], PLACE_KEY_CITY,
						[country stringByConvertingHTMLToPlainText], PLACE_KEY_COUNTRY,
						[region stringByConvertingHTMLToPlainText], PLACE_KEY_REGION,
						aLongtitude, PLACE_KEY_LONGITUDE,
						aLatitude, PLACE_KEY_LATITUDE,
						timezoneName, PLACE_KEY_TIMEZONE, nil]];
		city = [TBXML nextSiblingNamed:CW_CITY_XML searchFromElement:city];
	}
	
	return [NSArray arrayWithArray:ret];
}

- (NSDictionary*)parseCurrentConditionFromXML:(TBXMLElement*)xmlRoot {
	if (xmlRoot == nil || ![[TBXML elementName:xmlRoot] isEqualToString:CW_REPORT_XML]) {
		return nil;
	}
	NSMutableDictionary *ret = nil;
	TBXMLElement *observation = xmlRoot->firstChild;
	if (observation != nil && [[TBXML elementName:observation] isEqualToString:CW_OBSERVATION_XML]) {
		NSString *skyDesc = [TBXML valueOfAttributeNamed:CW_OBSERVATION_XML_A_SKY_DESC forElement:observation];
		NSString *precipDesc = [TBXML valueOfAttributeNamed:CW_OBSERVATION_XML_A_PRECIP_DESC forElement:observation];
		NSString *t = [TBXML valueOfAttributeNamed:CW_OBSERVATION_XML_A_TEMPERATURE forElement:observation];
		if (t == nil || [t isEqualToString:@""]) {
			return ret;
		}
		NSNumber *temperature = [NSNumber numberWithInt:round([t floatValue])];//[f numberFromString:tempra];
		NSNumber *temperatureF = [NSNumber numberWithInt:round(([t floatValue] * 1.8) + 32.0)];
		NSString *description = [[TBXML valueOfAttributeNamed:CW_OBSERVATION_XML_A_DESCRIPTION forElement:observation] stringByDecodingHTMLEntities];
		
		NSDictionary *images;
		if (![precipDesc isEqualToString:CW_ABSENT_DESCRIPTION] || [precipDesc isEqualToString:@"0"]) {
			images = [[[WWOProxy iconsMapping] objectForKey:PRECIP_DESCRIPTORS_KEY] objectForKey:precipDesc];
		} else if (![skyDesc isEqualToString:CW_ABSENT_DESCRIPTION] || [skyDesc isEqualToString:@"0"]) {
			images = [[[WWOProxy iconsMapping] objectForKey:SKY_DESCRIPTORS_KEY] objectForKey:skyDesc];
		} else {
			return ret;
		}
		
		ret = [NSMutableDictionary dictionaryWithDictionary:images];
		if (nil != description) {
			[ret setObject:description forKey:WEATHER_KEY_DESCRIPTION];
		}
		if (nil != temperature) {
			[ret setObject:temperature forKey:WEATHER_KEY_TEMP_C];
		}
		if (nil != temperatureF) {
			[ret setObject:temperatureF forKey:WEATHER_KEY_TEMP_F];
		}
		if (nil != skyDesc) {
			[ret setObject:skyDesc forKey:CW_OBSERVATION_XML_A_SKY_DESC];
		}
		if (nil != precipDesc) {
			[ret setObject:precipDesc forKey:CW_OBSERVATION_XML_A_PRECIP_DESC];
		}
	}
	return [NSDictionary dictionaryWithDictionary:ret];
}

- (NSDictionary*)parseAstronomyForecastFromXML:(TBXMLElement*)xmlRoot {
	if (xmlRoot == nil || ![[TBXML elementName:xmlRoot] isEqualToString:CW_REPORT_XML]) {
		return nil;
	}
	NSMutableDictionary *ret = nil;
	TBXMLElement *forecast = xmlRoot->firstChild;
	if (forecast != nil && [[TBXML elementName:forecast] isEqualToString:CW_FORECAST_XML]) {
		NSString *sunset = [TBXML valueOfAttributeNamed:CW_FORECAST_XML_A_SUNSET forElement:forecast];
		NSString *sunrise = [TBXML valueOfAttributeNamed:CW_FORECAST_XML_A_SUNRISE forElement:forecast];
        NSString *timezoneName=[TBXML valueOfAttributeNamed:@"tzinfo" forElement:xmlRoot];
        NSString *ltString = [[TBXML valueOfAttributeNamed:CW_REPORT_XML_A_LOCALTIME forElement:xmlRoot] substringToIndex:25];
        ltString = [ltString substringFromIndex:16];
        NSDate* localTime=[WeatherDataProxy dataFromStrCurTime:ltString];
        
        if (timezoneName == nil) {
			timezoneName = [[NSTimeZone defaultTimeZone] name];
		}
        if (localTime==nil) {
            localTime=[NSDate date];
        }
		ret = [NSDictionary dictionaryWithObjectsAndKeys:
			   sunset, WEATHER_KEY_SUNSET,
			   sunrise, WEATHER_KEY_SUNRISE,timezoneName,PLACE_KEY_TIMEZONE,localTime,CW_REPORT_XML_A_LOCALTIME,nil];
	}
	
	return ret;
}
-(NSArray*)addNowDay:(NSArray*)otherDays{
    NSDictionary *currWeather = [self.data objectForKey:WEATHER_KEY_CURRENT_CONDITION];
    NSMutableDictionary* forecastForToday=[NSMutableDictionary dictionaryWithDictionary:[otherDays objectAtIndex:0]];
    
    if (currWeather!=nil) {
        if ([[forecastForToday objectForKey:WEATHER_KEY_WEEKDAY] isEqualToString:NSLocalizedString(@"Today", @"Today")]) {
            NSString *iconName=[currWeather objectForKey:WEATHER_KEY_DAY_ICON];
            if (nil !=iconName) {
                [forecastForToday setObject:iconName forKey:WEATHER_KEY_DAY_ICON];
            }
            /// refa
            NSString* weather = kBluesky;
            NSString* desc = [currWeather objectForKey:CW_OBSERVATION_XML_A_PRECIP_DESC];
            NSString* descSky = [currWeather objectForKey:CW_OBSERVATION_XML_A_SKY_DESC];
            
            if (![desc isEqualToString:CW_ABSENT_DESCRIPTION] || [desc isEqualToString:@"0"]) {
                weather = [WeatherDataProxy weatherByPrecipDeskr:desc];
            } else if (![descSky isEqualToString:CW_ABSENT_DESCRIPTION] || [descSky isEqualToString:@"0"]) {
                weather = [WeatherDataProxy weatherBySkyDeskr:descSky];
            }
            if (nil == weather) {
                weather = kBluesky;
            }
            NSDictionary* astronomy = [self.data objectForKey:WEATHER_KEY_ASTRONOMY];
            NSString* timeOfDay=kDay;
            
            if (nil!=astronomy) {
                NSDate *localTime=[astronomy objectForKey:CW_REPORT_XML_A_LOCALTIME];
                NSDate* sunset = [WeatherDataProxy sunsetFromData:astronomy];
                NSDate* sunrise = [WeatherDataProxy sunriseFromData:astronomy];
                timeOfDay=[WeatherDataProxy checkTimeOfDay:localTime WithSunrise:sunrise withSunset:sunset];
                if (![WeatherDataProxy checkIsDay:localTime WithSunrise:sunrise withSunset:sunset]) {
                    iconName=[currWeather objectForKey:WEATHER_KEY_NIGHT_ICON];
                }
                
            }
            if (nil !=iconName) {
                [forecastForToday setObject:iconName forKey:WEATHER_KEY_DAY_ICON];
            }
            NSNumber *highTemp =[currWeather objectForKey:WEATHER_KEY_TEMP_C];
            NSNumber *highTempF = [currWeather objectForKey:WEATHER_KEY_TEMP_F];
            
            if (nil != highTemp) {
                [forecastForToday setObject:highTemp forKey:WEATHER_KEY_TEMP_MAX];
            }
            if (nil != highTempF) {
                [forecastForToday setObject:highTempF forKey:WEATHER_KEY_TEMP_MAX_F];
            }
            NSString* filename=[WeatherDataProxy getVideoForWeather:weather timeOfDay:timeOfDay];
            
            [forecastForToday setObject:filename forKey:WEATHER_KEY_VIDEO_FILE];
            [forecastForToday setObject:[NSNumber numberWithBool:NO] forKey:WEATHER_KEY_FAKE_TODAY];
            
            //ref
            NSMutableArray *newArray=[NSMutableArray arrayWithArray:otherDays];
            //[otherDays objectAtIndex:0]=forecastForToday;
            [newArray replaceObjectAtIndex:0 withObject:forecastForToday];
            return newArray;
        } else {
            NSMutableDictionary* dayForcast=[NSMutableDictionary dictionary];
            NSString *weekday = NSLocalizedString(@"Today", @"Today");
            
            NSString* weather = kBluesky;
            
            NSString* desc = [currWeather objectForKey:CW_OBSERVATION_XML_A_PRECIP_DESC];
            NSString* descSky = [currWeather objectForKey:CW_OBSERVATION_XML_A_SKY_DESC];
            
            if (![desc isEqualToString:CW_ABSENT_DESCRIPTION] || [desc isEqualToString:@"0"]) {
                weather = [WeatherDataProxy weatherByPrecipDeskr:desc];
            } else if (![descSky isEqualToString:CW_ABSENT_DESCRIPTION] || [descSky isEqualToString:@"0"]) {
                weather = [WeatherDataProxy weatherBySkyDeskr:descSky];
            }
            if (nil == weather) {
                weather = kBluesky;
            }
            NSDictionary* astronomy = [self.data objectForKey:WEATHER_KEY_ASTRONOMY];
            NSString* timeOfDay=kDay;
            NSString *iconName=[currWeather objectForKey:WEATHER_KEY_DAY_ICON];
            if (nil!=astronomy) {
                NSDate *localTime=[astronomy objectForKey:CW_REPORT_XML_A_LOCALTIME];
                NSDate* sunset = [WeatherDataProxy sunsetFromData:astronomy];
                NSDate* sunrise = [WeatherDataProxy sunriseFromData:astronomy];
                timeOfDay=[WeatherDataProxy checkTimeOfDay:localTime WithSunrise:sunrise withSunset:sunset];
                if (![WeatherDataProxy checkIsDay:localTime WithSunrise:sunrise withSunset:sunset]) {
                    iconName=[currWeather objectForKey:WEATHER_KEY_NIGHT_ICON];
                }
                
            }
            NSNumber *highTemp =[currWeather objectForKey:WEATHER_KEY_TEMP_C];
            NSNumber *highTempF = [currWeather objectForKey:WEATHER_KEY_TEMP_F];
            
            if (nil != highTemp) {
                [dayForcast setObject:highTemp forKey:WEATHER_KEY_TEMP_MAX];
            }
            if (nil != highTempF) {
                [dayForcast setObject:highTempF forKey:WEATHER_KEY_TEMP_MAX_F];
            }
            NSString* filename=[WeatherDataProxy getVideoForWeather:weather timeOfDay:timeOfDay];
            
            if (nil !=iconName) {
                [dayForcast setObject:iconName forKey:WEATHER_KEY_DAY_ICON];
            }
            [dayForcast setObject:filename forKey:WEATHER_KEY_VIDEO_FILE];
            
            
            if (nil != weekday) {
                [dayForcast setObject:weekday forKey:WEATHER_KEY_WEEKDAY];
            }
            [dayForcast setObject:[NSNumber numberWithBool:YES] forKey:WEATHER_KEY_FAKE_TODAY];
            
            NSArray *nowDay=[NSArray arrayWithObject:dayForcast];
            return [nowDay arrayByAddingObjectsFromArray:otherDays];
        }
    } else {
        return otherDays;
    }
}
- (NSArray*)parseExtendedForecastFromXML:(TBXMLElement*)xmlRoot {
	if (xmlRoot == nil || ![[TBXML elementName:xmlRoot] isEqualToString:CW_REPORT_XML]) {
		return nil;
	}
    NSString *ltString = [[TBXML valueOfAttributeNamed:CW_REPORT_XML_A_LOCALTIME forElement:xmlRoot] substringToIndex:25];
    // ltString = [ltString substringFromIndex:16];
    NSDate* localTime=[WeatherDataProxy localDay:ltString];
    
	NSCalendar *cal = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    
    
	NSMutableArray *ret = [NSMutableArray array];
	TBXMLElement *location = [TBXML childElementNamed:CW_LOCATION_XML parentElement:xmlRoot];
	TBXMLElement *forecast = [TBXML childElementNamed:CW_FORECAST_XML parentElement:location];
    while (forecast != nil) {
		NSMutableDictionary *dayForcast;
		
		NSString *d = [TBXML valueOfAttributeNamed:CW_FORECAST_XML_A_ISO8601 forElement:forecast];
		d = [d substringToIndex:10];
		NSDate *date = [WeatherDataProxy getDayFromUnixFormat:d];
		NSString *weekday;
		NSString *skyDesc = [TBXML valueOfAttributeNamed:CW_FORECAST_XML_A_SKY_DESC forElement:forecast];
		int daysFromLocalTime = [[cal components:NSDayCalendarUnit fromDate:localTime toDate:date options:0] day];
		if (daysFromLocalTime == 0) {
			weekday = NSLocalizedString(@"Today", @"Today");
		} else if (daysFromLocalTime == 1) {
			weekday = NSLocalizedString(@"Tomorrow", @"Tomorrow");
		} else {
            NSString* localizing = [[TBXML valueOfAttributeNamed:CW_FORECAST_XML_A_WEEKDAY forElement:forecast] stringByDecodingHTMLEntities];
			weekday = NSLocalizedString(localizing, localizing);
		}
        
		NSString *precipDesc = [TBXML valueOfAttributeNamed:CW_FORECAST_XML_A_PRECIP_DESC forElement:forecast];
		NSString *h = [TBXML valueOfAttributeNamed:CW_FORECAST_XML_A_HIGH_TEMP forElement:forecast];
		NSString *l = [TBXML valueOfAttributeNamed:CW_FORECAST_XML_A_LOW_TEMP forElement:forecast];
		NSNumber *highTemp = [NSNumber numberWithInt:round([h floatValue])];//[f numberFromString:tempra];
		NSNumber *lowTemp = [NSNumber numberWithInt:round([l floatValue])];//[f numberFromString:tempra];
		NSNumber *highTempF = [NSNumber numberWithInt:round(([h floatValue] * 1.8) + 32.0)];
		NSNumber *lowTempF = [NSNumber numberWithInt:round(([l floatValue] * 1.8) + 32.0)];
		NSString *description = [[TBXML valueOfAttributeNamed:CW_OBSERVATION_XML_A_DESCRIPTION forElement:forecast] stringByDecodingHTMLEntities];
		
		NSDictionary *images;
		if (![precipDesc isEqualToString:CW_ABSENT_DESCRIPTION]) {
			images = [[[WWOProxy iconsMapping] objectForKey:PRECIP_DESCRIPTORS_KEY] objectForKey:precipDesc];
		} else if (![skyDesc isEqualToString:CW_ABSENT_DESCRIPTION]) {
			images = [[[WWOProxy iconsMapping] objectForKey:SKY_DESCRIPTORS_KEY] objectForKey:skyDesc];
		} else {
			images = [[WWOProxy iconsMapping] objectForKey:DEFAULT_DESCRIPTORS_KEY];
		}
        NSString* weather = kBluesky;
        if (![precipDesc isEqualToString:CW_ABSENT_DESCRIPTION] || [precipDesc isEqualToString:@"0"]) {
            weather = [WeatherDataProxy weatherByPrecipDeskr:precipDesc];
        } else if (![skyDesc isEqualToString:CW_ABSENT_DESCRIPTION] || [skyDesc isEqualToString:@"0"]) {
            weather = [WeatherDataProxy weatherBySkyDeskr:skyDesc];
        }
        if (nil == weather) {
            weather = kBluesky;
        }
		dayForcast = [NSMutableDictionary dictionaryWithDictionary:images];
        NSString* filename=[WeatherDataProxy getVideoForWeather:weather timeOfDay:kDay];
        if (nil!=filename) {
            [dayForcast setObject:filename forKey:WEATHER_KEY_VIDEO_FILE];
        }
		if (nil != date) {
			[dayForcast setObject:date forKey:WEATHER_KEY_DATE];
		}
		if (nil != description) {
			[dayForcast setObject:description forKey:WEATHER_KEY_DESCRIPTION];
		}
		if (nil != lowTemp) {
			[dayForcast setObject:lowTemp forKey:WEATHER_KEY_TEMP_MIN];
		}
		if (nil != highTemp) {
			[dayForcast setObject:highTemp forKey:WEATHER_KEY_TEMP_MAX];
		}
		if (nil != lowTempF) {
			[dayForcast setObject:lowTempF forKey:WEATHER_KEY_TEMP_MIN_F];
		}
		if (nil != highTempF) {
			[dayForcast setObject:highTempF forKey:WEATHER_KEY_TEMP_MAX_F];
		}
		if (nil != weekday) {
			[dayForcast setObject:weekday forKey:WEATHER_KEY_WEEKDAY];
		}
		[ret addObject:[NSDictionary dictionaryWithDictionary:dayForcast]];
		forecast = [TBXML nextSiblingNamed:CW_FORECAST_XML searchFromElement:forecast];
	}
	
	return [NSArray arrayWithArray:ret];
}

- (NSArray*)parseDetailedForecastFromXML:(TBXMLElement*)xmlRoot {
	if (xmlRoot == nil || ![[TBXML elementName:xmlRoot] isEqualToString:CW_REPORT_XML]) {
		return [NSArray array];
	}
	
	NSMutableArray *ret = [NSMutableArray array];
    NSString *ltString = [[TBXML valueOfAttributeNamed:CW_REPORT_XML_A_LOCALTIME forElement:xmlRoot] substringToIndex:3];
    
    NSUInteger dayOfWeek=[WeatherDataProxy getDayOfWeek:ltString];
    //    NSDictionary *todayForecast=[[self.data objectForKey:WEATHER_KEY_EXTENDED_CONDITION] objectAtIndex:0]; //первый день в прогнозе
    //    if (![[todayForecast objectForKey:WEATHER_KEY_FAKE_TODAY] boolValue]) {
    //        dayOfWeek++;
    //    }
	NSString *startDayOfWeek = [NSString stringWithFormat:@"%i", dayOfWeek];
	DLog(@"day name %@ number %d", ltString,dayOfWeek);
    //WEATHER_KEY_EXTENDED_CONDITION
	TBXMLElement *location = [TBXML childElementNamed:CW_LOCATION_XML parentElement:xmlRoot];
	TBXMLElement *forecast = [TBXML childElementNamed:CW_FORECAST_XML parentElement:location];
	NSString *currentDayOfWeek = @"";
	NSMutableArray *dayHourlyFeed;
	while (forecast != nil) {
		NSMutableDictionary *dayForcast;
		NSString *skyDesc = [TBXML valueOfAttributeNamed:CW_FORECAST_XML_A_SKY_DESC forElement:forecast];
		NSString *weekday = [[TBXML valueOfAttributeNamed:CW_FORECAST_XML_A_WEEKDAY forElement:forecast] stringByDecodingHTMLEntities];
		NSString *precipDesc = [TBXML valueOfAttributeNamed:CW_FORECAST_XML_A_PRECIP_DESC forElement:forecast];
		NSString *t = [TBXML valueOfAttributeNamed:CW_FORECAST_XML_A_TEMPERATURE forElement:forecast];
		NSNumber *temperature = [NSNumber numberWithInt:round([t floatValue])];
		NSNumber *temperatureF = [NSNumber numberWithInt:round(([t floatValue] * 1.8) + 32.0)];
		NSString *description = [[TBXML valueOfAttributeNamed:CW_FORECAST_XML_A_DESCRIPTION forElement:forecast] stringByDecodingHTMLEntities];
		NSString *d = [TBXML valueOfAttributeNamed:CW_FORECAST_XML_A_DAY_OF_WEEK forElement:forecast];
		NSNumber *dayOfWeek = [NSNumber numberWithInt:[d intValue]];
		NSString *daySegment = [[TBXML valueOfAttributeNamed:CW_FORECAST_XML_A_DAY_SEGMENT forElement:forecast] stringByDecodingHTMLEntities];
		NSString *segment = [[TBXML valueOfAttributeNamed:CW_FORECAST_XML_A_SEGMENT forElement:forecast] stringByDecodingHTMLEntities];
		NSDictionary *images;
		if (![precipDesc isEqualToString:CW_ABSENT_DESCRIPTION]) {
			images = [[[WWOProxy iconsMapping] objectForKey:PRECIP_DESCRIPTORS_KEY] objectForKey:precipDesc];
		} else if (![skyDesc isEqualToString:CW_ABSENT_DESCRIPTION]) {
			images = [[[WWOProxy iconsMapping] objectForKey:SKY_DESCRIPTORS_KEY] objectForKey:skyDesc];
		} else {
			images = [[WWOProxy iconsMapping] objectForKey:DEFAULT_DESCRIPTORS_KEY];
			forecast = [TBXML nextSiblingNamed:CW_FORECAST_XML searchFromElement:forecast];
			//continue;
		}
		dayForcast = [NSMutableDictionary dictionaryWithDictionary:images];
		if (nil != description) {
			[dayForcast setObject:description forKey:WEATHER_KEY_DESCRIPTION];
		}
		if (nil != temperature) {
			[dayForcast setObject:temperature forKey:WEATHER_KEY_TEMP_C];
		}
		if (nil != temperatureF) {
			[dayForcast setObject:temperatureF forKey:WEATHER_KEY_TEMP_F];
		}
		if (nil != weekday) {
			[dayForcast setObject:weekday forKey:WEATHER_KEY_WEEKDAY];
		}
		if (nil != dayOfWeek) {
			[dayForcast setObject:dayOfWeek forKey:WEATHER_KEY_DAY_OF_WEEK];
		}
		if (nil != daySegment) {
			[dayForcast setObject:NSLocalizedString(daySegment, daySegment) forKey:WEATHER_KEY_DAY_SEGMENT];
		}
		if (nil != segment) {
			[dayForcast setObject:segment forKey:WEATHER_KEY_SEGMENT];
		}
		
		if ([d intValue] >= [startDayOfWeek intValue]) {
			if (![currentDayOfWeek isEqualToString:weekday]) {
				dayHourlyFeed = [NSMutableArray array];
				[ret addObject:dayHourlyFeed];
			}
			
			currentDayOfWeek = weekday;
			
			[dayHourlyFeed addObject:[NSDictionary dictionaryWithDictionary:dayForcast]];
		}
		
		forecast = [TBXML nextSiblingNamed:CW_FORECAST_XML searchFromElement:forecast];
	}
	
	return [NSArray arrayWithArray:ret];
}

- (void)parseWeatherWithResponseString:(NSString *)responseString
{
    TBXML *xml = [TBXML tbxmlWithXMLString:responseString];
	NSError *error = nil;
	id res = nil;
	
	switch (self.type) {
		case prCitiesRequest:
			res = [self parseCitiesFromXML:xml.rootXMLElement];
			state = prCompleted;
			break;
		case prWeatherByLocRequest:
		{
			switch (self.state) {
				case prUnknown:
					res = [self parseCurrentConditionFromXML:xml.rootXMLElement];
					state = prWeatherCurrentConditionComplete;
					if (res == nil) {
						break;
					}
					if (data == nil) {
						self.data = [NSMutableDictionary dictionary];
					}
					[data setObject:res forKey:WEATHER_KEY_CURRENT_CONDITION];
					res = data;
					break;
				case prWeatherCurrentConditionComplete:
					res = [self parseAstronomyForecastFromXML:xml.rootXMLElement];
					if (res == nil) {
						break;
					}
					if (data == nil) {
						self.data = [NSMutableDictionary dictionary];
					}
					[data setObject:res forKey:WEATHER_KEY_ASTRONOMY];
					res = data;
					state = prWeatherAstronomyForcastComplete;
					break;
				case prWeatherAstronomyForcastComplete:
					res = [self addNowDay:[self parseExtendedForecastFromXML:xml.rootXMLElement ]];
					if (res == nil) {
						break;
					}
					if (data == nil) {
						self.data = [NSMutableDictionary dictionary];
					}
					[data setObject:res forKey:WEATHER_KEY_EXTENDED_CONDITION];
					res = data;
					state = prWeatherExtendedForcastComplete;
					break;
				case prWeatherExtendedForcastComplete:
					res = [self parseDetailedForecastFromXML:xml.rootXMLElement];
					if (res == nil) {
						break;
					}
					if (data == nil) {
						self.data = [NSMutableDictionary dictionary];
					}
					[data setObject:res forKey:WEATHER_KEY_DETAILED_FORECAST];
					if ([data objectForKey:WEATHER_KEY_CURRENT_CONDITION] == nil) {
						if ([res count] > 0) {
							[data setObject:SAFE_VALUE([[res objectAtIndex:0] objectAtIndex:0]) forKey:WEATHER_KEY_CURRENT_CONDITION];
						} else {
							[data setObject:SAFE_VALUE([[WWOProxy iconsMapping] objectForKey:DEFAULT_DESCRIPTORS_KEY]) forKey:WEATHER_KEY_CURRENT_CONDITION];
						}
                        
					}
					res = data;
					state = prCompleted;
					break;
				default:
					state = prUnknown;
					break;
			}
		}
			break;
		default:
			break;
	}
	
	if (self.state != prUnknown) {
		self.data = res;
	} else {
		self.requestError = error;
		state = prError;
	}
    
	SAFE_CALL(self.delegate, @selector(didCompleteWWORequest:), self);
}

#pragma mark -

- (void)requestFinished:(id)request {
	NSString *responseString = @"";
    if ([request isKindOfClass:[NSData class]]) {
        responseString = [[NSString alloc] initWithData:request encoding:NSUTF8StringEncoding];
    }
    [self parseWeatherWithResponseString:responseString];
}

- (void)requestFailed:(NSError*)error {
	self.requestError = error;
	state = prError;
	
	SAFE_CALL(self.delegate, @selector(didCompleteWWORequest:), self);
}

@end
