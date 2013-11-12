//
//  MMGlobalViewController.m
//  MMAppNet
//
//  Created by Kyle Mai on 10/5/13.
//  Copyright (c) 2013 Kyle Mai. All rights reserved.
//

#import "MMGlobalViewController.h"
#import "MMUserPostsViewController.h"


@implementation MMGlobalViewController

@synthesize globalTableView,
            spinning,
            allUsersPostsArray,
            userInfoArrayToPass,
            lastRefreshTime;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    //Initialize stuff
    allUsersPostsArray = [[NSMutableArray alloc] init];
    userInfoArrayToPass = [[NSArray alloc] init];
    
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.title = @"Global Tweets";
    
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
    [globalTableView addSubview:refreshControl];
    [globalTableView sendSubviewToBack:refreshControl];
    
    [self loadGlobalPosts];
    
    lastRefreshTime = [NSDate date];
}

- (void)tableRefresh:(UIRefreshControl *)refresh
{
    [self loadGlobalPosts];
    lastRefreshTime = [NSDate date];
    [refresh endRefreshing];
}

- (void)loadGlobalPosts
{
    [spinning startAnimating];
    
    NSString *urlString = @"https://alpha-api.app.net/stream/0/posts/stream/global";
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError)
     {
         NSDictionary *returnedJSONDictionary = [[NSDictionary alloc] initWithDictionary:[NSJSONSerialization JSONObjectWithData:data options:0 error:&connectionError]];
         NSArray *objectOfKeyData = [[NSArray alloc] initWithArray:[returnedJSONDictionary objectForKey:@"data"]];
         //NSLog(@"Data Object: %@", objectOfKeyData);
         
         [allUsersPostsArray removeAllObjects];
         for (NSDictionary *dataArrayDictionaryObject in objectOfKeyData)
         {
             NSMutableArray *arrayObjectOfEachUserPost = [[NSMutableArray alloc] init];
             
             NSDictionary *userDictionary = [[NSDictionary alloc] initWithDictionary:[dataArrayDictionaryObject objectForKey:@"user"]];
             NSDictionary *avatarImageOfUser = [userDictionary objectForKey:@"avatar_image"];
             NSString *stringUserImageURL = [avatarImageOfUser objectForKey:@"url"];
             NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:stringUserImageURL]];
             
             [arrayObjectOfEachUserPost addObject:[NSString stringWithFormat:@"@%@", [userDictionary objectForKey:@"username"]]];
             [arrayObjectOfEachUserPost addObject:[userDictionary objectForKey:@"name"]];
             [arrayObjectOfEachUserPost addObject:imageData];
             
             if ([dataArrayDictionaryObject objectForKey:@"text"] == nil) {
                 continue;
             }
             
             [arrayObjectOfEachUserPost addObject:[dataArrayDictionaryObject objectForKey:@"text"]];
             [arrayObjectOfEachUserPost addObject:[userDictionary objectForKey:@"timezone"]];
             [arrayObjectOfEachUserPost addObject:[dataArrayDictionaryObject objectForKey:@"html"]];
             
             [allUsersPostsArray addObject:arrayObjectOfEachUserPost];
         }
         //NSLog(@"allUsersPostsArray: %@", allUsersPostsArray);
         
         [globalTableView reloadData];
         [spinning stopAnimating];

     }];
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

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [allUsersPostsArray count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellID = @"cellID";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellID];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.textLabel.numberOfLines = 3;
        cell.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
        cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:13.0];
        cell.textLabel.textColor = [UIColor whiteColor];
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
    userInfoArrayToPass = [allUsersPostsArray objectAtIndex:indexPath.row];
    [self performSegueWithIdentifier:@"segueGlobalVCtoUserPostsVC" sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    MMUserPostsViewController *userPostsVC = segue.destinationViewController;
    userPostsVC.userInfoArray = userInfoArrayToPass;
    NSLog(@"userInfoArrayToPass: %@", userInfoArrayToPass);
}



@end
