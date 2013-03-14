//
//  SearchPlaceViewController.m
//  WeatherClock
//
//  Created by Igor Fedorov on 7/14/10.
//  Copyright 2010 iPhone developer at Postindustria. All rights reserved.
//

#import "CustomWeatherConts.h"
#import "SearchPlaceViewController.h"

#import <QuartzCore/QuartzCore.h>


@implementation SearchPlaceViewController

#pragma mark - Accessors

- (void)setFoundPlaces:(NSArray *)thePlaces {
	_foundPlaces = thePlaces;
	[self.placesTable reloadData];
}

#pragma mark - Private

- (CATransition*)progressVeiwTransiton {
	
	CATransition *transition = [CATransition animation];
	// Animate over 3/4 of a second
	transition.duration = 0.4;
	// using the ease in/out timing function
	transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
	
	// Now to set the type of transition.
	transition.type = kCATransitionFade;
	
	return transition;
}

#pragma mark - Actions

- (IBAction)cancel:(id)sender {
    UIViewController* controller = nil;
    if ([self parentViewController] != nil) {
        controller = [self parentViewController];
    } else if ([self respondsToSelector:@selector(presentingViewController)] && [self presentingViewController] != nil) {
        controller = [self presentingViewController];
    }
    [controller dismissModalViewControllerAnimated:YES];
}

#pragma mark - Initialization

- (id)init {
	if ((self = [super initWithNibName:@"SearchPlaceView" bundle:nil])) {
	}
	return self;
}

#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
	self.searchView.layer.borderWidth = 1;
	self.searchView.layer.cornerRadius = 10.0;
	self.searchView.layer.borderColor = [[UIColor grayColor] CGColor];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
	[self.searchField setText:@""];
	self.foundPlaces = nil;
	if ([self.searchField canBecomeFirstResponder]) {
		[self.searchField becomeFirstResponder];
	}
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.foundPlaces count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
	NSDictionary *place = [self.foundPlaces objectAtIndex:indexPath.row];
	NSString *region = [place objectForKey:@"region"];
	NSString *cellText = [NSString stringWithFormat:@"%@,%@ %@", [place objectForKey:PLACE_KEY_CITY], ![region isEqualToString:UNKNOWN_LOCATION]?[NSString stringWithFormat:@" %@,", region]:@"", [place objectForKey:PLACE_KEY_COUNTRY]];
						  
    [cell.textLabel setText:cellText];
    
    return cell;
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
	if ([self.delegate respondsToSelector:@selector(getPlacesByQuery:)]) {
		[self.delegate getPlacesByQuery:searchText];
	}
}

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if ([self.delegate respondsToSelector:@selector(userChoosePlace:)]) {
		[self.delegate userChoosePlace:[self.foundPlaces objectAtIndex:indexPath.row]];
	}
	[self cancel:nil];
}

#pragma mark -
#pragma mark Memory management

- (void)viewDidUnload {
	self.placesTable = nil;
	self.searchView = nil;
	self.searchField = nil;
}

@end

