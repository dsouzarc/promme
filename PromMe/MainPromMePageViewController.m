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
@property (strong, nonatomic) PQFBouncingBalls *loadingAnimation2;

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
        
        self.loadingAnimation2 = [[PQFBouncingBalls alloc] initLoaderOnView:self.view];
        self.loadingAnimation2.loaderColor = [UIColor blueColor];
        self.loadingAnimation2.jumpAmount = 150;
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
                             @"gender": @"Male"};
    
    [PFCloud callFunctionInBackground:@"getPeopleToSwipe" withParameters:params block:^(NSArray *results, NSError *error) {
        
        [self.loadingAnimation hide];
        if(!error) {
            
            [self.availablePeopleToSwipe removeAllObjects];
            
            for(NSDictionary *result in results) {
                Person *person = [[Person alloc] initWithEverything:result];
                [self.availablePeopleToSwipe addObject:person];
            }
            
            if(self.availablePeopleToSwipe.count == 0) {
                [self showAlert:@"Uh Oh" alertMessage:@"Sorry, there is no one to swipe. Please try again later" buttonName:@"ok"];
                return;
            }
            
            [self showNextPerson];
        }
        
        else {
            NSLog(@"Error");
        }
        
    }];
}

- (IBAction)yesIcon:(id)sender {
    
    if(self.availablePeopleToSwipe.count == 0) {
        [self showAlert:@"Whoops" alertMessage:@"Sorry, there's no one to swipe" buttonName:@"Ok"];
        return;
    }
    
    [self yesPerson];
}

- (IBAction)noIcon:(id)sender {
    
    if(self.availablePeopleToSwipe.count == 0) {
        [self showAlert:@"Whoops" alertMessage:@"Sorry, there's no one to swipe" buttonName:@"Ok"];
        return;
    }
    
    [self noPerson];
}

- (IBAction)searchPreferencesButton:(id)sender {
    NSLog(@"Getting people");
    [self loadFriends];
}

- (void) yesPerson {
    self.nameLabel.textColor = [UIColor greenColor];
    self.nameLabel.text = [NSString stringWithFormat:@"%@: Yes", self.nameLabel.text];
    
    [self updateParseWithSwipeDirection:YES];

    [self nextPerson];
}

- (void) noPerson {
    self.nameLabel.textColor = [UIColor redColor];
    self.nameLabel.text = [NSString stringWithFormat:@"%@: No", self.nameLabel.text];
    
    [self updateParseWithSwipeDirection:NO];
    
    [self nextPerson];
}

- (void) updateParseWithSwipeDirection:(BOOL)didSwipeRight
{
    NSString *parseFunction, *directionID;
    if(didSwipeRight) {
        parseFunction = @"swipeRight";
        directionID = @"yesFBID";
    }
    else {
        parseFunction = @"swipeLeft";
        directionID = @"noFBID";
    }
    
    NSDictionary *params = @{@"myFBID": self.facebookID,
                             directionID: currentPerson.facebookID};
    
    [PFCloud callFunctionInBackground:parseFunction withParameters:params block:^(NSString *result, NSError *error) {
        if(error) {
            [self showAlert:@"Uh oh" alertMessage:@"Sorry, something went wrong with saving your last swipe" buttonName:@"Ok"];
        }
        else {
            NSLog(@"%@\t%@", parseFunction, result);
        }
    }];
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
                    self.draggableView = [[SwipeDraggableView alloc] init:currentPerson nameLabel:self.nameLabel photo:[UIImage imageWithData:data]];
                    self.draggableView.delegate = self;
                    
                    self.nameLabel.text = currentPerson.name;
                    
                    [self.view addSubview:self.draggableView];
                    
                    int imageSize = 300;
                    
                    self.draggableView.frame = CGRectMake((self.view.frame.size.width - imageSize)/2, (self.view.frame.size.height - imageSize)/2, imageSize, imageSize);
                    
                    [self.draggableView setCenter:CGPointMake(CGRectGetMidX(self.view.bounds), CGRectGetMidY(self.view.bounds))];
                    self.nameLabel.textColor = [UIColor blackColor];
                    self.nameLabel.text = [NSString stringWithFormat:@"%@, %@, %@", currentPerson.name, currentPerson.grade, currentPerson.highSchool];
                    self.nameLabel.numberOfLines = 2;
                    self.nameLabel.adjustsFontSizeToFitWidth = YES;
                    
                    
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
    
    [self.loadingAnimation2 show];
    
    [PFCloud callFunctionInBackground:@"getMatches" withParameters:@{@"myFBID": self.facebookID} block:^(NSArray *matches, NSError *error) {
        
        if(error) {
            [self showAlert:@"Uh oh" alertMessage:@"Sorry, something went wrong. Please try again" buttonName:@"Ok"];
            [self.loadingAnimation2 hide];
            NSLog(error.description);
            return;
        }
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^(void) {
            NSMutableArray *officialMatches = [[NSMutableArray alloc] init];
            
            for(NSDictionary *match in matches) {
                MatchedPerson *matched = [[MatchedPerson alloc] initWithEverything:match];
                [officialMatches addObject:matched];
            }
            
            dispatch_async(dispatch_get_main_queue(), ^(void) {
                [self.loadingAnimation2 hide];
                
                self.peopleAccepted = [[PeopleAcceptedViewController alloc] initWithNibName:@"PeopleAcceptedViewController" bundle:[NSBundle mainBundle] matchedPeople:officialMatches];
                self.modalPresentationStyle = UIModalPresentationFullScreen;
                [self presentViewController:self.peopleAccepted animated:YES completion:nil];
            });
        });
    }];
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
