//
//  WeatherControllerSettingsTableView.m
//  WeatherClock
//
//  Created by Igor Fedorov on 7/14/10.
//  Copyright 2010 iPhone developer at Postindustria. All rights reserved.
//

#import "WeatherControllerSettingsTableView.h"
#import "WeatherController.h"
#import "SearchPlaceViewController.h"
#import "TransparentToolbar.h"
#import "CustomWeatherConts.h"
#import "LifelikeClock2AppDelegate.h"
#import "UIPopoverManager.h"

#define NUMBER_SECTION 2
#define AUTOMATIC_SECTION 0
#define USER_SECTION 1

@implementation WeatherControllerSettingsTableView

@synthesize delegate;

- (void)setPlaces:(NSMutableArray *)thePlaces {
	[places release];
	places = [thePlaces retain];
	[self.tableView reloadData];
}

- (NSMutableArray*)places {
	return places;
}

#pragma mark -
#pragma mark Initialization

- (id)init {
	if ((self = [super initWithStyle:UITableViewStyleGrouped])) {
		
	}
	
	return self;
}

/*
- (id)initWithStyle:(UITableViewStyle)style {
    // Override initWithStyle: if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
    if ((self = [super initWithStyle:style])) {
    }
    return self;
}
*/


#pragma mark -
#pragma mark View lifecycle

/*
*/
- (void)viewDidLoad {
    [super viewDidLoad];
	[self.tableView setFrame:CGRectMake(0, 0, 480, 300)];
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
	self.title = NSLocalizedString(@"Location",@"Location");
	TransparentToolbar* tools;
	NSString *locString = [[[NSBundle mainBundle] preferredLocalizations] objectAtIndex:0];
	if ([locString isEqualToString:@"de"]) {
		tools = [[TransparentToolbar alloc] initWithFrame:CGRectMake(0, 0, 134.0, 44.0)];
	} else if ([locString isEqualToString:@"fr"]) {
		tools = [[TransparentToolbar alloc] initWithFrame:CGRectMake(0, 0, 117.0, 44.0)];
	} else {
		tools = [[TransparentToolbar alloc] initWithFrame:CGRectMake(0, 0, 100.0, 44.0)];
	}
	tools.barStyle = UIBarStyleBlackTranslucent;
	// create the array to hold the buttons, which then gets added to the toolbar
	NSMutableArray* buttons = [[NSMutableArray alloc] initWithCapacity:2];

	// create a standard "add" button
	UIBarButtonItem *add = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(searchNewPlace:)];
	[add setStyle:UIBarButtonItemStyleBordered];
	[buttons addObject:add];
	[buttons addObject:self.editButtonItem];
	[add release];

	// stick the buttons in the toolbar
	[tools setItems:buttons animated:NO];
	[buttons release];
	UIBarButtonItem *buttonsBar = [[UIBarButtonItem alloc] initWithCustomView:tools];
	[tools release];
	// and put the toolbar in the nav bar
	self.navigationItem.rightBarButtonItem = buttonsBar;
	[buttonsBar release];
		
	//[self.navigationController.navigationBar pushNavigationItem:add animated:YES];
    //self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

/*
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}
*/
/*
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}
*/

- (void)viewWillDisappear:(BOOL)animated {
	[self setEditing:NO];
    [super viewWillDisappear:animated];
}

/*
- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}
*/

/*
- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
	if ([self modalViewController] != nil) {
		[self.modalViewController willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
	}
}

*/
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return YES;
}


#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return NUMBER_SECTION;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return (section == AUTOMATIC_SECTION ? 1 : section == USER_SECTION ? [places count] : 0) ;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"SettingsViewCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    switch (indexPath.section) {
		case AUTOMATIC_SECTION:
			[cell.textLabel setText:NSLocalizedString(@"Automatic mode",@"Automatic mode")];
			if ([[WeatherController sharedController] scheduledPlaceIdx] == AUTOMATIC_IDX) {
				[cell setAccessoryType:UITableViewCellAccessoryCheckmark];
			} else {
				[cell setAccessoryType:UITableViewCellAccessoryNone];
			}
			break;
		case USER_SECTION: {
			NSDictionary *aPlace = [places objectAtIndex:indexPath.row];
			NSString *placeStr = [NSString stringWithFormat:@"%@, %@", [aPlace objectForKey:PLACE_KEY_COUNTRY], [aPlace objectForKey:PLACE_KEY_CITY]];
			[cell.textLabel setText:placeStr];
			if ([[WeatherController sharedController] scheduledPlaceIdx] == indexPath.row) {
				[cell setAccessoryType:UITableViewCellAccessoryCheckmark];
			} else {
				[cell setAccessoryType:UITableViewCellAccessoryNone];
			}

		}
			break;
		default:
			break;
	}
    // Configure the cell...
    
    return cell;
}


/*
*/
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return indexPath.section != AUTOMATIC_SECTION;
}


/*
*/
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
		NSDictionary *removedPlace = [places objectAtIndex:indexPath.row];
		[places removeObject:removedPlace];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:YES];
		if ([delegate respondsToSelector:@selector(removePlace:)]) {
			[delegate removePlace:removedPlace];
		}
		
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}


/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/


/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here. Create and push another view controller.
	/*
	 <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
	 [self.navigationController pushViewController:detailViewController animated:YES];
	 [detailViewController release];
	 */
	[tableView deselectRowAtIndexPath:indexPath animated:NO];
	
	switch (indexPath.section) {
		case AUTOMATIC_SECTION:
			if ([delegate respondsToSelector:@selector(setAutomaticWeatherMode)]) {
				[delegate setAutomaticWeatherMode];
			}
			break;
		case USER_SECTION:
				if ([delegate respondsToSelector:@selector(setCurrentPlace:)]) {
				[delegate setCurrentPlace:[places objectAtIndex:indexPath.row]];
			}
			break;
		default:
			break;
	}
	[tableView reloadData];
}


#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
}


- (void)dealloc {
	self.places = nil;
    [super dealloc];
}

- (void)searchNewPlace:(id)sender {
	if ([delegate respondsToSelector:@selector(addNewPlace)]) {
		[delegate addNewPlace];
	}
   /* [UIPopoverManager dismissPopover];
    LifelikeClock2ViewController *rootCtrl = [(LifelikeClock2AppDelegate*)[[UIApplication sharedApplication] delegate] viewController];
    [rootCtrl presentModalViewController:(UIViewController*)[[WeatherController sharedController] searchViewController] animated:YES];*/

}

@end

