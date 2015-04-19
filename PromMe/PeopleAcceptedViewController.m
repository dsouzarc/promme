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

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.people.count;
}

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

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.mainView registerNib:[UINib nibWithNibName:@"MatchedPersonTableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@TABLE_IDENTIFIER];
}

-(UIImage*)resizeImage:(UIImage *)image imageSize:(CGSize)size
{
    UIGraphicsBeginImageContext(size);
    [image drawInRect:CGRectMake(0,0,size.width,size.height)];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

- (IBAction)backClick:(id)sender {
    [self.navigationController popToRootViewControllerAnimated:YES];
}

@end
