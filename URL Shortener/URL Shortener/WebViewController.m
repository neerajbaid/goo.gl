//
//  WebViewController.m
//  URL Shortener
//
//  Created by Neel Bhoopalam and Neeraj Baid on 3/20/13.
//  Copyright (c) 2013 Neeraj Baid. All rights reserved.
//

#import "WebViewController.h"


@interface WebViewController ()

@end

@implementation WebViewController

- (UIWebView *)webView
{
    if (!_webView)
        _webView = [[UIWebView alloc] init];
    return _webView;
}

/*
- (NSString *)convertToURLFormat:(NSString *)str
{
    if ([str rangeOfString:@"http://"].location == NSNotFound)
        str = [@"http://" stringByAppendingString:str];
    return str;
}
 */

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
    
    /*
    if(self.navigationController.viewControllers.count > 1)
    {
        UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
        
        [backButton setTitle:@"Back" forState:UIControlStateNormal];
        [backButton addTarget:self action:@selector(didTapBackButton:) forControlEvents:UIControlEventTouchUpInside];
        backButton.frame = CGRectMake(0.0f, 0.0f, 64.0f, 41.0f);
        [backButton setBackgroundImage:[UIImage imageNamed:@"black-square.jpg"] forState:UIControlStateNormal];
        UIBarButtonItem *backButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
        
        self.navigationItem.backBarButtonItem = backButtonItem;
    }
     */
    
//    [self.navigationController.navigationItem.backBarButtonItem setBackButtonBackgroundImage:[UIImage imageNamed:@"black-square.jpg"] forState:UIControlStateHighlighted barMetrics:UIBarMetricsDefault];
    
    NSURLRequest *requestURL = [NSURLRequest requestWithURL:[NSURL URLWithString:_URLToLoad]];
    [_webView loadRequest:requestURL];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
