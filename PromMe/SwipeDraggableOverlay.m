//
//  SwipeDraggableOverlay.m
//  PromMe
//
//  Created by Ryan D'souza on 4/8/15.
//  Copyright (c) 2015 Ryan D'souza. All rights reserved.
//

#import "SwipeDraggableOverlay.h"

@interface SwipeDraggableOverlay ()

@property UIImageView *imageView;

@end

@implementation SwipeDraggableOverlay

- (id) initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if(self) {
        self.backgroundColor = [UIColor whiteColor];
        self.imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"yes_dress"]];
        [self addSubview:self.imageView];
    }
    
    return self;
}

- (void) setMode:(SwipeDraggableOverlayMode)mode
{
    if(_mode == mode) {
        return;
    }
    
    _mode = mode;
    
    if(_mode == SwipeDraggableOverlayModeLeft) {
        NSLog(@"HERE");
        self.imageView.image = [UIImage imageNamed:@"no_dress"];
    }
    else {
        self.imageView.image = [UIImage imageNamed:@"yes_dress"];
    }
}

- (void) layoutSubviews
{
    [super layoutSubviews];
    self.imageView.frame = CGRectMake(50, 50, 100, 100);
}

@end
