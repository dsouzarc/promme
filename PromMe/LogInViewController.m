//
//  LogInViewController.m
//  PromMe
//
//  Created by Ryan D'souza on 4/6/15.
//  Copyright (c) 2015 Ryan D'souza. All rights reserved.
//

#import "LogInViewController.h"

@interface LogInViewController () <CLLocationManagerDelegate>

extern const int NUM_PROFILE_PHOTOS = 5;
extern const int PROFILE_PHOTO_SIZE = 300;

@property (strong, nonatomic) IBOutlet FBSDKLoginButton *loginButton;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;

@property (strong, nonatomic) IBOutlet UITextField *myNameTextField;
@property (strong, nonatomic) IBOutlet UITextField *myHighSchoolTextField;
@property (strong, nonatomic) IBOutlet UITextField *myPhoneNumberTextField;

@property (strong, nonatomic) IBOutlet UISegmentedControl *myGradeSegmentedControl;
@property (strong, nonatomic) IBOutlet UISegmentedControl *myGenderSegmentedControl;

@property (strong, nonatomic) IBOutlet UITableView *myProfilePicturesTableView;
@property (strong, nonatomic) IBOutlet UIButton *myLocationButton;

@property (strong, nonatomic) NSMutableArray *profilePhotosArray;
@property (strong, nonatomic) NSMutableArray *hasCustomizedPhoto;

@property (strong, nonatomic) NSString *facebookID;
@property (strong, nonatomic) PFGeoPoint *homeLocation;

@property (strong, nonatomic) ChooseAddressViewController *homeAddressView;

@property (strong, nonatomic) PQFCirclesInTriangle *loadingCircles;
@property (strong, nonatomic) UICKeyChainStore *keyChain;

- (IBAction)createAccountClicked:(id)sender;
- (IBAction)findMyLocationClicked:(id)sender;

@end

@implementation LogInViewController

- (instancetype) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if(self) {
        self.keyChain = [[UICKeyChainStore alloc] init];
        self.profilePhotosArray = [self blankImages]; //initWithCapacity:NUM_PROFILE_PHOTOS];
        self.hasCustomizedPhoto = [self hasNotCustomizedPhoto];
        
        self.loadingCircles = [[PQFCirclesInTriangle alloc] initLoaderOnView:self.view];
        self.loadingCircles.label.text = @"Fetching account information...";
        self.loadingCircles.borderWidth = 4.0;
        self.loadingCircles.maxDiam = 250.0;
        self.loadingCircles.numberOfCircles = 9;
        self.loadingCircles.loaderColor = [UIColor blueColor];
        self.loadingCircles.label.textColor = [UIColor blackColor];
    }
    return self;
}

- (void)viewDidLoad {
    
    self.scrollView.contentSize = CGSizeMake(self.view.bounds.size.width, self.scrollView.contentSize.height);
    [super viewDidLoad];
    
    NSArray *permissions = @[@"public_profile", @"email", @"user_friends", @"user_photos"];
    self.loginButton.readPermissions = permissions;
    
    self.homeAddressView = [[ChooseAddressViewController alloc] initWithNibName:@"ChooseAddressViewController" bundle:[NSBundle mainBundle]];
    self.homeAddressView.delegate = self;
    
    [self.myProfilePicturesTableView registerNib:[UINib nibWithNibName:@"ProfilePictureTableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:cellIdentifier];
    
    //[FBSDKProfile enableUpdatesOnAccessTokenChange:YES];
    
    /*[self getFacebookInformation];
    
    //If we have successfully logged into Facebook
    if ([FBSDKAccessToken currentAccessToken]) {
        NSLog(@"Logged in with access token");
        [self getFacebookInformation];
    }
    else {
        FBSDKLoginManager *loginManager = [[FBSDKLoginManager alloc] init];
        [loginManager logInWithReadPermissions:self.loginButton.readPermissions handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
            if(!error) {
                NSLog(@"Logged in");
                [self getFacebookInformation];
            }
        }];
    }*/
}

- (void) chooseAddressViewController:(ChooseAddressViewController *)viewController chosenAddress:(PFGeoPoint *)chosenAddress addressName:(NSString *)addressName
{
    self.homeLocation = chosenAddress;
    [self.myLocationButton setTitle:addressName forState:UIControlStateNormal];
}

- (void) getFacebookInformation
{
    [self getFacebookIDAndName];
    //[self getProfilePictureLink];
    [self getProfilePictureAlbumID];
}

- (void) getProfilePictureAlbumID
{
    [[[FBSDKGraphRequest alloc] initWithGraphPath:@"/me/albums?fields=name&limit=30" parameters:nil] startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
        
        if(error) {
            
        }
        
        NSArray *albums = ((NSDictionary*)result)[@"data"];
        
        for(NSDictionary *album in albums) {
            if([album[@"name"] isEqualToString:@"Profile Pictures"]) {
                NSString *profilePicturesID = album[@"id"];
                NSLog(@"PROFILE PICTURES ID: %@", profilePicturesID);
                [self getRecentProfilePhotos:profilePicturesID];
            }
        }
    }];
}

static int profilePictureCounter = 0;

- (void) getRecentProfilePhotos:(NSString*)profilePictureAlbumID
{
    NSString *path = [NSString stringWithFormat:@"%@/photos?fields=album,id,link", profilePictureAlbumID];
    [[[FBSDKGraphRequest alloc] initWithGraphPath:path parameters:nil] startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
        
        NSArray *albums = ((NSDictionary*)result)[@"data"];
        
        for(int i = 0; i < NUM_PROFILE_PHOTOS && i < albums.count; i++) {
            NSString *profilePhotoID = ((NSDictionary*)albums[i])[@"id"];
            [self addProfilePhotoToArray:profilePhotoID];
        }
    }];
}

- (void) addProfilePhotoToArray:(NSString*)photoID
{
    NSString *path = [NSString stringWithFormat:@"%@?width=300", photoID];
    
    [[[FBSDKGraphRequest alloc] initWithGraphPath:path parameters:nil] startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
        
        NSArray *photoVersions = ((NSDictionary*)result)[@"images"];
        
        for(NSDictionary *photo in photoVersions) {
            int photoWidth = [photo[@"width"] intValue];
            
            //Photo width bigger than 300, less than 400
            if(photoWidth > PROFILE_PHOTO_SIZE && photoWidth <= (PROFILE_PHOTO_SIZE + 100)) {
                NSString *source = photo[@"source"];
                self.profilePhotosArray[profilePictureCounter] = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:source]]];
                self.hasCustomizedPhoto[profilePictureCounter] = [NSNumber numberWithBool:YES];
                profilePictureCounter++;
                
                [self.myProfilePicturesTableView reloadData];
            }
        }
    }];
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
         [self.loadingCircles hide];
     }];
}

- (void) getProfilePictureLink
{
    [[[FBSDKGraphRequest alloc] initWithGraphPath:@"/me/picture?redirect=false&width=300" parameters:nil]
     startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
         if(error) {
             NSLog(@"ERROR: %@", error.description);
         }
         else {
             if(result) {
                 NSDictionary *resultItems = (NSDictionary*)result;
                 if(resultItems) {
                     NSDictionary *link = resultItems[@"data"];
                     if(link) {
                         
                         self.profilePhotosArray[profilePictureCounter] = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:link[@"url"]]]];
                         self.hasCustomizedPhoto[profilePictureCounter] = [NSNumber numberWithBool:YES];
                         profilePictureCounter++;
                         
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

- (NSString*) getGender
{
    switch(self.myGenderSegmentedControl.selectedSegmentIndex) {
        case 0:
            return @"Male";
        case 1:
            return @"Female";
        case 2:
            return @"Other";
        default:
            return @"Other";
    }
}

- (NSString*) getGrade
{
    switch(self.myGradeSegmentedControl.selectedSegmentIndex) {
        case 0:
            return @"Freshman";
        case 1:
            return @"Sophomore";
        case 2:
            return @"Junior";
        case 3:
            return @"Senior";
        default:
            return @"Senior";
    }
}

- (IBAction)createAccountClicked:(id)sender {
    
    //Validate all fields
    if(self.myNameTextField.text.length < 3) {
        [self showAlert:@"Invalid Information" alertMessage:@"Please enter a valid name" buttonName:@"Ok"];
        return;
    }
    else if(![self.myNameTextField.text containsString:@" "]) {
        [self showAlert:@"Invalid Information" alertMessage:@"Please enter your first and last name" buttonName:@"Ok"];
        return;
    }
    if(self.myHighSchoolTextField.text.length < 6) {
        [self showAlert:@"Invalid Information" alertMessage:@"Please enter a valid high school name" buttonName:@"Ok"];
        return;
    }
    if(self.myPhoneNumberTextField.text.length != 10) {
        [self showAlert:@"Invalid Information" alertMessage:@"Please enter a valid phone number" buttonName:@"Ok"];
        return;
    }
    if(!self.facebookID) {
        [self showAlert:@"Invalid Information" alertMessage:@"Please login with Facebook" buttonName:@"Ok"];
        return;
    }
    for(int i = 0; i < self.hasCustomizedPhoto.count; i++) {
        if(![self.hasCustomizedPhoto[i] boolValue]) {
            [self showAlert:@"Invalid Information" alertMessage:@"Please customize all profile photos in the ScrollView" buttonName:@"Ok"];
            return;
        }
    }
    if(!self.homeLocation) {
        [self showAlert:@"Invalid Information" alertMessage:@"Please choose a valid home town" buttonName:@"Ok"];
        return;
    }
    
    self.loadingCircles.label.text = @"Saving profile information";
    [self.loadingCircles show];
    
    NSDictionary *params = @{@"userFullName": self.myNameTextField.text,
                             @"fbID": self.facebookID,
                             @"school": self.myHighSchoolTextField.text,
                             @"phoneNumber": self.myPhoneNumberTextField.text,
                             @"gender": [self getGender],
                             @"grade": [self getGrade],
                             @"currentLocation": self.homeLocation
                             };
    
    [PFCloud callFunctionInBackground:@"addUser" withParameters:params block:^(PFObject *user, NSError *error) {
        if(error) {
            //TODO: Alert: No account made
            NSLog(@"No account: %@", error.description);
            [self.loadingCircles hide];
            return;
        }
        
        self.loadingCircles.label.text = @"Saving profile pictures";
        
        NSString *channel = [NSString stringWithFormat:@"P%@", self.facebookID];
        PFInstallation *installation = [PFInstallation currentInstallation];
        [installation addObject:channel forKey:@"channels"];
        
        [installation saveInBackgroundWithBlock:^(BOOL success, NSError *error) {
            if(success) {
                NSLog(@"Saved FB ID as channel: %@", channel);
            }
        }];
        
        user[@"profile_picture_one"] = [self profilePictureToFile:0];
        user[@"profile_picture_two"] = [self profilePictureToFile:1];
        user[@"profile_picture_three"] = [self profilePictureToFile:2];
        user[@"profile_picture_four"] = [self profilePictureToFile:3];
        user[@"profile_picture_five"] = [self profilePictureToFile:4];
        
        self.keyChain[@"facebookid"] = self.facebookID;
        self.keyChain[@"name"] = self.myNameTextField.text;
        self.keyChain[@"phoneNumber"] = self.myPhoneNumberTextField.text;
        self.keyChain[@"school"] = self.myHighSchoolTextField.text;
        self.keyChain[@"gender"] = [self getGender];
        self.keyChain[@"grade"] = [self getGrade];
        
        [user saveInBackgroundWithBlock:^(BOOL success, NSError *error) {
            
            [self.loadingCircles hide];
            
            if(success) {
                NSLog(@"Profile pictures saved");
                
                MainPromMePageViewController *mainPromMe = [[MainPromMePageViewController alloc] initWithNibName:@"MainPromMePageViewController" bundle:[NSBundle mainBundle]];
                [self setModalPresentationStyle:UIModalPresentationOverFullScreen];
                [self presentViewController:mainPromMe animated:YES completion:nil];
            }
        }];
    }];
    
}

- (PFFile*) profilePictureToFile:(NSInteger)profilePictureNumber
{
    UIImage *image = (UIImage*)self.profilePhotosArray[profilePictureNumber];
    
    if(!image) {
        NSLog(@"BAD");
    }
    
    NSString *fileName = [NSString stringWithFormat:@"profilePicture%d", (int)(profilePictureNumber + 1)];
    PFFile *file = [PFFile fileWithName:fileName data:UIImagePNGRepresentation(image)];
    
    if(!file) {
        NSLog(@"No file");
    }
    return file;
}

- (IBAction)findMyLocationClicked:(id)sender {
    //UINavigationController *navigation = [[UINavigationController alloc] initWithRootViewController:self.homeAddressView];
    //[self presentViewController:navigation animated:YES completion:nil];
    [self setModalPresentationStyle:UIModalPresentationPopover];
    [self presentViewController:self.homeAddressView animated:YES completion:nil];
}

- (NSMutableArray*) blankImages
{
    NSMutableArray *blankArray = [[NSMutableArray alloc] initWithCapacity:NUM_PROFILE_PHOTOS];
    
    for(int i = 0; i < NUM_PROFILE_PHOTOS; i++) {
        UIImage *blankImage = [[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"no_picture_image" ofType:@"png"]];
        
        [blankArray setObject:blankImage atIndexedSubscript:i];
    }
    
    return blankArray;
}

- (NSMutableArray*) hasNotCustomizedPhoto
{
    NSMutableArray *array = [[NSMutableArray alloc] initWithCapacity:NUM_PROFILE_PHOTOS];
    
    for(int i = 0; i < NUM_PROFILE_PHOTOS; i++) {
        array[i] = [NSNumber numberWithBool:NO];
    }
    return array;
}

/****************************/
//   FACEBOOK SDK LOGIN DELEGATES
/****************************/

- (void) loginButton:(FBSDKLoginButton *)loginButton didCompleteWithResult:(FBSDKLoginManagerLoginResult *)result error:(NSError *)error
{
    if(!error) {
        NSLog(@"Successful login");
        [FBSDKProfile enableUpdatesOnAccessTokenChange:YES];
        [self getFacebookInformation];
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

/****************************/
//   TABLEVIEW DELEGATES
/****************************/

static int chosenPicture = 0;
static NSString *cellIdentifier = @"ProfilePictureCellIdentifier";

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.profilePhotosArray.count;
}

- (UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ProfilePictureTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if(!cell) {
        cell = [[ProfilePictureTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    if(indexPath.row < self.profilePhotosArray.count) {
        cell.profilePictureView.image = (UIImage*) self.profilePhotosArray[indexPath.row];
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return ((UIImage*) self.profilePhotosArray[indexPath.row]).size.height + 50; //PROFILE_PHOTO_SIZE;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row == 0) {
        [self showAlert:@"Invalid Action" alertMessage:@"Sorry, but you cannot change the first profile picture for verification reasons" buttonName:@"Ok"];
        return;
    }
    
    chosenPicture = (int)indexPath.row;
    
    UIImagePickerController *changePhoto = [[UIImagePickerController alloc] init];
    changePhoto.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    changePhoto.allowsEditing = YES;
    changePhoto.delegate = self;
    [self presentViewController:changePhoto animated:YES completion:nil];
}

- (void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *selectedImage = info[UIImagePickerControllerEditedImage];
    selectedImage = [self imageWithImage:selectedImage scaledToSize:CGSizeMake(300, 300)];
    self.profilePhotosArray[chosenPicture] = selectedImage;
    self.hasCustomizedPhoto[chosenPicture] = [NSNumber numberWithBool:YES];
    [picker dismissViewControllerAnimated:YES completion:nil];
    [self.myProfilePicturesTableView reloadData];
}

- (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize {
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

- (void) showAlert:(NSString*)alertTitle alertMessage:(NSString*)alertMessage buttonName:(NSString*)buttonName {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:alertTitle
                                                        message:alertMessage
                                                       delegate:nil
                                              cancelButtonTitle:buttonName
                                              otherButtonTitles:nil, nil];
    [alertView show];
}

/****************************/
//    TEXTFIELD DELEGATES
/****************************/

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    //Add some glow effect
    textField.layer.cornerRadius=8.0f;
    textField.layer.masksToBounds=YES;
    textField.layer.borderColor=[[UIColor blueColor]CGColor];
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
