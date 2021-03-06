//
//  Person.m
//  PromMe
//
//  Created by Ryan D'souza on 4/6/15.
//  Copyright (c) 2015 Ryan D'souza. All rights reserved.
//

#import "Person.h"

@implementation Person

- (instancetype) initWithEverything:(NSDictionary *)dictionary
{
    self = [super init];
    
    if(self) {
        self.name = dictionary[@"name"];
        self.highSchool = dictionary[@"highschool"];
        self.grade = dictionary[@"grade"];
        self.facebookID = dictionary[@"facebookID"];
        self.gender = dictionary[@"gender"];
    }
    
    return self;
}


@end

