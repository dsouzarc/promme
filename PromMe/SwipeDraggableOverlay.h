//
//  SwipeDraggableOverlay.h
//  PromMe
//
//  Created by Ryan D'souza on 4/8/15.
//  Copyright (c) 2015 Ryan D'souza. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SwipeDraggableView.h"

typedef NS_ENUM(NSUInteger, SwipeDraggableOverlayMode) {
    SwipeDraggableOverlayModeLeft,
    SwipeDraggableOverlayModeRight
};

@interface SwipeDraggableOverlay : UIView

@end
