//
//  MatchedPerson.m
//  PromMe
//
//  Created by Ryan D'souza on 4/19/15.
//  Copyright (c) 2015 Ryan D'souza. All rights reserved.
//

#import "MatchedPerson.h"

@implementation MatchedPerson

- (instancetype) initWithEverything:(NSDictionary *)dictionary
{
    self = [super initWithEverything:dictionary];
    
    if(self) {
        self.phoneNumber = dictionary[@"phone"];
        
        PFFile *file = dictionary[@"profilePhoto1"];
        
        self.profilePicture = [UIImage imageWithData:[file getData]];
    }
    return self;
}

@end
