//
//  MMUserPostsViewController.m
//  MMAppNet
//
//  Created by Kyle Mai on 10/4/13.
//  Copyright (c) 2013 Kyle Mai. All rights reserved.
//

#import "MMUserPostsViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "MMWebViewViewController.h"

@implementation MMUserPostsViewController

@synthesize userInfoArray,
            userImageView,
            userPostsTableView,
            userPostsArray,
            spinning,
            postDetailArrayToPass,
            addUserButton,
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
    //Intialize stuff
    userPostsArray = [[NSMutableArray alloc] init];
    postDetailArrayToPass = [[NSArray alloc] init];
    followingVC = [[[[self.tabBarController viewControllers] objectAtIndex:1] viewControllers] objectAtIndex:0];
    
    [super viewDidLoad];
    
	// Do any additional setup after loading the view.
    self.title = [userInfoArray objectAtIndex:1];
    
    UIImageView *backgroundImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"AppNetBG"]];
    [self.view addSubview:backgroundImageView];
    [self.view sendSubviewToBack:backgroundImageView];
    
    //Setting user image properties
    userImageView.image = [UIImage imageWithData:[userInfoArray objectAtIndex:2]];
    userImageView.layer.cornerRadius = userImageView.frame.size.height / 2;
    userImageView.layer.masksToBounds = YES;
    userImageView.layer.borderWidth = 5;
    userImageView.layer.borderColor = [UIColor colorWithRed:158/255.0 green:234/255.0 blue:235/255.0 alpha:1.0].CGColor;
    
    //waiting spinning view
    spinning = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
    spinning.backgroundColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.5];
    spinning.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
    spinning.layer.cornerRadius = 20;
    spinning.center = self.view.center;
    [self.view addSubview:spinning];
    
    //tableview refresh spinning
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(tableRefresh:) forControlEvents:UIControlEventValueChanged];
    [userPostsTableView addSubview:refreshControl];
    [userPostsTableView sendSubviewToBack:refreshControl];
    
    [self loadUserPosts];
    
    lastRefreshTime = [NSDate date];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self checkAddUserButtonState];
}

- (void)checkAddUserButtonState
{
    //Check following for assUserButton state
    if (followingVC.followingUsersDictionary[[userInfoArray objectAtIndex:0]] != nil)
    {
        [addUserButton setTitle:@"You are following this user" forState:UIControlStateNormal];
        addUserButton.enabled = NO;
    }
    else
    {
        [addUserButton setTitle:@"+ Follow" forState:UIControlStateNormal];
        addUserButton.enabled = YES;
    }
}

- (void)tableRefresh:(UIRefreshControl *)refresh
{
    [self loadUserPosts];
    lastRefreshTime = [NSDate date];
    [refresh endRefreshing];
}

- (void)loadUserPosts
{
    [spinning startAnimating];
    
    NSString *urlString = [NSString stringWithFormat:@"https://alpha-api.app.net/stream/0/users/%@/posts", [userInfoArray objectAtIndex:0]];
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError)
     {
         NSDictionary *returnedJSONDictionary = [[NSDictionary alloc] initWithDictionary:[NSJSONSerialization JSONObjectWithData:data options:0 error:&connectionError]];
         NSArray *objectOfKeyData = [[NSArray alloc] initWithArray:[returnedJSONDictionary objectForKey:@"data"]];
         //NSLog(@"objectOfKeyData: %@", objectOfKeyData);
         
         [userPostsArray removeAllObjects];
         for (NSDictionary *dataArrayDictionaryObject in objectOfKeyData)
         {
             //NSLog(@"dataArrayDictionaryObject: %@", dataArrayDictionaryObject);
             
             NSMutableArray *post = [[NSMutableArray alloc] init];
             NSDictionary *userDictionary = [[NSDictionary alloc] initWithDictionary:[dataArrayDictionaryObject objectForKey:@"user"]];
             
             if ([dataArrayDictionaryObject objectForKey:@"text"] == nil) {
                 [post addObject:@"Deleted by user."];
             }
             else {
                 [post addObject:[dataArrayDictionaryObject objectForKey:@"text"]];
             }
             
             [post addObject:[userDictionary objectForKey:@"timezone"]];
             
             if ([dataArrayDictionaryObject objectForKey:@"html"] == nil) {
                 [post addObject:@"Deleted by user."];
             }
             else {
                 [post addObject:[dataArrayDictionaryObject objectForKey:@"html"]];
             }
             
             [userPostsArray addObject:post];
         }
         //NSLog(@"userPostsArray: %@", userPostsArray);
         
         [userPostsTableView reloadData];
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

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70.0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [userPostsArray count];
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
        cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:13.0];
        cell.textLabel.textColor = [UIColor whiteColor];
        cell.detailTextLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:12.0];
        cell.detailTextLabel.textColor = [UIColor blackColor];
        cell.backgroundColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.2];
    }
    
    //Text for cell label
    NSString *textForCellLabel = [[userPostsArray objectAtIndex:indexPath.row] objectAtIndex:0];
    cell.textLabel.text = textForCellLabel;
    
    //Text for cell detail label
    NSString *textForCellDetailLabel = [NSString stringWithFormat:@"in %@", [[[[userPostsArray objectAtIndex:indexPath.row] objectAtIndex:1] lastPathComponent] stringByReplacingOccurrencesOfString:@"_" withString:@" "]];
    cell.detailTextLabel.text = textForCellDetailLabel;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    postDetailArrayToPass = [userPostsArray objectAtIndex:indexPath.row];
    [self performSegueWithIdentifier:@"segueUserPostsVCtoWebViewVC" sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    MMWebViewViewController *webviewVC = segue.destinationViewController;
    webviewVC.postDetailArray = postDetailArrayToPass;
}

- (IBAction)addUserAction:(id)sender
{
    followingVC.followingUsersDictionary[[userInfoArray objectAtIndex:0]] = @[[userInfoArray objectAtIndex:0], [userInfoArray objectAtIndex:1], [userInfoArray objectAtIndex:2]];
    
    UIAlertView *userAddedAlert = [[UIAlertView alloc] initWithTitle:@"User Added" message:[NSString stringWithFormat:@"You are now following %@", [userInfoArray objectAtIndex:0]] delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [userAddedAlert show];
    
    [self checkAddUserButtonState];
}



@end
