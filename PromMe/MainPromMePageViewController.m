//
//  MainPromMePageViewController.m
//  PromMe
//
//  Created by Ryan D'souza on 4/6/15.
//  Copyright (c) 2015 Ryan D'souza. All rights reserved.
//

#import "MainPromMePageViewController.h"
#import "SwipeDraggableView.h"
#import "Person.h"

@interface MainPromMePageViewController ()

@property (strong, nonatomic) NSArray *friendsList;
@property (strong, nonatomic) SwipeDraggableView *draggableView;

@end

@implementation MainPromMePageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self loadFriends];
    
    self.view.window.backgroundColor = [UIColor whiteColor];
    self.draggableView = [[SwipeDraggableView alloc] init:self.friendsList[0]];
    
    [self.view addSubview:self.draggableView];
    self.draggableView.frame = CGRectMake(60, 60, 200, 260);

    
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
