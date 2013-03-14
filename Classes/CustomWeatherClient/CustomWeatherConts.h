/*
 *  CustomWeatherConts.h
 *  CustomWeatherClient
 *
 *  Created by Igor Fedorov on 8/20/10.
 *  Copyright 2010 iPhone developer at Postindustria. All rights reserved.
 *
 */

#define CLIENT          @"postindustria"
#define PASSWORD        @"it$l1felik3"

#define CW_API_DOMAIN @"http://xml.customweather.com"
#define XML_PATH    @"xml"

#define CURRENT_CONDITIONS  @"current_conditions"
#define ASTRONOMY_FORECAST  @"astronomy_forecast"
#define DETAILED_FORECAST   @"detailed_forecast"
#define EXPANDED_FORECAST   @"expanded_forecast"
#define SEARCH              @"search"

#define SEARCH_PARAM            @"search"
#define LONGTITUDE_PARAM        @"longitude"
#define LATITUDE_PARAM         @"latitude"
#define CITY_PARAM              @"name"
#define PRODUCT_PARAM           @"product"
#define CLIENT_PARAM            @"client"
#define PASSWORD_PARAM          @"client_password"
#define LANGUAGE_PARAM          @"language"

//
// XML attributes tags names
//

#define CW_REPORT_XML_A_LOCALTIME @"localtime"
#define CW_CITYLIST_XML_A_SIZE @"size"
#define CW_CITY_XML_A_ID @"id"
#define CW_CITY_XML_A_NAME @"name"
#define CW_CITY_XML_A_STATE @"state"
#define CW_CITY_XML_A_STATE_NAME @"state_name"
#define CW_CITY_XML_A_COUNTRY @"country"
#define CW_CITY_XML_A_COUNTRY_NAME @"country_name"
#define CW_CITY_XML_A_REGION @"region"
#define CW_CITY_XML_A_LONGTITUDE @"long"
#define CW_CITY_XML_A_LATITUDE @"lat"
#define CW_CITY_XML_A_TIMEZONE_CODE @"timezone_code"
#define CW_CITY_XML_A_TIMEZONE_ID @"timezone_id"
#define CW_CITY_XML_A_TIMEZONE @"timezone"
#define CW_OBSERVATION_XML_A_SKY_DESC @"sky_desc"
#define CW_OBSERVATION_XML_A_SKY @"sky"
#define CW_OBSERVATION_XML_A_PRECIP_DESC @"precip_desc"
#define CW_OBSERVATION_XML_A_PRECIP @"precip"
#define CW_OBSERVATION_XML_A_TEMPERATURE @"temperature"
#define CW_OBSERVATION_XML_A_DESCRIPTION @"description"
#define CW_FORECAST_XML_A_WEEKDAY @"weekday"
#define CW_FORECAST_XML_A_LOW_TEMP @"low_temp"
#define CW_FORECAST_XML_A_HIGH_TEMP @"high_temp"
#define CW_FORECAST_XML_A_SKY_DESC @"sky_desc"
#define CW_FORECAST_XML_A_SKY @"sky"
#define CW_FORECAST_XML_A_PRECIP_DESC @"precip_desc"
#define CW_FORECAST_XML_A_PRECIP @"precip"
#define CW_FORECAST_XML_A_DESCRIPTION @"description"
#define CW_FORECAST_XML_A_DAY_SEGMENT @"day_segment"
#define CW_FORECAST_XML_A_SEGMENT @"segment"
#define CW_FORECAST_XML_A_DAY_OF_WEEK @"day_of_week"
#define CW_FORECAST_XML_A_SUNSET @"sunset"
#define CW_FORECAST_XML_A_SUNRISE @"sunrise"
#define CW_FORECAST_XML_A_TEMPERATURE CW_OBSERVATION_XML_A_TEMPERATURE
#define CW_FORECAST_XML_A_ISO8601 @"iso8601"

//
// XML tags
//

#define CW_CITYLIST_XML @"cw_citylist"
#define CW_CITY_XML @"city"
#define CW_REPORT_XML @"report"
#define CW_OBSERVATION_XML @"observation"
#define CW_FORECAST_XML @"forecast"
#define CW_LOCATION_XML @"location"

//
// XML CONSTANTS
//

#define CW_ABSENT_DESCRIPTION @"*"
#define CW_NIGHT_FORCAST @"N"
#define CW_EVENING_FORECAST @"E"
//
// Weather data model keys names
//

#define WEATHER_KEY_CURRENT_CONDITION		@"current_condition"
#define WEATHER_KEY_EXTENDED_CONDITION		@"extended_condition"
#define WEATHER_KEY_DETAILED_FORECAST		@"detailed_forecast"
#define WEATHER_KEY_WEATHERS_ON_ALL_DAYS	@"weather"
#define WEATHER_KEY_WEATHER_CODE			@"weatherCode"
#define WEATHER_KEY_TEMP_C					@"temp_C"
#define WEATHER_KEY_TEMP_F					@"temp_F"
#define WEATHER_KEY_DATE					@"date"
#define WEATHER_KEY_TEMP_MAX_F				@"maxtempF"
#define WEATHER_KEY_TEMP_MIN_F				@"mintempF"
#define WEATHER_KEY_TEMP_MAX				@"maxtemp"
#define WEATHER_KEY_TEMP_MIN				@"mintemp"
#define WEATHER_KEY_DESCRIPTION				@"weatherDesc"
#define WEATHER_KEY_DAY_ICON				@"day_icon"
#define WEATHER_KEY_NIGHT_ICON				@"night_icon"
#define WEATHER_KEY_DAY_BACKGROUND			@"day_background"
#define WEATHER_KEY_NIGHT_BACKGROUND		@"night_background"
#define WEATHER_KEY_DATA					@"data"
#define WEATHER_KEY_CODEMAPPING				@"codeMapping"
#define WEATHER_KEY_BACKGROUND				@"backgroundImage"
#define WEATHER_KEY_IMAGE_NAME				@"image"
#define WEATHER_KEY_IS_STATIC				@"isStatic"
#define WEATHER_KEY_PLACE					@"place"
#define WEATHER_KEY_HOURLY					@"hourly"
#define WEATHER_KEY_ASTRONOMY				@"astronomy"
#define WEATHER_KEY_SUNSET					@"sunset"
#define WEATHER_KEY_SUNRISE					@"sunrise"
#define WEATHER_KEY_WEEKDAY					@"weekday"
#define WEATHER_KEY_DAY_SEGMENT CW_FORECAST_XML_A_DAY_SEGMENT
#define WEATHER_KEY_SEGMENT CW_FORECAST_XML_A_SEGMENT
#define WEATHER_KEY_DAY_OF_WEEK CW_FORECAST_XML_A_DAY_OF_WEEK
#define WEATHER_KEY_VIDEO_FILE              @"video"
#define WEATHER_KEY_FAKE_TODAY              @"faketoday"
//
// Place data model keys names and constants
//

#define PLACE_KEY_ID @"id"
#define PLACE_KEY_CITY @"city"
#define PLACE_KEY_COUNTRY @"country"
#define PLACE_KEY_REGION @"region"
#define PLACE_KEY_LATITUDE @"latitude"
#define PLACE_KEY_LONGITUDE @"longitude"
#define PLACE_KEY_TIMEZONE @"timezone"

//
// File name for icons mapping data
//

#define ICONS_MAPPING_FILE @"icons_mapping"

//
// Weather descriptors names
//

#define SKY_DESCRIPTORS_KEY @"Sky Descriptors"
#define PRECIP_DESCRIPTORS_KEY @"Precipitation Descriptors"
#define DEFAULT_DESCRIPTORS_KEY @"Default Descriptors"

//
// 
//

#define ISO8601_UNIX_FORMAT @"yyyy-MM-dd"

//
// Place data model keys names and constants
//
#define UNKNOWN_LOCATION @"unknown"
#define AUTOMATIC_IDX -1

//
// Use this prefix for filenames (data, preferences, etc)
//
#define FILE_PREFIX @"WeatherClock_"

//
//   define WWO_UPDATES_TIMEOUT_SEC 60 * 60
//
#define WWO_UPDATES_TIMEOUT_SEC 60 * 20 //20 min
