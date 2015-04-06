//
//  Person.m
//  PromMe
//
//  Created by Ryan D'souza on 4/6/15.
//  Copyright (c) 2015 Ryan D'souza. All rights reserved.
//

#import "Person.h"

@implementation Person

- (instancetype) initWithEverything:(NSString *)id name:(NSString *)name photoLink:(NSString *)photoLink
{
    self = [super init];
    
    if(self) {
        self.id = id;
        self.name = name;
        self.profilePhotoLink = photoLink;
    }
    
    return self;
}

@end

