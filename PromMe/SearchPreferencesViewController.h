//
//  SearchPreferencesViewController.h
//  PromMe
//
//  Created by Ryan D'souza on 4/19/15.
//  Copyright (c) 2015 Ryan D'souza. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UICKeyChainStore.h"

@class SearchPreferencesViewController;

@protocol SearchPreferencesViewControllerDelegate <NSObject>

- (void) searchPreferencesViewController:(SearchPreferencesViewController*)viewController;

@end

@interface SearchPreferencesViewController : UIViewController <UITextFieldDelegate>

@property (nonatomic, weak) id<SearchPreferencesViewControllerDelegate> delegate;

@end