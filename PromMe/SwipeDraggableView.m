//
//  SwipeDraggableView.m
//  PromMe
//
//  Created by Ryan D'souza on 4/7/15.
//  Copyright (c) 2015 Ryan D'souza. All rights reserved.
//

#import "SwipeDraggableView.h"

@interface SwipeDraggableView ()

@property (strong, nonatomic) Person *person;
@property (strong, nonatomic) UIPanGestureRecognizer *panGestureRecognizer;

@end


@implementation SwipeDraggableView

- (instancetype) init:(Person *)person
{
    self = [super init];
    self.person = person;
    
    self.backgroundColor = [UIColor blackColor];
    self.panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(dragged:)];
    
    [self addGestureRecognizer:self.panGestureRecognizer];
    
    NSLog(self.person.profilePhotoLink);
    
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:self.person.profilePhotoLink]]]];
    
    [self addSubview:imageView];
    self.layer.cornerRadius = 8;
    self.layer.shadowOffset = CGSizeMake(7, 7);
    self.layer.shadowRadius = 5;
    self.layer.shadowOpacity = 0.5;
    
    return self;
}

- (void) dragged:(UIPanGestureRecognizer*)gestureRecognizer
{
    
}


@end
