//
//  SearchPlaceViewController.h
//  WeatherClock
//
//  Created by Igor Fedorov on 7/14/10.
//  Copyright 2010 iPhone developer at Postindustria. All rights reserved.
//

#import "SearcherDelegate.h"
#import <Foundation/Foundation.h>


@interface SearchPlaceViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate>

@property(strong, nonatomic) IBOutlet UISearchBar *searchField;
@property(strong, nonatomic) IBOutlet UIView *searchView;
@property(strong, nonatomic) IBOutlet UITableView *placesTable;
@property(strong, nonatomic) NSArray *foundPlaces;
@property(weak, nonatomic) id <SearchPlaceViewControllerDelegate> delegate;

- (IBAction)cancel:(id)sender;

@end

