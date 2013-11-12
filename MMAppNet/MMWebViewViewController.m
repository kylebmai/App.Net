//
//  MMWebViewViewController.m
//  MMAppNet
//
//  Created by Kyle Mai on 10/5/13.
//  Copyright (c) 2013 Kyle Mai. All rights reserved.
//

#import "MMWebViewViewController.h"

@implementation MMWebViewViewController

@synthesize postDetailArray, detailWebView, spinning;

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
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    spinning = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
    spinning.backgroundColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.5];
    spinning.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
    spinning.layer.cornerRadius = 20;
    spinning.center = self.view.center;
    [self.view addSubview:spinning];
}

- (void)viewWillAppear:(BOOL)animated
{
    webLoadCount = 0;
    
    [super viewWillAppear:animated];
    
    NSString *postHTMLString = [postDetailArray objectAtIndex:2];
    [detailWebView loadHTMLString:postHTMLString baseURL:nil];
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    [spinning startAnimating];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [spinning stopAnimating];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    webLoadCount++;
    
    if (webLoadCount > 1) {
        webView.scalesPageToFit = YES;
    }
    
    return YES;
}



@end
