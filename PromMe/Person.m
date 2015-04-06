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

- (instancetype) initWithDictionary:(NSDictionary *)dictionary
{
    NSString *name = dictionary[@"name"];
    
    NSDictionary *photoInformation = (NSDictionary*)(((NSDictionary*)dictionary[@"picture"])[@"data"]);
    
    NSString *id = photoInformation[@"url"];
    NSString *profilePhotoLink = photoInformation[@"url"];
    
    self = [self initWithEverything:id name:name photoLink:profilePhotoLink];
    return self;
}

- (instancetype) initWithParseDictionary:(NSDictionary *)fromParse
{
    self = [self initWithEverything:fromParse[@"id"] name:fromParse[@"name"] photoLink:fromParse[@"profilePhotoLink"]];
    
    return self;
}

- (NSDictionary*)toDictionary
{
    NSDictionary *dictionary = @{@"name": self.name, @"profilePhotoLink": self.profilePhotoLink, @"id": self.id};
    
    return dictionary;
}

- (void) encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.name forKey:@"name"];
    [aCoder encodeObject:self.id forKey:@"id"];
    [aCoder encodeObject:self.profilePhotoLink forKey:@"profilePhotoLink"];
}

- (id) initWithCoder:(NSCoder *)aDecoder
{
    self = [[Person alloc] init];
    
    if(self) {
        self.name = [aDecoder decodeObjectForKey:@"name"];
        self.id = [aDecoder decodeObjectForKey:@"id"];
        self.profilePhotoLink = [aDecoder decodeObjectForKey:@"profilePhotoLink"];
    }
    
    return self;
}

@end

