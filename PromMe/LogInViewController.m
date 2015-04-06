//
//  LogInViewController.m
//  PromMe
//
//  Created by Ryan D'souza on 4/6/15.
//  Copyright (c) 2015 Ryan D'souza. All rights reserved.
//

#import "LogInViewController.h"
#import "MainPromMePageViewController.h"
#import "PQFBouncingBalls.h"
#import "UICKeyChainStore.h"
#import "Person.h"

@interface LogInViewController ()

@property (strong, nonatomic) IBOutlet FBSDKLoginButton *loginButton;

@property (strong, nonatomic) PQFBouncingBalls *loadingAnimation;
@property (strong, nonatomic) UICKeyChainStore *keyChain;

@property (strong, nonatomic) NSMutableArray *listOfFriends;

@property (strong, nonatomic) NSString *facebookID;
@property (strong, nonatomic) NSString *myName;

@end

@implementation LogInViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.loginButton.readPermissions = @[@"public_profile", @"email", @"user_friends", @"read_custom_friendlists"];
    
    //If we have successfully logged into Facebook
    if ([FBSDKAccessToken currentAccessToken]) {
        
        [self.loadingAnimation show];
        
        //GET AND SAVE MY USERNAME AND INFORMATION
        [[[FBSDKGraphRequest alloc] initWithGraphPath:@"/me/" parameters:nil]
         startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
             
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
             }
         }];
        
        //GET LIST OF FRIENDS
        NSString *urlRequest = @"/me/taggable_friendsfields=name,picture.width(300),limit=500";
        
        [[[FBSDKGraphRequest alloc] initWithGraphPath:urlRequest parameters:nil] startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection,
                                                            id result, NSError *error) {
            if(error) {
                NSLog(@"ERROR AT USER TAGGABLE");
                NSLog(error.description);
            }
            
            else {
                NSDictionary *formattedResults = (NSDictionary*)result;
                
                NSArray *people = [formattedResults objectForKey:@"data"];
                
                for(NSDictionary *person in people) {
                    [self.listOfFriends addObject:[[Person alloc] initWithDictionary:person]];
                }
                
                NSDictionary *paging = [formattedResults objectForKey:@"paging"];
                
                NSLog(paging[@"next"]);
                
                NSString *html = [NSString stringWithContentsOfURL:[NSURL URLWithString:paging[@"next"]] encoding:NSUTF8StringEncoding error:nil];
                
                NSLog(@"RESULT\n\n%@", html);
                
                NSString *url = [NSString stringWithFormat:@"/%@/photos", people[0]];
                
                [[[FBSDKGraphRequest alloc] initWithGraphPath:url parameters:nil] startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
                    if(error) {
                        NSLog(@"ERROR GETTING PHOTOS");
                        NSLog(error.description);
                    }
                    else {
                        NSLog(@"SUCCESS");
                        NSDictionary *results = (NSDictionary*)result;
                        
                        NSArray *links = results[@"data"];
                        
                        for(NSString *string in links) {
                            NSLog(@"HERE STRINGS: %@", string);
                        }
                    }
                }];
                
                NSDictionary *aPerson = (NSDictionary*)people[0];
                
                NSLog(@"ID: %@", aPerson[@"id"]);
                
                url = [NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?width=140&height=110", aPerson[@"id"]];
                
                html = [NSString stringWithContentsOfURL:[NSURL URLWithString:url] encoding:NSUTF8StringEncoding error:nil];
                
                NSLog(@"LATEST PHOTOS: %@", html);
            }
            
        }];
    }
    else {
        NSLog(@"NOPE!");
    }

}

- (void) loginButton:(FBSDKLoginButton *)loginButton didCompleteWithResult:(FBSDKLoginManagerLoginResult *)result error:(NSError *)error
{
    if(!error) {
        MainPromMePageViewController *mainPromMe = [[MainPromMePageViewController alloc] initWithNibName:@"MainPromMePageViewController" bundle:[NSBundle mainBundle]];
        
        self.view.window.rootViewController = mainPromMe;
    }
    else {
        NSLog(@"NOPE");
    }
}

- (void) loginButtonDidLogOut:(FBSDKLoginButton *)loginButton
{
    [self viewDidLoad];
}

- (instancetype) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if(self) {
        self.loadingAnimation = [[PQFBouncingBalls alloc] initLoaderOnView:self.view];
        
        self.keyChain = [[UICKeyChainStore alloc] init];
        self.listOfFriends = [[NSMutableArray alloc] init];
    }
    
    return self;
}

@end
