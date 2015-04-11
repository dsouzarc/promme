//
//  LogInViewController.m
//  PromMe
//
//  Created by Ryan D'souza on 4/6/15.
//  Copyright (c) 2015 Ryan D'souza. All rights reserved.
//

#import "LogInViewController.h"

@interface LogInViewController ()

extern const int NUM_PROFILE_PHOTOS = 4;
extern const int PROFILE_PHOTO_SIZE = 300;

@property (strong, nonatomic) IBOutlet FBSDKLoginButton *loginButton;

@property (strong, nonatomic) IBOutlet UITextField *myNameTextField;
@property (strong, nonatomic) IBOutlet UITextField *myHighSchoolTextField;
@property (strong, nonatomic) IBOutlet UITextField *myPhoneNumberTextField;

@property (strong, nonatomic) IBOutlet UIButton *myLocationTextField;

@property (strong, nonatomic) IBOutlet UISegmentedControl *myGradeSegmentedControl;
@property (strong, nonatomic) IBOutlet UISegmentedControl *myGenderSegmentedControl;

@property (strong, nonatomic) IBOutlet UITableView *myProfilePicturesTableView;
@property (strong, nonatomic) IBOutlet UIButton *myLocationButton;

- (IBAction)createAccountClicked:(id)sender;
- (IBAction)findMyLocationClicked:(id)sender;

@property (strong, nonatomic) PQFCirclesInTriangle *loadingCircles;
@property (strong, nonatomic) UICKeyChainStore *keyChain;

@property (strong, nonatomic) NSMutableArray *profilePhotosArray;

@property (strong, nonatomic) NSString *facebookID;


@end

@implementation LogInViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [FBSDKProfile enableUpdatesOnAccessTokenChange:YES];

    
    //If we have successfully logged into Facebook
    /*if ([FBSDKAccessToken currentAccessToken]) {
        NSLog(@"Logged in with access token");
        [self getFacebookIDAndName];
    }
    else {
        FBSDKLoginManager *loginManager = [[FBSDKLoginManager alloc] init];
        [loginManager logInWithReadPermissions:permissions handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
            if(!error) {
                NSLog(@"Logged in");
            }
        }];
    }*/

}

- (void) getFacebookIDAndName
{
    [self.loadingCircles show];
    
    [[[FBSDKGraphRequest alloc] initWithGraphPath:@"/me" parameters:nil]
     startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
         NSLog(@"Completion profile information ");
         if(error) {
             NSLog(@"ERROR: %@", error.description);
         }
         else {
             NSLog(@"Good results");
             NSDictionary *goodResult = (NSDictionary*)result;
             
             if(!result) {
                 NSLog(@"NO RESULT");
             }
             
             self.facebookID = goodResult[@"id"];
             self.myNameTextField.text = [NSString stringWithFormat:@"%@ %@", goodResult[@"first_name"], goodResult[@"last_name"]];
         }
     }];
}

- (void) getProfilePictureLink
{
    [[[FBSDKGraphRequest alloc] initWithGraphPath:@"/me/picture?redirect=false" parameters:nil]
     startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
         NSLog(@"Completion profile photo: ");
         if(error) {
             NSLog(@"ERROR: %@", error.description);
         }
         else {
             
             if(result) {
                 
                 NSLog(@"Is result");
                 NSDictionary *resultItems = (NSDictionary*)result;
                 
                 if(resultItems) {
                     NSLog(@"Is result items");
                     NSDictionary *link = resultItems[@"data"];
                     
                     if(link) {
                         self.profilePhotosArray[0] = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:link[@"url"]]]];
                         [self.myProfilePicturesTableView reloadData];
                         
                     }
                     else {
                         NSLog(@"NO URL");
                     }
                 }
                 else {
                     NSLog(@"No data");
                 }
                 
                 [self.loadingCircles hide];
             }
         }
     }];
}


- (void) loginButton:(FBSDKLoginButton *)loginButton didCompleteWithResult:(FBSDKLoginManagerLoginResult *)result error:(NSError *)error
{
    if(!error) {
        NSLog(@"Successful login");
        [FBSDKProfile enableUpdatesOnAccessTokenChange:YES];
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
        self.profilePhotosArray = [[NSMutableArray alloc] initWithCapacity:NUM_PROFILE_PHOTOS];
        
        self.loadingCircles = [[PQFCirclesInTriangle alloc] initLoaderOnView:self.view];
        self.loadingCircles.label.text = @"Fetching account information...";
        self.loadingCircles.borderWidth = 4.0;
        self.loadingCircles.maxDiam = 250.0;
        self.loadingCircles.numberOfCircles = 9;
        self.loadingCircles.loaderColor = [UIColor blueColor];
        
        NSArray *permissions = @[@"public_profile", @"email", @"user_friends", @"user_photos"];
        self.loginButton.readPermissions = permissions;
    }
    
    return self;
}

- (IBAction)createAccountClicked:(id)sender {
    
}

- (IBAction)findMyLocationClicked:(id)sender {
    
}

/****************************/
//   TABLEVIEW DELEGATES
/****************************/

static NSString *cellIdentifier = @"ProfilePictureCellIdentifier";

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return NUM_PROFILE_PHOTOS;
}

- (UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if(!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    if(self.profilePhotosArray && self.profilePhotosArray.count > indexPath.row && self.profilePhotosArray[indexPath.row]) {
        cell.imageView.image = (UIImage*)self.profilePhotosArray[indexPath.row];
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return PROFILE_PHOTO_SIZE;
}


/****************************/
//    TEXTFIELD DELEGATES
/****************************/

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    //Add some glow effect
    textField.layer.cornerRadius=8.0f;
    textField.layer.masksToBounds=YES;
    textField.layer.borderColor=[[UIColor whiteColor]CGColor];
    textField.layer.borderWidth= 2.0f;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    //Remove the glow effect
    textField.layer.borderColor=[[UIColor clearColor]CGColor];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

@end
