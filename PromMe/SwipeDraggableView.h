//
//  SwipeDraggableView.h
//  PromMe
//
//  Created by Ryan D'souza on 4/7/15.
//  Copyright (c) 2015 Ryan D'souza. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Person.h"
#import "SwipeDraggableOverlay.h"

@class SwipeDraggableView;

@protocol SwipeDraggableViewDelegate <NSObject>

- (void) swipedDirection:(SwipeDraggableView*)view didSwipeLeft:(BOOL)didSwipeLeft;

@end

@interface SwipeDraggableView : UIView <UIGestureRecognizerDelegate>

- (instancetype) init:(Person*)person nameLabel:(UILabel*)nameLabel photo:(UIImage*)photo;

@property (strong, nonatomic) UIImage *photo;

@property (nonatomic, weak) id<SwipeDraggableViewDelegate> delegate;

@end
