//
//  MMSecondViewController.m
//  MMAppNet
//
//  Created by Kyle Mai on 10/4/13.
//  Copyright (c) 2013 Kyle Mai. All rights reserved.
//

#import "MMFollowingViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "MMUserPostsViewController.h"

@implementation MMFollowingViewController

@synthesize followingUsersTableView, followingUsersDictionary, usersSearchBar, userInfoArrayToPass, spinning;

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self == [super initWithCoder:aDecoder])
    {
        //Initialize stuff at the start of application
        NSString *urlString = @"https://d2rfichhc2fb9n.cloudfront.net/image/5/EST4CDcz9e6BBchxCGQJPaWvudd7InMiOiJzMyIsImIiOiJhZG4tdXNlci1hc3NldHMiLCJrIjoiYXNzZXRzL3VzZXIvZWUvODMvNjAvZWU4MzYwMDAwMDAwMDAwMC5qcGciLCJvIjoiIn0";
        NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:urlString]];
        
        followingUsersDictionary = [[NSMutableDictionary alloc] init];
        followingUsersDictionary[@"@kylebmai"] = @[@"@kylebmai", @"Kyle Mai", imageData];

    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    self.title = @"Following";
    
    UIImageView *backgroundImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"AppNetBG"]];
    [self.view addSubview:backgroundImageView];
    [self.view sendSubviewToBack:backgroundImageView];
    
    //Initialize stuff here for viewDidLoad
    userInfoArrayToPass = [[NSArray alloc] init];
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    //Define accessories
    usersSearchBar.delegate = self;
    usersSearchBar.placeholder = @"Search @Username";
    
    spinning = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
    spinning.backgroundColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.5];
    spinning.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
    spinning.layer.cornerRadius = 20;
    spinning.center = self.view.center;
    [self.view addSubview:spinning];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [followingUsersTableView reloadData];
}

- (void)reloadUsers
{
    [spinning startAnimating];
    
    NSString *urlString = [NSString stringWithFormat:@"https://alpha-api.app.net/stream/0/users/%@/posts", [usersSearchBar.text lowercaseString]];
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError)
    {
        NSDictionary *returnedJSONDictionary = [[NSDictionary alloc] initWithDictionary:[NSJSONSerialization JSONObjectWithData:data options:0 error:&connectionError]];
        NSDictionary *objectOfKeyMeta = [[NSDictionary alloc] initWithDictionary:[returnedJSONDictionary objectForKey:@"meta"]];
        NSString *returnedUserMetaCode = (NSString *)[objectOfKeyMeta objectForKey:@"code"];
        NSArray *arrayObjectOfKeyData = [[NSArray alloc] initWithArray:[returnedJSONDictionary objectForKey:@"data"]];
        
        if (returnedUserMetaCode.intValue == 404 || arrayObjectOfKeyData.count == 0)
        {
            [spinning stopAnimating];
            
            //User is NOT existed
            UIAlertView *nonExistedUserAler = [[UIAlertView alloc] initWithTitle:@"User is not existed!" message:@"Please check @username input, don't forget the @" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [nonExistedUserAler show];
        }
        else
        {
            if (followingUsersDictionary[[usersSearchBar.text lowercaseString]] != nil)
            {
                [spinning stopAnimating];
                UIAlertView *userAlreadyInArrayAlert = [[UIAlertView alloc] initWithTitle:@"Repeating User" message:@"You are already following this user." delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
                [userAlreadyInArrayAlert show];
            }
            else
            {
                //Getting info from users
                //NSArray *arrayObjectOfKeyData = [[NSArray alloc] initWithArray:[returnedJSONDictionary objectForKey:@"data"]];
                NSDictionary *aPostFromUser = [[NSDictionary alloc] initWithDictionary:[arrayObjectOfKeyData objectAtIndex:0]];
                NSDictionary *userInfoDictionary = [[NSDictionary alloc] initWithDictionary:[aPostFromUser objectForKey:@"user"]];
                NSString *stringNameOfUser = [userInfoDictionary objectForKey:@"name"];
                NSDictionary *avatarImageOfUser = [userInfoDictionary objectForKey:@"avatar_image"];
                NSString *stringUserImageURL = [avatarImageOfUser objectForKey:@"url"];
                NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:stringUserImageURL]];
                
                followingUsersDictionary[[usersSearchBar.text lowercaseString]] = @[[usersSearchBar.text lowercaseString], stringNameOfUser, imageData];
                usersSearchBar.text = @"";
                [followingUsersTableView reloadData];
                [spinning stopAnimating];
            }
        }
    }];
}

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    usersSearchBar.showsCancelButton = YES;
    return YES;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [self reloadUsers];
    usersSearchBar.showsCancelButton = NO;
    [usersSearchBar resignFirstResponder];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    usersSearchBar.showsCancelButton = NO;
    [usersSearchBar resignFirstResponder];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70.0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [followingUsersDictionary count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellID = @"cellID";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    
    if (!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellID];
        [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
        cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:16.0];
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
    
    NSString *usernameKey = [[followingUsersDictionary allKeys] objectAtIndex:indexPath.row];
    
    //Index 0 is username, Index 1 is full name, Index 2 is image url
    
    //Set cell text
    cell.textLabel.text = [followingUsersDictionary[usernameKey] objectAtIndex:1];
    cell.detailTextLabel.text = [followingUsersDictionary[usernameKey] objectAtIndex:0];
    
    //Set cell image
    cell.imageView.image = [UIImage imageWithData:[followingUsersDictionary[usernameKey] objectAtIndex:2]];
    
    
    return cell;
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    [super setEditing:editing animated:animated];
    
    if (editing)
    {
        [followingUsersTableView setEditing:editing animated:animated];
    }
    else
    {
        [followingUsersTableView setEditing:editing animated:animated];
    }
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        [followingUsersTableView beginUpdates];
        [followingUsersDictionary removeObjectForKey:[[followingUsersDictionary allKeys] objectAtIndex:indexPath.row]];
        [followingUsersTableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
        [followingUsersTableView endUpdates];
    }
    
    [followingUsersTableView reloadData];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{    
    NSString *keyOfObjectToPass = [[followingUsersDictionary allKeys] objectAtIndex:indexPath.row];
    NSLog(@"Did select key %@", keyOfObjectToPass);
    userInfoArrayToPass = [followingUsersDictionary objectForKey:keyOfObjectToPass];
    [self performSegueWithIdentifier:@"segueFollowingVCtoUserPosts" sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    MMUserPostsViewController *userPostsVC = segue.destinationViewController;
    userPostsVC.userInfoArray = userInfoArrayToPass;
    

}


@end
