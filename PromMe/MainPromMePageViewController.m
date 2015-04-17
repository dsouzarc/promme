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

- (IBAction)yesIcon:(id)sender;
- (IBAction)noIcon:(id)sender;

- (IBAction)searchPreferencesButton:(id)sender;
- (IBAction)matchesClicked:(id)sender;

@property (strong, nonatomic) NSMutableArray *availablePeopleToSwipe;
@property (strong, nonatomic) NSArray *friendsList;
@property (strong, nonatomic) NSString *facebookID;

@property (strong, nonatomic) PQFCirclesInTriangle *loadingAnimation;

@end

@implementation MainPromMePageViewController

static int counter = 0;

static int randomPerson;

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
    [self getPeople];
}

- (void) getPeople {
    
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

- (void) showNextPerson {
    
    Person *nextPerson = [self.availablePeopleToSwipe firstObject];
    [self.availablePeopleToSwipe removeObject:nextPerson];
    
    NSDictionary *parameters = @{@"facebookID": nextPerson.facebookID,
                                 @"pictureNumber": @0
                                 };
    
    [PFCloud callFunctionInBackground:@"getUserPhoto" withParameters:parameters block:^(PFFile *file, NSError *error) {
        
        if(!error) {
            
            [file getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                if(!error) {
                    NSLog(@"NO ERROR");
                    self.draggableView = [[SwipeDraggableView alloc] init:self.friendsList[randomPerson] nameLabel:self.nameLabel photo:[UIImage imageWithData:data]];
                    self.draggableView.delegate = self;
                    self.nameLabel.text = ((Person*)self.friendsList[randomPerson]).name;
                    
                    [self.view addSubview:self.draggableView];
                    
                    int imageSize = 300;
                    
                    self.draggableView.frame = CGRectMake((self.view.frame.size.width - imageSize)/2, (self.view.frame.size.height - imageSize)/2, imageSize, imageSize);
                    
                    [self.draggableView setCenter:CGPointMake(CGRectGetMidX(self.view.bounds), CGRectGetMidY(self.view.bounds))];
                    self.nameLabel.textColor = [UIColor blackColor];
                    counter++;
                    randomPerson = arc4random() % self.friendsList.count;
                }
                else {
                    NSLog(@"ERROR: %@", error.description);
                }
            }];
        }
        else {
            NSLog(@"ERROR: %@", error.description);
        }
    }];
}

- (IBAction)matchesClicked:(id)sender {
    self.peopleAccepted = [[PeopleAcceptedViewController alloc] initWithNibName:@"PeopleAcceptedViewController" bundle:[NSBundle mainBundle]];
    
    [self.peopleAccepted showInView:self.view shouldAnimate:YES];
}


@end
