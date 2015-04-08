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
    
    int imageSize = 300;
    
    self.draggableView.frame = CGRectMake((self.view.frame.size.width - imageSize)/2, (self.view.frame.size.height - imageSize)/2, imageSize, imageSize);

    //self.draggableView.frame = CGRectMake((self.view.frame.size.width - 300)/2, (self.view.frame.size.height - 400)/2, 200, 200);
    //[self.draggableView setCenter:CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height/2)];
    [self.draggableView setCenter:CGPointMake(CGRectGetMidX(self.view.bounds), CGRectGetMidY(self.view.bounds))];
    
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
