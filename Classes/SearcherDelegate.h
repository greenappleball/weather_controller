//
//  SearcherDelegate.h
//  LifelikeClock2
//
//  Created by Dmitri Petrishin on 3/13/13.
//  Copyright (c) 2013 Postindustria. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol SearchPlaceDelegate <NSObject>

- (void)findPlaces:(NSArray*)thePlaces;

- (void)findPlaceForCurrentLocation:(NSDictionary*)aPlace;

@end

@protocol SearchPlaceViewControllerDelegate <NSObject>

- (void)getPlacesByQuery:(NSString*)aQuery;

- (void)userChoosePlace:(NSDictionary*)aPlace;

@end