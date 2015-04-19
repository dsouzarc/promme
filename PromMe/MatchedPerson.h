//
//  MatchedPerson.h
//  PromMe
//
//  Created by Ryan D'souza on 4/19/15.
//  Copyright (c) 2015 Ryan D'souza. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <Parse/Parse.h>

#import "Person.h"

@interface MatchedPerson : Person

@property (strong, nonatomic) NSString *phoneNumber;
@property (strong, nonatomic) UIImage *profilePicture;

- (instancetype) initWithEverything:(NSDictionary *)dictionary;

@end
