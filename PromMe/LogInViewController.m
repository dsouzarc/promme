//
//  LogInViewController.m
//  PromMe
//
//  Created by Ryan D'souza on 4/6/15.
//  Copyright (c) 2015 Ryan D'souza. All rights reserved.
//

#import "LogInViewController.h"

@interface LogInViewController ()

extern const int NUM_PROFILE_PHOTOS = 5;
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
    
    [self.myProfilePicturesTableView registerNib:[UINib nibWithNibName:@"ProfilePictureTableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:cellIdentifier];
    
    //[FBSDKProfile enableUpdatesOnAccessTokenChange:YES];
    
    [self getFacebookInformation];
    
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
    }
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
                [self.profilePhotosArray addObject:[UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:source]]]];
                
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
                         [self.profilePhotosArray addObject:[UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:link[@"url"]]]]];
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

- (instancetype) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if(self) {
        self.keyChain = [[UICKeyChainStore alloc] init];
        self.profilePhotosArray = [[NSMutableArray alloc] init]; //initWithCapacity:NUM_PROFILE_PHOTOS];
        
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
