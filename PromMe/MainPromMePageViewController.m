//
//  MainPromMePageViewController.m
//  PromMe
//
//  Created by Ryan D'souza on 4/6/15.
//  Copyright (c) 2015 Ryan D'souza. All rights reserved.
//

#import "MainPromMePageViewController.h"
#import "Person.h"

@interface MainPromMePageViewController ()

@property (strong, nonatomic) NSArray *friendsList;

@end

@implementation MainPromMePageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self loadFriends];
    
    for(Person *person in self.friendsList) {
        NSLog(person.name);
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) loadFriends
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSData *savedData = [defaults objectForKey:@"savedFriends"];
    
    if(savedData != nil) {
        NSArray *data = [NSKeyedUnarchiver unarchiveObjectWithData:savedData];
        
        self.friendsList = [[NSArray alloc] initWithArray:data];
    }
}

@end
