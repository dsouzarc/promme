//
//  Person.h
//  PromMe
//
//  Created by Ryan D'souza on 4/6/15.
//  Copyright (c) 2015 Ryan D'souza. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Person : NSObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *id;
@property (nonatomic, strong) NSString *profilePhotoLink;

- (instancetype) initWithEverything:(NSString*)id name:(NSString*)name photoLink:(NSString*)photoLink;

@end
