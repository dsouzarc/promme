//
//  LogInViewController.h
//  PromMe
//
//  Created by Ryan D'souza on 4/6/15.
//  Copyright (c) 2015 Ryan D'souza. All rights reserved.
//

#import "ViewController.h"

#import "MainPromMePageViewController.h"
#import "PQFCirclesInTriangle.h"
#import "UICKeyChainStore.h"
#import "Person.h"
#import "ProfilePictureTableViewCell.h"

#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <ParseFacebookUtilsV4/PFFacebookUtils.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <Parse/Parse.h>

@interface LogInViewController : ViewController <FBSDKLoginButtonDelegate, UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate, UIImagePickerControllerDelegate>

@end
