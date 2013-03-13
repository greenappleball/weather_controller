//
//  DateProxy.m
//  FlickrClock
//
//  Created by Dmitri Petrishin on 12/14/10.
//  Copyright 2010 Postindustria. All rights reserved.
//

#import "WeatherDataProxy.h"

#define FORMAT_DAY_WEATHER	@"%@_%@"

@implementation WeatherDataProxy

#pragma mark -
#pragma mark Private
+(NSDate*)dataFromStrDays:(NSString*)aStr{
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
	NSLocale *prefLoc = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
	[formatter setDateFormat:ISO8601_UNIX_FORMAT];
    [formatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
	[formatter setLocale:prefLoc];
	[prefLoc release];
	
	
	NSDate* sunriseDate = [formatter dateFromString:aStr];
	
	[formatter release];
	return sunriseDate;
}
+(NSDate*)dataFromStrCurTime:(NSString *)aStr{
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
	NSLocale *prefLoc = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
	[formatter setDateFormat:@"HH:mm:ss"];
    [formatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
	[formatter setLocale:prefLoc];
	[prefLoc release];
	
	
	NSDate* sunriseDate = [formatter dateFromString:aStr];
	
	[formatter release];
	return sunriseDate;
}
+(NSDate*)localDay:(NSString *)aStr{
    aStr=[aStr substringToIndex:16];
    aStr=[aStr substringFromIndex:5];
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
	NSLocale *prefLoc = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
	[formatter setDateFormat:@"dd MMM yyyy"];
    [formatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
	[formatter setLocale:prefLoc];
	[prefLoc release];
	
	
	NSDate* sunriseDate = [formatter dateFromString:aStr];
	
	[formatter release];
	return sunriseDate;
}
+(NSDate*)getDayFromUnixFormat:(NSString *)aStr{
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
	NSLocale *prefLoc = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
	[formatter setDateFormat:ISO8601_UNIX_FORMAT];
    [formatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
	[formatter setLocale:prefLoc];
	[prefLoc release];
	
	
	NSDate* sunriseDate = [formatter dateFromString:aStr];
	
	[formatter release];
	return sunriseDate;
}
+(NSDate*)fullLocalDate:(NSString *)aStr{
    aStr=[aStr substringToIndex:25];
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
	NSLocale *prefLoc = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
	[formatter setDateFormat:@"EEE, dd MMM yyyy HH:mm:ss"];
    [formatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
	[formatter setLocale:prefLoc];
	[prefLoc release];
	
	
	NSDate* sunriseDate = [formatter dateFromString:aStr];
	
	[formatter release];
	return sunriseDate;
}
+(NSDate*)dataFromStr:(NSString*)aStr{

    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
	NSLocale *prefLoc = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
	[formatter setDateFormat:@"h:mma"];
    [formatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
	[formatter setLocale:prefLoc];
	[prefLoc release];
	
	
	NSDate* sunriseDate = [formatter dateFromString:aStr];
	
	[formatter release];
	return sunriseDate;
}
+(NSUInteger)getDayOfWeek:(NSString*)aStr{
    NSArray *days=[NSArray arrayWithObjects:@"Sun",@"Mon",@"Tue",@"Wed",@"Thu",@"Fri",@"Sat",nil];
    NSUInteger result=0;
    for (NSString* day in days) {
        if ([day isEqualToString:aStr]) {
            result=[days indexOfObject:day];
        }
    }
    return result+1;
}
+ (NSDate*) timeSkipDay:(NSDate*)aDay {
    ///
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
	NSLocale *prefLoc = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    [formatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
	[formatter setDateFormat:@"h:mma"];
	[formatter setLocale:prefLoc];
	[prefLoc release];
	
	NSString* now = [formatter stringFromDate:aDay]; 
	NSDate* nowDate = [formatter dateFromString:now];
	
	[formatter release];
    return nowDate;

}





#pragma mark -
#pragma mark Public
+ (NSString*) checkTimeOfDay:(NSDate*)currTime WithSunrise:(NSDate*)sunrise withSunset:(NSDate*)sunset {
    //отбрасываем даты во всех входящих значениях - нам надо только время
    currTime=[self timeSkipDay:currTime];
    sunrise=[self timeSkipDay:sunrise];
    sunset=[self timeSkipDay:sunset];

	NSString* result = kNight;
	NSInteger oneHour = 3600;
	NSDate* leftCheck;
	NSDate* rightCheck;
	
	BOOL isOk;
	//	sunrise(от SR-20m до SR+20m), 
	leftCheck = [sunrise dateByAddingTimeInterval:(-1)*oneHour/2];
	rightCheck = [sunrise dateByAddingTimeInterval:1*oneHour/2];
	isOk = (NSOrderedSame == [currTime compare:leftCheck] || (NSOrderedDescending == [currTime compare:leftCheck] &&
                                                              NSOrderedAscending == [currTime compare:rightCheck]));
	if (isOk) {
		result = kSunChange;
        return result;
	}
    
	//	sunset(SS-20h — SS+20m), 
	leftCheck = [sunset dateByAddingTimeInterval:(-1)*oneHour/2];
	rightCheck = [sunset dateByAddingTimeInterval:oneHour/2];
	isOk = (NSOrderedSame == [currTime compare:leftCheck] || (NSOrderedDescending == [currTime compare:leftCheck] &&
                                                              NSOrderedAscending == [currTime compare:rightCheck]));
	if (isOk) {
		result = kSunChange;
        return result;
	}
	//	day(SR — SS), 
	leftCheck = sunrise;
	rightCheck = sunset;
	isOk = (NSOrderedSame == [currTime compare:leftCheck] || (NSOrderedDescending == [currTime compare:leftCheck] &&
                                                              NSOrderedAscending == [currTime compare:rightCheck]));
	if (isOk) {
		result = kDay;
	}
	//	night (SS — SR)
	return result;
}
+ (BOOL) checkIsDay:(NSDate*)currTime WithSunrise:(NSDate*)sunrise withSunset:(NSDate*)sunset{
	//	day(SR — SS), 
    currTime=[self timeSkipDay:currTime];
    sunrise=[self timeSkipDay:sunrise];
    sunset=[self timeSkipDay:sunset];
	BOOL isOk = (NSOrderedSame == [currTime compare:sunrise] || (NSOrderedDescending == [currTime compare:sunrise] &&
                                                              NSOrderedAscending == [currTime compare:sunset]));

	return isOk;

}
+ (NSDate*) sunriseFromData:(NSDictionary*)data {
	NSDateFormatter* formatter = [[[NSDateFormatter alloc] init] autorelease];
	NSLocale *prefLoc = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
	[formatter setDateFormat:@"h:mma"];
    //[formatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
	[formatter setLocale:prefLoc];
	[prefLoc release];
	
	NSString* sunrise = [data objectForKey:WEATHER_KEY_SUNRISE];
     return  [self dataFromStr:sunrise];
    NSString* timezoneStr=[data objectForKey:PLACE_KEY_TIMEZONE];
    NSTimeZone *timeZone=[NSTimeZone timeZoneWithName:timezoneStr];
    [formatter setTimeZone:timeZone];
	NSDate* sunriseDate = [formatter dateFromString:[sunrise length]>0?sunrise:@"6:00AM"];
	
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
	
	unsigned dateUnitFlags = NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit;
	unsigned timeUnitFlags = NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit;
	
	NSDateComponents *dateComp = [calendar components:dateUnitFlags fromDate:[data objectForKey:CW_REPORT_XML_A_LOCALTIME]];
	NSDateComponents *timeComp = [calendar components:timeUnitFlags fromDate:sunriseDate];
	
	[timeComp setDay:[dateComp day]];
	[timeComp setMonth:[dateComp month]];
	[timeComp setYear:[dateComp year]];
	
	sunriseDate = [calendar dateFromComponents:timeComp];
	return sunriseDate;
}

+ (NSDate*) sunsetFromData:(NSDictionary*)data {
	NSDateFormatter* formatter = [[[NSDateFormatter alloc] init] autorelease];
	NSLocale *prefLoc = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
	[formatter setDateFormat:@"h:mma"];
     //  [formatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
	[formatter setLocale:prefLoc];
	[prefLoc release];
	
	NSString* sunset = [data objectForKey:WEATHER_KEY_SUNSET];
    return  [self dataFromStr:sunset];
    NSString* timezoneStr=[data objectForKey:PLACE_KEY_TIMEZONE];
    NSTimeZone *timeZone=[NSTimeZone timeZoneWithName:timezoneStr];
    [formatter setTimeZone:timeZone];
	NSDate* sunsetDate = [formatter dateFromString:[sunset length]>0?sunset:@"9:00PM"];
	
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
	
	unsigned dateUnitFlags = NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit;
	unsigned timeUnitFlags = NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit;
	
	NSDateComponents *dateComp = [calendar components:dateUnitFlags fromDate:[data objectForKey:CW_REPORT_XML_A_LOCALTIME]];
	NSDateComponents *timeComp = [calendar components:timeUnitFlags fromDate:sunsetDate];
	
	[timeComp setDay:[dateComp day]];
	[timeComp setMonth:[dateComp month]];
	[timeComp setYear:[dateComp year]];
	
	sunsetDate = [calendar dateFromComponents:timeComp];
	return sunsetDate;
}



+ (NSString*) weatherBySkyDeskr:(NSString*)skyDeskr {
	NSString* result = kBluesky;
	NSNumber* numKey = [NSNumber numberWithInt:[skyDeskr intValue]];
	int key = [numKey intValue];
	if (0 != key) {
		if ((key>=1 && key<=4) || (key>=7 && key<=9)) {
			result = kBluesky;
		}
		if ((key>=10 && key<=12)||(key>=31 && key<=32)||key==26||key==29) {
			result = kPartlycloudy;
		}
		if ((key>=13 && key<=19) ||(key>=27 && key<=28) || key==30 ) {
			result = kCloudy;
		}
		if ((key>=20 && key<=25) ||(key>=33 && key<=34) ||(key>=5 && key<=6)) {
			result = kFog;
		}
	}
	return result;
}

+ (NSString*) weatherByPrecipDeskr:(NSString*)precipDeskr {
	NSString* result =kBluesky;
	NSNumber* numKey = [NSNumber numberWithInt:[precipDeskr intValue]];
	int key = [numKey intValue];
	if (0 != key) {
		if ((key>=1 && key<=27) || (key==31) || 
			(key>=50 && key<=55) || (key>=63 && key<=70)) {
			result = kRain;
		}
		if ((key>=28 && key<=30) || (key>=32 && key<=49) || 
			(key>=41 && key<=49) || (key>=56 && key<=62)
			|| (key>=71 && key<=77)) {
			result = kSnow;
		}
	}
	return result;
}

+ (NSString*) getVideoForWeather:(NSString*)aWeather timeOfDay:(NSString*)aTimeOfDay{
    NSString *result=[NSString stringWithFormat:@"%@_%@",kDay, kBluesky];
    //если день, то всё прозрачно 
    if (![aTimeOfDay isEqualToString:kDay]) { // если ночь или закат/рассвет
        if ([aWeather isEqualToString:kPartlycloudy]) {
            aWeather=kBluesky; // если маля облачность то показываем чистое небо
        }
        if (![aWeather isEqualToString:kBluesky]) { //всё что не чистое небо
            aWeather=kCloudy;
        }
    }
     result=[NSString stringWithFormat:@"%@_%@",aTimeOfDay, aWeather];
    return  result;
}


@end
