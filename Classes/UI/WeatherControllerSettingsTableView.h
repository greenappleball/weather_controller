//
//  WeatherControllerSettingsTableView.h
//  WeatherClock
//
//  Created by Igor Fedorov on 7/14/10.
//  Copyright 2010 iPhone developer at Postindustria. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol WeatherControllerSettingsTableViewDelegate;

@interface WeatherControllerSettingsTableView : UITableViewController

@property(nonatomic, weak) id <WeatherControllerSettingsTableViewDelegate> delegate;
@property(nonatomic, retain) NSMutableArray *places;

@end

@protocol WeatherControllerSettingsTableViewDelegate <NSObject>

- (void)setCurrentPlace:(NSDictionary*)aPlace;

- (void)setAutomaticWeatherMode;

- (void)addNewPlace;

- (void)removePlace:(NSDictionary*)aPlace;

@end

