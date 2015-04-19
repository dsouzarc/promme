//
//  MainPromMePageViewController.m
//  PromMe
//
//  Created by Ryan D'souza on 4/6/15.
//  Copyright (c) 2015 Ryan D'souza. All rights reserved.
//

#import "MainPromMePageViewController.h"

@interface MainPromMePageViewController ()

@property (strong, nonatomic) SwipeDraggableView *draggableView;
@property (strong, nonatomic) PeopleAcceptedViewController *peopleAccepted;

@property (strong, nonatomic) IBOutlet UILabel *nameLabel;
@property (strong, nonatomic) IBOutlet UILabel *detailsLabel;
@property (strong, nonatomic) IBOutlet UIButton *matchesButton;

@property (strong, nonatomic) NSMutableArray *availablePeopleToSwipe;
@property (strong, nonatomic) NSArray *friendsList;
@property (strong, nonatomic) NSString *facebookID;

@property (strong, nonatomic) PQFCirclesInTriangle *loadingAnimation;

- (IBAction)yesIcon:(id)sender;
- (IBAction)noIcon:(id)sender;

- (IBAction)searchPreferencesButton:(id)sender;
- (IBAction)matchesClicked:(id)sender;

@end

@implementation MainPromMePageViewController

static int profilePictureNumber = 1;
static int currentPersonIndex = 0;
static Person *currentPerson;

- (instancetype) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if(self) {
        self.availablePeopleToSwipe = [[NSMutableArray alloc] init];
        UICKeyChainStore *keychain = [[UICKeyChainStore alloc] init];
        self.facebookID = keychain[@"facebookid"];

        self.loadingAnimation = [[PQFCirclesInTriangle alloc] initLoaderOnView:self.view];
        self.loadingAnimation.center = CGPointMake((self.view.frame.size.width - 100) / 2, (self.view.frame.size.height - 150) / 2);
        self.loadingAnimation.loaderColor = [UIColor blueColor];
        self.loadingAnimation.maxDiam = 150;
    }
    
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self loadFriends];
}

/** GETS AVAILABLE PEOPLE TO SWIPE FROM PARSE */
- (void) loadFriends
{
    [self.loadingAnimation show];
    
    NSDictionary *params = @{@"myFBID": self.facebookID,
                             @"isLocation": @true,
                             @"maxDistance": @100,
                             @"isSchool": @true,
                             @"highschool": @"Princeton High School",
                             @"isGender": @true,
                             @"gender": @"Female"};
    
    [PFCloud callFunctionInBackground:@"getPeopleToSwipe" withParameters:params block:^(NSArray *results, NSError *error) {
        
        [self.loadingAnimation hide];
        if(!error) {
            
            [self.availablePeopleToSwipe removeAllObjects];
            
            for(NSDictionary *result in results) {
                Person *person = [[Person alloc] initWithEverything:result];
                NSLog(@"AVAILABLE TO SWIPE: %@", person.name);
                [self.availablePeopleToSwipe addObject:person];
            }
            
            [self showNextPerson];
        }
        
        else {
            NSLog(@"Error");
        }
        
    }];

}

- (IBAction)yesIcon:(id)sender {
    [self yesPerson];
}

- (IBAction)noIcon:(id)sender {
    [self noPerson];
}

- (IBAction)searchPreferencesButton:(id)sender {
    NSLog(@"Getting people");
    [self loadFriends];
}


- (void) yesPerson {
    self.nameLabel.textColor = [UIColor greenColor];
    self.nameLabel.text = [NSString stringWithFormat:@"%@: Yes", self.nameLabel.text];

    /*NSDictionary *params = @{@"users_facebook_id": self.facebookID,
                             @"otherFBID": ((Person*)self.availablePeopleToSwipe[counter])[@"users_facebook_id"]
                             };*
    
    
    [PFCloud callFunctionInBackground:@"swiped" withParameters:params block:^(NSString *result, NSError *error) {
        if(error) {
            NSLog(@"Error calling swiped: %@", error.description);
        }
        else {
            if([result isEqualToString:@"YES"]) {
                NSLog(@"Swipe saved");
            }
            else {
                NSLog(@"Swipe problem");
            }
        }
    }]; */

    [self nextPerson];
    //[self getPeople];
}

- (void) noPerson {
    self.nameLabel.textColor = [UIColor redColor];
    self.nameLabel.text = [NSString stringWithFormat:@"%@: No", self.nameLabel.text];
    [self nextPerson];
}

- (void) swipedDirection:(SwipeDraggableView *)view didSwipeLeft:(BOOL)didSwipeLeft
{
    if(didSwipeLeft) {
        [self noPerson];
    }
    else {
        [self yesPerson];
    }
}

- (void) nextPerson {
    currentPersonIndex++;
    
    self.view.window.backgroundColor = [UIColor whiteColor];
    
    if(self.draggableView) {
        [UIView animateWithDuration:0.1 delay:0.3 options:0 animations:^{
            self.draggableView.alpha = 0.0f;
        
        }completion:^(BOOL finished) {
            self.draggableView.hidden = YES;
            [self showNextPerson];
        }];
    }
    else {
        [self showNextPerson];
    }
}

- (void) swipedDirection:(SwipeDraggableView *)view didSwipeUp:(BOOL)didSwipeUp
{
    if(didSwipeUp) {
        profilePictureNumber++;
        if(profilePictureNumber >= 6) {
            profilePictureNumber = 1;
        }
    }
    else {
        profilePictureNumber--;
        if(profilePictureNumber <= 0) {
            profilePictureNumber = 5;
        }
    }
    
    [self showNextProfilePhoto];
}

- (void) showNextPerson {
    
    [self.loadingAnimation show];
    
    if(currentPersonIndex >= self.availablePeopleToSwipe.count) {
        [self showAlert:@"Uh oh." alertMessage:@"Sorry, no more people to swipe. Please check back later" buttonName:@"Ok"];
        return;
    }
    
    currentPerson = self.availablePeopleToSwipe[currentPersonIndex];
    
    NSDictionary *parameters = @{@"facebookID": currentPerson.facebookID,
                                 @"pictureNumber": [NSNumber numberWithInt:1]};
    
    [PFCloud callFunctionInBackground:@"getUserPhoto" withParameters:parameters block:^(PFFile *file, NSError *error) {
        
        if(!error) {
            
            [file getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                if(!error) {
                    NSLog(@"NO ERROR");
                    self.draggableView = [[SwipeDraggableView alloc] init:currentPerson nameLabel:self.nameLabel photo:[UIImage imageWithData:data]];
                    self.draggableView.delegate = self;
                    
                    self.nameLabel.text = currentPerson.name;
                    
                    [self.view addSubview:self.draggableView];
                    
                    int imageSize = 300;
                    
                    self.draggableView.frame = CGRectMake((self.view.frame.size.width - imageSize)/2, (self.view.frame.size.height - imageSize)/2, imageSize, imageSize);
                    
                    [self.draggableView setCenter:CGPointMake(CGRectGetMidX(self.view.bounds), CGRectGetMidY(self.view.bounds))];
                    self.nameLabel.textColor = [UIColor blackColor];
                    
                    [self.loadingAnimation hide];
                }
                else {
                    [self showAlert:@"Error" alertMessage:@"Sorry, something went wrong while trying to display this user's profile photo" buttonName:@"Ok"];
                }
            }];
        }
        else {
            [self showAlert:@"Error" alertMessage:@"Sorry, something went wrong while trying to get this user's profile photo" buttonName:@"Ok"];
        }
    }];
}

- (void) showNextProfilePhoto
{
    [self.loadingAnimation show];
    NSDictionary *parameters = @{@"facebookID": currentPerson.facebookID,
                                 @"pictureNumber": [NSNumber numberWithInt:profilePictureNumber]};
    
    [PFCloud callFunctionInBackground:@"getUserPhoto" withParameters:parameters block:^(PFFile *file, NSError *error) {
        if(!error) {
            [file getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                
                if(!error) {
                    self.draggableView.photo = [UIImage imageWithData:data];
                    [self.draggableView setNeedsDisplay];
                    [self.loadingAnimation hide];
                }
                else {
                    [self showAlert:@"Error" alertMessage:@"Sorry, something went wrong while trying to display this user's profile photo" buttonName:@"Ok"];
                }
            }];
        }
        else {
            [self showAlert:@"Error" alertMessage:@"Sorry, something went wrong while trying to get this user's profile photo" buttonName:@"Ok"];
        }
    }];
}

- (IBAction)matchesClicked:(id)sender {
    self.peopleAccepted = [[PeopleAcceptedViewController alloc] initWithNibName:@"PeopleAcceptedViewController" bundle:[NSBundle mainBundle]];
    
    [self.peopleAccepted showInView:self.view shouldAnimate:YES];
}

- (void) showAlert:(NSString*)alertTitle alertMessage:(NSString*)alertMessage buttonName:(NSString*)buttonName {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:alertTitle
                                                        message:alertMessage
                                                       delegate:nil
                                              cancelButtonTitle:buttonName
                                              otherButtonTitles:nil, nil];
    [alertView show];
}


@end
