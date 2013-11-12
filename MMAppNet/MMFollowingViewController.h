//
//  MMSecondViewController.h
//  MMAppNet
//
//  Created by Kyle Mai on 10/4/13.
//  Copyright (c) 2013 Kyle Mai. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MMFollowingViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate>

//Outlets
@property (weak, nonatomic) IBOutlet UITableView *followingUsersTableView;
@property (weak, nonatomic) IBOutlet UISearchBar *usersSearchBar;

//Properties
@property (strong, nonatomic) NSMutableDictionary *followingUsersDictionary;
@property (strong, nonatomic) NSArray *userInfoArrayToPass;
@property (strong, nonatomic) UIActivityIndicatorView *spinning;


//Methods
- (id)initWithCoder:(NSCoder *)aDecoder;


@end
