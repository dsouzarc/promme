//
//  PeopleAcceptedViewController.h
//  PromMe
//
//  Created by Ryan D'souza on 4/8/15.
//  Copyright (c) 2015 Ryan D'souza. All rights reserved.
//

#import "ViewController.h"

@interface PeopleAcceptedViewController : ViewController <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate>
- (void) showInView:(UIView *)view shouldAnimate:(BOOL)shouldAnimate;
@end
