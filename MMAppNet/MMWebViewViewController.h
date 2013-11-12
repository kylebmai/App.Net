//
//  MMWebViewViewController.h
//  MMAppNet
//
//  Created by Kyle Mai on 10/5/13.
//  Copyright (c) 2013 Kyle Mai. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MMWebViewViewController : UIViewController <UIWebViewDelegate>
{
    int webLoadCount;
}

//Outlets
@property (weak, nonatomic) IBOutlet UIWebView *detailWebView;
@property (strong, nonatomic) UIActivityIndicatorView *spinning;


//Properties
@property (strong, nonatomic) NSArray *postDetailArray;

@end
