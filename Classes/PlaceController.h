//
//  PlaceController.h
//  LifelikeClock2
//
//  Created by Dmitri Petrishin on 3/13/13.
//  Copyright (c) 2013 Postindustria. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SearcherDelegate.h"

@interface PlaceController : NSObject

@property(nonatomic, assign) id <SearchPlaceViewControllerDelegate> delegate;

- (void)currentPlaceWithBlock:(void (^)(NSDictionary* place))block;

@end
