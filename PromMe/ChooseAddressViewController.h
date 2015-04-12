//
//  ChooseAddressViewController.h
//  Bring Me Food
//
//  Created by Ryan D'souza on 3/15/15.
//  Copyright (c) 2015 Ryan D'souza. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SPGooglePlacesAutocompleteQuery.h"
#import "SPGooglePlacesAutocompletePlace.h"
#import <Parse/Parse.h>

@class ChooseAddressViewController;

@protocol ChooseAddressDelegate <NSObject>

- (void) chooseAddressViewController:(ChooseAddressViewController*)viewController chosenAddress:(PFGeoPoint*)chosenAddress addressName:(NSString*)addressName;

@end

@interface ChooseAddressViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property(nonatomic, weak) id<ChooseAddressDelegate> delegate;

@end
