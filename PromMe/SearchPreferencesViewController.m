//
//  SearchPreferencesViewController.m
//  PromMe
//
//  Created by Ryan D'souza on 4/19/15.
//  Copyright (c) 2015 Ryan D'souza. All rights reserved.
//

#import "SearchPreferencesViewController.h"


@interface SearchPreferencesViewController ()

@property (strong, nonatomic) IBOutlet UIView *mainView;

@property (strong, nonatomic) IBOutlet UISwitch *isHighSchoolSwitch;
@property (strong, nonatomic) IBOutlet UITextField *highSchoolTextField;

@property (strong, nonatomic) IBOutlet UISegmentedControl *genderSegmentedControl;

@property (strong, nonatomic) IBOutlet UISwitch *isDistanceSwitch;
@property (strong, nonatomic) IBOutlet UILabel *distanceLabel;
@property (strong, nonatomic) IBOutlet UISlider *distanceSlider;

@property (strong, nonatomic) UICKeyChainStore *keyChain;

- (IBAction)distanceSlider:(id)sender;
- (IBAction)cancel:(id)sender;
- (IBAction)savePreferences:(id)sender;

@end

@implementation SearchPreferencesViewController

- (instancetype) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if(self) {
        self.keyChain = [[UICKeyChainStore alloc] init];
    }
    
    return self;
}

- (IBAction)distanceSlider:(id)sender {
    self.distanceLabel.text = [NSString stringWithFormat:@"Show people within %.2f miles", self.distanceSlider.value];
}

- (IBAction)cancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (void)viewDidLoad
{
    self.view.backgroundColor=[[UIColor grayColor] colorWithAlphaComponent:.6];
    self.mainView.layer.cornerRadius = 15;
    self.mainView.layer.shadowColor = [[UIColor blueColor]CGColor];
    self.mainView.layer.shadowOpacity = 0.8;
    self.mainView.layer.shadowOffset = CGSizeMake(2.0f, 2.0f);

    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapReceived:)];
    [tapGestureRecognizer setDelegate:self];
    [self.view addGestureRecognizer:tapGestureRecognizer];
    
    self.distanceSlider.value = self.keyChain[@"distance"] == nil ? 50.00 : [self.keyChain[@"distance"] floatValue];
    self.highSchoolTextField.text = self.keyChain[@"school"] == nil ? @"" : self.keyChain[@"school"];
    
    if(self.keyChain[@"useHighSchool"]) {
        [self.isHighSchoolSwitch setOn:YES animated:YES];
    }
    else {
        [self.isHighSchoolSwitch setOn:NO animated:YES];
    }
    [self.isHighSchoolSwitch setOn:NO];
    
    
    if(self.keyChain[@"isDistance"]) {
        [self.isDistanceSwitch setOn:YES animated:YES];
    }
    else {
        [self.isDistanceSwitch setOn:NO animated:YES];
    }
    
    if(!self.keyChain[@"genderToShow"]) {
        [self.genderSegmentedControl setSelectedSegmentIndex:0];
    }
    else if([self.keyChain[@"genderToShow"] isEqualToString:@"Male"]) {
        [self.genderSegmentedControl setSelectedSegmentIndex:0];
    }
    else if([self.keyChain[@"genderToShow"] isEqualToString:@"Female"]) {
        [self.genderSegmentedControl setSelectedSegmentIndex:1];
    }
    else {
        [self.genderSegmentedControl setSelectedSegmentIndex:2];
    }
    
    self.distanceLabel.text = [NSString stringWithFormat:@"Show people within %.2f miles", self.distanceSlider.value];
    
    [super viewDidLoad];
}

- (IBAction)savePreferences:(id)sender {
    
    [self.delegate searchPreferencesViewController:self];
    
    self.keyChain[@"useHighSchool"] = [[NSNumber numberWithBool:self.isHighSchoolSwitch.isOn] stringValue];
    self.keyChain[@"school"] = self.highSchoolTextField.text;
    
    switch(self.genderSegmentedControl.selectedSegmentIndex) {
        case 0:
            self.keyChain[@"genderToShow"] = @"Male";
            break;
        case 1:
            self.keyChain[@"genderToShow"] = @"Female";
            break;
        case 2:
            self.keyChain[@"genderToShow"] = @"Everyone";
            break;
        default:
            self.keyChain[@"genderToShow"] = @"Everyone";
            break;
    }
    
    self.keyChain[@"distance"] = [[NSNumber numberWithFloat:self.distanceSlider.value] stringValue];
    self.keyChain[@"isDistance"] = [[NSNumber numberWithBool:self.isDistanceSwitch.isOn] stringValue];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

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
    //Remove the flow effect
    textField.layer.borderColor=[[UIColor clearColor]CGColor];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

-(void)tapReceived:(UITapGestureRecognizer *)tapGestureRecognizer
{
    [self.view endEditing:YES];
}

@end
