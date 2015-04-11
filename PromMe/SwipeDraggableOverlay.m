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
        self.imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"fire"]];
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
        self.imageView.image = [UIImage imageNamed:@"fire"];
    }
    else {
        self.imageView.image = [UIImage imageNamed:@"yes_dress"];
    }
}

- (void) layoutSubviews
{
    [super layoutSubviews];
    self.imageView.frame = CGRectMake(70, 0, 150, 300);
}

@end
