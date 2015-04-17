//
//  Person.h
//  PromMe
//
//  Created by Ryan D'souza on 4/6/15.
//  Copyright (c) 2015 Ryan D'souza. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Person : NSObject

@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *highSchool;
@property (strong, nonatomic) NSString *grade;
@property (strong, nonatomic) NSString *facebookID;
@property (strong, nonatomic) NSString *gender;

- (instancetype) initWithEverything:(NSDictionary*)dictionary;

@end
