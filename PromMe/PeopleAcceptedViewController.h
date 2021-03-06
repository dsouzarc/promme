//
//  PeopleAcceptedViewController.h
//  PromMe
//
//  Created by Ryan D'souza on 4/8/15.
//  Copyright (c) 2015 Ryan D'souza. All rights reserved.
//

#import "ViewController.h"
#import "MatchedPersonTableViewCell.h"
#import "MatchedPerson.h"

#import <MessageUI/MFMessageComposeViewController.h>

@interface PeopleAcceptedViewController : ViewController <UITableViewDelegate, UITableViewDataSource, MFMessageComposeViewControllerDelegate>

- (instancetype) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil matchedPeople:(NSArray*)matchedPeople;

@end
