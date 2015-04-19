//
//  MatchedPersonTableViewCell.h
//  PromMe
//
//  Created by Ryan D'souza on 4/19/15.
//  Copyright (c) 2015 Ryan D'souza. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MatchedPersonTableViewCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UIImageView *profilePictureView;
@property (strong, nonatomic) IBOutlet UILabel *nameLabel;
@property (strong, nonatomic) IBOutlet UILabel *gradeLabel;
@property (strong, nonatomic) IBOutlet UILabel *schoolLabel;

@end
