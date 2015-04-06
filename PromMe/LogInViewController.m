//
//  LogInViewController.m
//  PromMe
//
//  Created by Ryan D'souza on 4/6/15.
//  Copyright (c) 2015 Ryan D'souza. All rights reserved.
//

#import "LogInViewController.h"
#import "MainPromMePageViewController.h"

@interface LogInViewController ()

@property (strong, nonatomic) IBOutlet FBSDKLoginButton *loginButton;

@end

@implementation LogInViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.loginButton.readPermissions = @[@"public_profile", @"email", @"user_friends", @"read_custom_friendlists"];
    
    if ([FBSDKAccessToken currentAccessToken]) {
        
        [[[FBSDKGraphRequest alloc] initWithGraphPath:@"/me/taggable_friends?fields=name,picture.width(300),limit=500" parameters:nil] startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
            if(error) {
                NSLog(@"ERROR AT USER TAGGABLE");
                NSLog(error.description);
            }
            
            else {
                
                NSDictionary *formattedResults = (NSDictionary*)result;
                
                NSArray *people = [formattedResults objectForKey:@"data"];
                
                for(NSDictionary *person in people) {
                    NSLog(person.description);
                }
                
                NSLog(@"SIZE: %ld", (long)people.count);
                
                NSDictionary *paging = [formattedResults objectForKey:@"paging"];
                
                NSLog(paging[@"next"]);
                
                NSString *html = [NSString stringWithContentsOfURL:[NSURL URLWithString:paging[@"next"]] encoding:NSUTF8StringEncoding error:nil];
                
                NSLog(@"RESULT\n\n%@", html);
            }
            
        }];
    }
    else {
        NSLog(@"NOPE!");
    }

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

@end
