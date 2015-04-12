//
//  ChooseAddressViewController.m
//  Bring Me Food
//
//  Created by Ryan D'souza on 3/15/15.
//  Copyright (c) 2015 Ryan D'souza. All rights reserved.
//

#import "ChooseAddressViewController.h"
#import <Parse/Parse.h>

@interface ChooseAddressViewController ()

- (IBAction)editDidBegin:(id)sender;

@property (strong, nonatomic) IBOutlet UITextField *textField;
@property (strong, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) NSArray *possibleLocations;

@property (strong, nonatomic) SPGooglePlacesAutocompleteQuery *query;

@end

@implementation ChooseAddressViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (instancetype) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    self.query = [[SPGooglePlacesAutocompleteQuery alloc] initWithApiKey:[self getGoogleAPIKey]];
    self.possibleLocations = [[NSArray alloc] init];
    return self;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.possibleLocations.count;
}

- (UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"Cell";
    
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if(cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    SPGooglePlacesAutocompletePlace *place = (SPGooglePlacesAutocompletePlace*)[self.possibleLocations
                                                                                objectAtIndex:indexPath.row];
    cell.textLabel.text = place.name;
    return cell;
}

- (void) tableView:(UITableView *)tableView didHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    SPGooglePlacesAutocompletePlace *placemark = (SPGooglePlacesAutocompletePlace*) [self.possibleLocations objectAtIndex:indexPath.row];
    
    [placemark resolveToPlacemark:^(CLPlacemark *placemark, NSString *addressString, NSError *error) {
        
        if(error) {
            NSLog(@"ERROR CONVERTING TO PLACEMARK");
        }
        else {
            PFGeoPoint *deliveryLocation = [PFGeoPoint geoPointWithLatitude:placemark.location.coordinate.latitude
                                                                  longitude:placemark.location.coordinate.longitude];
            
            [self.delegate chooseAddressViewController:self chosenAddress:deliveryLocation addressName:addressString];
            [self dismissViewControllerAnimated:YES completion:nil];
        }
    }];
}

- (NSString*)getGoogleAPIKey {
    NSString *plist = [[NSBundle mainBundle] pathForResource:@"ApiConfigurations" ofType:@"plist"];
    NSDictionary *config = [[NSDictionary alloc] initWithContentsOfFile:plist];
    
    return config[@"GoogleAPIKey"];
}

- (IBAction)editDidBegin:(id)sender {
    self.query.input = self.textField.text;
    self.query.types = SPPlaceTypeGeocode;
    
    [self.query fetchPlaces:^(NSArray *places, NSError *error) {
        if(!error) {
            self.possibleLocations = [[NSArray alloc] initWithArray:places];
            [self.tableView reloadData];
        }
    }];
}
@end
