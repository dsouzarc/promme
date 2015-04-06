//
//  LogInViewController.m
//  PromMe
//
//  Created by Ryan D'souza on 4/6/15.
//  Copyright (c) 2015 Ryan D'souza. All rights reserved.
//

#import "LogInViewController.h"
#import "MainPromMePageViewController.h"
#import "PQFCirclesInTriangle.h"
#import "UICKeyChainStore.h"
#import "Person.h"

@interface LogInViewController ()

@property (strong, nonatomic) IBOutlet FBSDKLoginButton *loginButton;

@property (strong, nonatomic) PQFCirclesInTriangle *loadingCircles;
@property (strong, nonatomic) UICKeyChainStore *keyChain;

@property (strong, nonatomic) NSMutableArray *listOfFriends;

@property (strong, nonatomic) NSString *facebookID;
@property (strong, nonatomic) NSString *myName;
@property (strong, nonatomic) NSString *linkToProfilePicture;

@end

@implementation LogInViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.loginButton.delegate = self;
    [FBSDKProfile enableUpdatesOnAccessTokenChange:YES];
    
    NSArray *permissions = @[@"public_profile", @"email", @"user_friends", @"read_custom_friendlists"];
    
    self.loginButton.readPermissions = permissions;
    
    self.loadingCircles = [[PQFCirclesInTriangle alloc] initLoaderOnView:self.view];
    self.loadingCircles.label.text = @"Creating account...";
    self.loadingCircles.borderWidth = 5.0;
    self.loadingCircles.maxDiam = 200.0;
    self.loadingCircles.loaderColor = [UIColor blueColor];
    [self.loadingCircles show];
    
    //If we have successfully logged into Facebook
    if ([FBSDKAccessToken currentAccessToken]) {
        NSLog(@"Logged in");
        [self getFacebookIDAndName];
    }
    else {
        FBSDKLoginManager *loginManager = [[FBSDKLoginManager alloc] init];
        [loginManager logInWithReadPermissions:permissions handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
            if(!error) {
                NSLog(@"Logged in");
                [self getFacebookIDAndName];
            }
        }];
    }

}

- (void) getFacebookIDAndName
{
    //GET AND SAVE MY USERNAME AND INFORMATION
    [[[FBSDKGraphRequest alloc] initWithGraphPath:@"/me" parameters:nil]
     startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
         NSLog(@"HERE: ");
         if(error) {
             NSLog(@"ERROR: %@", error.description);
         }
         else {
             NSDictionary *goodResult = (NSDictionary*)result;
             
             self.facebookID = goodResult[@"id"];
             self.myName = [NSString stringWithFormat:@"%@ %@", goodResult[@"first_name"], goodResult[@"last_name"]];
             
             self.keyChain[@"facebookID"] = self.facebookID;
             self.keyChain[@"myName"] = self.myName;
             
             NSLog(@"GOOD: %@\t%@", self.myName, self.facebookID);
             
             [self getProfilePictureLink];
             [self getFacebookFriends];
         }
     }];
}

- (void) getProfilePictureLink
{
    [[[FBSDKGraphRequest alloc] initWithGraphPath:@"/me/picture?redirect=false" parameters:nil]
     startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
         NSLog(@"HERE: ");
         if(error) {
             NSLog(@"ERROR: %@", error.description);
         }
         else {
             NSDictionary *goodResult = (NSDictionary*)((NSDictionary*)result)[@"data"];
             self.linkToProfilePicture = goodResult[@"url"];
         }
     }];
}

- (void) getFacebookFriends
{
    //GET LIST OF FRIENDS
    NSString *urlRequest = @"/me/taggable_friends?fields=name,picture.width(300),limit=500";
    
    [[[FBSDKGraphRequest alloc] initWithGraphPath:urlRequest parameters:nil] startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
        if(error) {
            NSLog(@"ERROR AT USER TAGGABLE");
            NSLog(error.description);
        }
        
        else {
            NSDictionary *formattedResults = (NSDictionary*) result;
            NSArray *people = [formattedResults objectForKey:@"data"];
            NSDictionary *pagingInformation = [formattedResults objectForKey:@"paging"];
            
            [self addPeople:people];
            [self recursivelyAddPeople:pagingInformation[@"next"]];
        }
        
    }];
}

- (void) recursivelyAddPeople:(NSString*)url
{
    NSLog(@"Still working... %ld", (long)self.listOfFriends.count);
    NSData *data = [[NSString stringWithContentsOfURL:[NSURL URLWithString:url] encoding:NSUTF8StringEncoding error:nil] dataUsingEncoding:NSUTF8StringEncoding];
    
    NSDictionary *formattedResults = (NSDictionary*)[NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    
    NSArray *people = [formattedResults objectForKey:@"data"];
    [self addPeople:people];
    NSDictionary *pagingInformation = [formattedResults objectForKey:@"paging"];
    
    if(pagingInformation && pagingInformation[@"next"]) {
        [self recursivelyAddPeople:pagingInformation[@"next"]];
    }
    
    else {
        
        //CREATE THE ACCOUNT
        NSDictionary *params = @{@"userName": self.myName,
                                 @"fbID": self.facebookID,
                                 @"userID": self.linkToProfilePicture};
        [PFCloud callFunctionInBackground:@"addUser" withParameters:params block:^(NSString *response, NSError *error) {
            if(error) {
                NSLog(@"ERROR SAVING");
            }
            else {
                NSLog(@"ACCOUNT CREATED");
                
                //SAVE THE DATA
                [[NSUserDefaults standardUserDefaults] setObject:[NSKeyedArchiver archivedDataWithRootObject:self.listOfFriends] forKey:@"savedFriends"];
                
                MainPromMePageViewController *mainPage = [[MainPromMePageViewController alloc] initWithNibName:@"MainPromMePageViewController" bundle:[NSBundle mainBundle]];
                self.view.window.rootViewController = mainPage;
            }
        }];
    }
}

- (NSArray*)peopleToDictionary
{
    NSMutableArray *array = [[NSMutableArray alloc] init];
    
    for(Person *person in self.listOfFriends) {
        [array addObject:person.toDictionary];
    }
    
    return array;
}

- (void) addPeople:(NSArray*)people
{
    for(NSDictionary *person in people) {
        
        @try {
            [self.listOfFriends addObject:[[Person alloc] initWithDictionary:person]];
        }
        @catch (NSException *exception) {
            NSLog(@"EXCEPTION ADDING: %@", exception.reason);
        }
    }
}

- (void) loginButton:(FBSDKLoginButton *)loginButton didCompleteWithResult:(FBSDKLoginManagerLoginResult *)result error:(NSError *)error
{
    if(!error) {
        NSLog(@"Successful login");
        [FBSDKProfile enableUpdatesOnAccessTokenChange:YES];
        
        [self getFacebookFriends];
        [self getFacebookIDAndName];
    }
    else {
        NSLog(@"Unsuccessful login");
    }
}

- (void) loginButtonDidLogOut:(FBSDKLoginButton *)loginButton
{
    NSLog(@"LOGGED OUT");
    [self viewDidLoad];
}

- (instancetype) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if(self) {
        self.keyChain = [[UICKeyChainStore alloc] init];
        self.listOfFriends = [[NSMutableArray alloc] init];
    }
    
    return self;
}

@end
