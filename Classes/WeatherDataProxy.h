//
//  WeatherDataProxy.h
//  LifelikeClock2
//
//  Created by Vasyl Liutikov on 12.10.11.
//  Copyright 2011 Postindustria. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CustomWeatherConts.h"

#define kBluesky		@"bluesky"
#define kPartlycloudy	@"partlycloudy"
#define kCloudy			@"cloudy"
#define kRain			@"rain"
#define kSnow			@"snow"
#define kFog			@"fog"


#define kDay            @"day"
#define kSunChange		@"sunchage"
#define kNight			@"night"

@interface WeatherDataProxy : NSObject

+ (NSString*) weatherByPrecipDeskr:(NSString*)precipDeskr;
+ (NSString*) weatherBySkyDeskr:(NSString*)skyDeskr;
+ (NSString*) checkTimeOfDay:(NSDate*)currTime WithSunrise:(NSDate*)sunrise withSunset:(NSDate*)sunset;
+ (BOOL) checkIsDay:(NSDate*)currTime WithSunrise:(NSDate*)sunrise withSunset:(NSDate*)sunset;
+ (NSString*) getVideoForWeather:(NSString*)aWeather timeOfDay:(NSString*)aTimeOfDay;
+ (NSDate*) timeSkipDay:(NSDate*)aDay;
+ (NSDate*) sunriseFromData:(NSDictionary*)data;
+ (NSDate*) sunsetFromData:(NSDictionary*)data;

+(NSDate*)dataFromStr:(NSString*)aStr;
+(NSDate*)dataFromStrCurTime:(NSString *)aStr;
+(NSDate*)dataFromStrDays:(NSString*)aStr;
+(NSDate*)localDay:(NSString *)aStr;
+(NSDate*)fullLocalDate:(NSString *)aStr;
+(NSDate*)getDayFromUnixFormat:(NSString *)aStr;
+(NSUInteger)getDayOfWeek:(NSString*)aStr;

@end
