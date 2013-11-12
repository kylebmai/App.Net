//
//  MMUserPostsViewController.h
//  MMAppNet
//
//  Created by Kyle Mai on 10/4/13.
//  Copyright (c) 2013 Kyle Mai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MMFollowingViewController.h"


@interface MMUserPostsViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>
{
    MMFollowingViewController *followingVC;
}

//Outlets
@property (weak, nonatomic) IBOutlet UIImageView *userImageView;
@property (weak, nonatomic) IBOutlet UITableView *userPostsTableView;
@property (weak, nonatomic) IBOutlet UIButton *addUserButton;

//Properties
@property (strong, nonatomic) NSArray *userInfoArray;
@property (strong, nonatomic) NSMutableArray *userPostsArray;
@property (strong, nonatomic) UIActivityIndicatorView *spinning;
@property (strong, nonatomic) NSArray *postDetailArrayToPass;
@property (strong, nonatomic) NSDate *lastRefreshTime;

//Actions

@end
