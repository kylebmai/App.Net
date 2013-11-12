//
//  MMFirstViewController.m
//  MMAppNet
//
//  Created by Kyle Mai on 10/4/13.
//  Copyright (c) 2013 Kyle Mai. All rights reserved.
//

#import "MMTweetsViewController.h"
#import "MMFollowingViewController.h"
#import "MMUserPostsViewController.h"


@implementation MMTweetsViewController

@synthesize tweetsTableView,
            usersInfoDictionary,
            spinning,
            usersKeyArray,
            allUsersPostsArray,
            userInfoToPass,
            lastRefreshTime;

- (void)viewDidLoad
{
    usersInfoDictionary = [[NSMutableDictionary alloc] init];
    followingVC = [[[[self.tabBarController viewControllers] objectAtIndex:1] viewControllers] objectAtIndex:0];
    usersKeyArray = [[NSMutableArray alloc] init];
    allUsersPostsArray = [[NSMutableArray alloc] init];
    userInfoToPass = [[NSArray alloc] init];
    
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    self.title = @"All Tweets";
    
    UIImageView *backgroundImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"AppNetBG"]];
    [self.view addSubview:backgroundImageView];
    [self.view sendSubviewToBack:backgroundImageView];
    
    spinning = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
    spinning.backgroundColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.5];
    spinning.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
    spinning.layer.cornerRadius = 20;
    spinning.center = self.view.center;
    [self.view addSubview:spinning];
    
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(tableRefresh:) forControlEvents:UIControlEventValueChanged];
    [tweetsTableView addSubview:refreshControl];
    [tweetsTableView sendSubviewToBack:refreshControl];
    
    lastRefreshTime = [NSDate date];
}

- (void)tableRefresh:(UIRefreshControl *)refreshControl
{
    [self loadUsersPosts];
    lastRefreshTime = [NSDate date];
    [refreshControl endRefreshing];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [usersInfoDictionary removeAllObjects];
    [usersInfoDictionary setDictionary:followingVC.followingUsersDictionary];
    usersKeyArray = [usersInfoDictionary allKeys].mutableCopy;
    
    [self loadUsersPosts];
}

- (void)loadUsersPosts
{
    [spinning startAnimating];
    
    if ([usersKeyArray count] > 0)
    {
        NSMutableArray *tempArray = [[NSMutableArray alloc] init];
        for (int i = 0; i < [usersKeyArray count]; i++)
        {
            NSString *urlString = [NSString stringWithFormat:@"https://alpha-api.app.net/stream/0/users/%@/posts", [usersKeyArray objectAtIndex:i]];
            NSURL *url = [NSURL URLWithString:urlString];
            NSURLRequest *request = [NSURLRequest requestWithURL:url];
            
            [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError)
             {
                 NSDictionary *returnedJSONDictionary = [[NSDictionary alloc] initWithDictionary:[NSJSONSerialization JSONObjectWithData:data options:0 error:&connectionError]];
                 NSArray *objectOfKeyData = [[NSArray alloc] initWithArray:[returnedJSONDictionary objectForKey:@"data"]];
                 
                 for (NSDictionary *dataArrayDictionaryObject in objectOfKeyData)
                 {
                     NSMutableArray *arrayObjectOfEachUserPost = [[NSMutableArray alloc] initWithArray:[usersInfoDictionary objectForKey:[usersKeyArray objectAtIndex:i]]];
                     NSDictionary *userDictionary = [[NSDictionary alloc] initWithDictionary:[dataArrayDictionaryObject objectForKey:@"user"]];
                     
                     if ([dataArrayDictionaryObject objectForKey:@"text"] == nil)
                     {
                         continue;
                     }
                     
                     [arrayObjectOfEachUserPost addObject:[dataArrayDictionaryObject objectForKey:@"text"]];
                     [arrayObjectOfEachUserPost addObject:[userDictionary objectForKey:@"timezone"]];
                     [arrayObjectOfEachUserPost addObject:[dataArrayDictionaryObject objectForKey:@"created_at"]];
                     
                     [tempArray addObject:arrayObjectOfEachUserPost];
                 }
                 
                 if (i == ([usersKeyArray count] - 1))
                 {
                     [spinning stopAnimating];
                 }
                 
                 allUsersPostsArray = [tempArray sortedArrayUsingComparator:^NSComparisonResult(NSArray *obj1, NSArray *obj2){return [obj2[5] compare:obj1[5]];}].mutableCopy;
                 
                 [tweetsTableView reloadData];
             }];
        }
    }
    else
    {
        [allUsersPostsArray removeAllObjects];
        [tweetsTableView reloadData];
        [spinning stopAnimating];
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"hh:mm:ss a"];
    UILabel *lastUpdateLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, 20)];
    lastUpdateLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:12.0];
    lastUpdateLabel.textAlignment = NSTextAlignmentCenter;
    lastUpdateLabel.textColor = [UIColor whiteColor];
    lastUpdateLabel.backgroundColor = [UIColor lightGrayColor];
    lastUpdateLabel.text = [NSString stringWithFormat:@"Last update: %@", [dateFormat stringFromDate:lastRefreshTime]];
    
    return lastUpdateLabel;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70.0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [allUsersPostsArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellID = @"cellID";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    
    if (!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellID];
        //cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.textLabel.numberOfLines = 3;
        cell.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
        cell.textLabel.textColor = [UIColor whiteColor];
        cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:13.0];
        cell.detailTextLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:12.0];
        cell.detailTextLabel.textColor = [UIColor blackColor];
        cell.imageView.frame = CGRectMake(0, 0, 70.0, 70.0);
        cell.imageView.layer.cornerRadius = 35;
        cell.imageView.layer.masksToBounds = YES;
        cell.imageView.layer.borderWidth = 0.5;
        cell.imageView.layer.borderColor = [UIColor lightGrayColor].CGColor;
        cell.backgroundColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.2];
    }
    
    //Index 0: @username
    NSString *username = [[allUsersPostsArray objectAtIndex:indexPath.row] objectAtIndex:0];
    
    //Index 1: Full name
    NSString *fullName = [[allUsersPostsArray objectAtIndex:indexPath.row] objectAtIndex:1];
    
    //Index 2: image data
    UIImage *userImage = [UIImage imageWithData:[[allUsersPostsArray objectAtIndex:indexPath.row] objectAtIndex:2]];
    
    //Index 3: post
    NSString *post = [[allUsersPostsArray objectAtIndex:indexPath.row] objectAtIndex:3];
    
    //Index 4: location
    NSString *location = [NSString stringWithFormat:@"%@ in %@", username, [[[[allUsersPostsArray objectAtIndex:indexPath.row] objectAtIndex:4] lastPathComponent] stringByReplacingOccurrencesOfString:@"_" withString:@" "]];
    
    cell.textLabel.text = [NSString stringWithFormat:@"%@\n%@", fullName, post];
    cell.detailTextLabel.text = location;
    cell.imageView.image = userImage;
    
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    userInfoToPass = [allUsersPostsArray objectAtIndex:indexPath.row];
    [self performSegueWithIdentifier:@"segueTweetsVCtoUserPostsVC" sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    MMUserPostsViewController *userPostsVC = segue.destinationViewController;
    userPostsVC.userInfoArray = userInfoToPass;
}



@end
