//
//  MMGlobalViewController.h
//  MMAppNet
//
//  Created by Kyle Mai on 10/5/13.
//  Copyright (c) 2013 Kyle Mai. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MMGlobalViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

//Outlets
@property (weak, nonatomic) IBOutlet UITableView *globalTableView;

//Properties
@property (strong, nonatomic) UIActivityIndicatorView *spinning;
@property (strong, nonatomic) NSMutableArray *allUsersPostsArray;
@property (strong, nonatomic) NSArray *userInfoArrayToPass;
@property (strong, nonatomic) NSDate *lastRefreshTime;

//Actions and Methods

@end
