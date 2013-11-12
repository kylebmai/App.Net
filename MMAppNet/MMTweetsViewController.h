//
//  MMFirstViewController.h
//  MMAppNet
//
//  Created by Kyle Mai on 10/4/13.
//  Copyright (c) 2013 Kyle Mai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MMFollowingViewController.h"

@interface MMTweetsViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>
{
    MMFollowingViewController *followingVC;
}

//Outlets
@property (weak, nonatomic) IBOutlet UITableView *tweetsTableView;

//Properties
@property (strong, nonatomic) NSMutableDictionary *usersInfoDictionary;
@property (strong, nonatomic) NSMutableArray *usersKeyArray;
@property (strong, nonatomic) NSMutableArray *allUsersPostsArray;
@property (strong, nonatomic) UIActivityIndicatorView *spinning;
@property (strong, nonatomic) NSArray *userInfoToPass;
@property (strong, nonatomic) NSDate *lastRefreshTime;

//Actions and Methods


@end
