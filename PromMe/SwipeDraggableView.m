//
//  SwipeDraggableView.m
//  PromMe
//
//  Created by Ryan D'souza on 4/7/15.
//  Copyright (c) 2015 Ryan D'souza. All rights reserved.
//

#import "SwipeDraggableView.h"
#import "SwipeDraggableOverlay.h"

@interface SwipeDraggableView ()

@property (strong, nonatomic) Person *person;
@property (strong, nonatomic) UIPanGestureRecognizer *panGestureRecognizer;
@property (nonatomic) CGPoint startPoint;

@property (nonatomic, strong) SwipeDraggableOverlay *overlay;

@property (nonatomic, strong) UILabel *nameLabel;

@end


@implementation SwipeDraggableView

- (instancetype) init:(Person *)person nameLabel:(UILabel *)nameLabel
{
    self = [super init];
    self.person = person;
    
    self.nameLabel = nameLabel;
    self.nameLabel.textColor = [UIColor blackColor];
    
    self.backgroundColor = [UIColor blackColor];
    self.panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(dragged:)];
    
    [self addGestureRecognizer:self.panGestureRecognizer];

    self.layer.cornerRadius = 8;
    self.layer.shadowOffset = CGSizeMake(7, 7);
    self.layer.shadowRadius = 5;
    self.layer.shadowOpacity = 0.5;

    return self;
}

- (id) initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    self.panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(dragged:)];
    [self addGestureRecognizer:self.panGestureRecognizer];
    
    self.overlay = [[SwipeDraggableOverlay alloc] initWithFrame:self.bounds];
    self.overlay.alpha = 0;
    [self addSubview:self.overlay];

    return self;
}

- (void)drawRect:(CGRect)rect
{
    UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:self.person.profilePhotoLink]]];
    
    self.startPoint = CGPointMake((self.frame.size.width/2) - (image.size.width/2),
                                  (self.frame.size.height / 2) - (image.size.height / 2));
    
    [image drawInRect:CGRectMake(self.startPoint.x, self.startPoint.y, image.size.width, image.size.height)];
}


- (void)dragged:(UIPanGestureRecognizer *)gestureRecognizer
{
    CGFloat xDistance = [gestureRecognizer translationInView:self].x;
    CGFloat yDistance = [gestureRecognizer translationInView:self].y;
    
    switch (gestureRecognizer.state) {
        case UIGestureRecognizerStateBegan:{
            self.startPoint = self.center;
            break;
        };
        case UIGestureRecognizerStateChanged:{
            CGFloat rotationStrength = MIN(xDistance / 320, 1);
            CGFloat rotationAngel = (CGFloat) (2*M_PI/16 * rotationStrength);
            CGFloat scaleStrength = 1 - fabsf(rotationStrength) / 4;
            CGFloat scale = MAX(scaleStrength, 0.93);
            
            CGAffineTransform transform = CGAffineTransformMakeRotation(rotationAngel);
            CGAffineTransform scaleTransform = CGAffineTransformScale(transform, scale, scale);
            self.transform = scaleTransform;
            self.center = CGPointMake(self.startPoint.x + xDistance, self.startPoint.y + yDistance);
            
            [self updateOverlay:xDistance];
            
            if(rotationAngel < 0) {
                self.nameLabel.textColor = [UIColor redColor];
            }
            else if(rotationAngel > 0) {
                self.nameLabel.textColor = [UIColor greenColor];
            }
            else {
                self.nameLabel.textColor = [UIColor blackColor];
            }
            
            break;
        };
        case UIGestureRecognizerStateEnded: {
            [self resetViewPositionAndTransformations];
            break;
        };
        case UIGestureRecognizerStatePossible:break;
        case UIGestureRecognizerStateCancelled:break;
        case UIGestureRecognizerStateFailed:break;
    }
}

- (void)updateOverlay:(CGFloat)distance
{
    if (distance > 0) {
        self.overlay.mode = SwipeDraggableOverlayModeRight;
    } else if (distance <= 0) {
        self.overlay.mode = SwipeDraggableOverlayModeLeft;
    }
    CGFloat overlayStrength = MIN(fabsf(distance) / 100, 0.4);
    self.overlay.alpha = overlayStrength;
}

- (void)resetViewPositionAndTransformations
{
    [UIView animateWithDuration:0.2
                     animations:^{
                         self.center = self.startPoint;
                         self.transform = CGAffineTransformMakeRotation(0);
                         self.overlay.alpha = 0;
                     }];
}

@end
