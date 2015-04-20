//
//  PeopleAcceptedViewController.m
//  PromMe
//
//  Created by Ryan D'souza on 4/8/15.
//  Copyright (c) 2015 Ryan D'souza. All rights reserved.
//

#import "PeopleAcceptedViewController.h"

#define TABLE_IDENTIFIER "MatchedPersonTableViewCell"

@interface PeopleAcceptedViewController ()

@property (strong, nonatomic) IBOutlet UITableView *mainView;

@property (strong, nonatomic) UILabel *noMatchesLabel;

@property (strong, nonatomic) NSArray *people;

- (IBAction)backClick:(id)sender;

@end

@implementation PeopleAcceptedViewController

- (instancetype) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil matchedPeople:(NSArray *)matchedPeople
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if(self) {
        self.people = matchedPeople;
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.mainView registerNib:[UINib nibWithNibName:@"MatchedPersonTableViewCell"
                                              bundle:[NSBundle mainBundle]]
        forCellReuseIdentifier:@TABLE_IDENTIFIER];
}

-(UIImage*)resizeImage:(UIImage *)image imageSize:(CGSize)size
{
    UIGraphicsBeginImageContext(size);
    [image drawInRect:CGRectMake(0,0,size.width,size.height)];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

- (IBAction)backClick:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void) showAlert:(NSString*)alertTitle alertMessage:(NSString*)alertMessage buttonName:(NSString*)buttonName
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:alertTitle
                                                        message:alertMessage
                                                       delegate:nil
                                              cancelButtonTitle:buttonName
                                              otherButtonTitles:nil, nil];
    [alertView show];
}

/****************************/
//    TABLEVIEW DELEGATES
/****************************/

- (UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    MatchedPersonTableViewCell *cell = [self.mainView dequeueReusableCellWithIdentifier:@TABLE_IDENTIFIER];
    
    if(cell == nil) {
        cell = [[MatchedPersonTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@TABLE_IDENTIFIER];
    }
    
    MatchedPerson *person = self.people[indexPath.row];
    
    CGSize profilePhotoSize = CGSizeMake(80, 75);
    
    cell.profilePictureView.image = [self resizeImage:person.profilePicture imageSize:profilePhotoSize];
    cell.nameLabel.text = person.name;
    cell.gradeLabel.text = person.grade;
    cell.schoolLabel.text = person.highSchool;
    
    cell.profilePictureView.layer.cornerRadius = 30;
    cell.profilePictureView.layer.masksToBounds = YES;
    
    cell.nameLabel.adjustsFontSizeToFitWidth = YES;
    cell.gradeLabel.adjustsFontSizeToFitWidth = YES;
    cell.schoolLabel.adjustsFontSizeToFitWidth = YES;
    
    return cell;
}

- (CGFloat) tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 116;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    //TODO: NO MATCHES
    if(self.people.count == 1) {
        self.noMatchesLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
        self.noMatchesLabel.text = @"Sorry, but you have no matches";
        self.noMatchesLabel.textAlignment = NSTextAlignmentCenter;
        self.mainView.backgroundView = self.noMatchesLabel;
        self.mainView.separatorStyle = UITableViewCellSeparatorStyleNone;
        return 0;
    }
    
    return self.people.count;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    MatchedPerson *person = self.people[indexPath.row];
    
    MFMessageComposeViewController *messageController = [[MFMessageComposeViewController alloc] init];
    messageController.recipients = [NSArray arrayWithObjects:person.phoneNumber, nil];
    messageController.messageComposeDelegate = self;
    
    if([MFMessageComposeViewController canSendText]) {
        [self presentViewController:messageController animated:YES completion:nil];
    }
    else {
        NSString *message = [NSString stringWithFormat:@"Sorry, we could not send that person a text. Their phone number is: %@", person.phoneNumber];
        [self showAlert:@"Uh oh" alertMessage:message buttonName:@"Ok"];
    }
}


/****************************/
//    MESSAGE COMPOSE DELEGATE
/****************************/

- (void) messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
{
    [self dismissViewControllerAnimated:YES completion:nil];
    if(result == MessageComposeResultSent) {
        [self showAlert:@"Woot Woot" alertMessage:@"Awesome!" buttonName:@"Let's keep on going"];
    }
}

@end
