//
//  WebViewController.m
//  URL Shortener
//
//  Created by Neel Bhoopalam on 3/20/13.
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
    
    [self.navigationController.navigationItem.backBarButtonItem setBackButtonBackgroundImage:[UIImage imageNamed:@"black-square.jpg"] forState:UIControlStateHighlighted barMetrics:UIBarMetricsDefault];
    
    NSURLRequest *requestURL = [NSURLRequest requestWithURL:[NSURL URLWithString:_URLToLoad]];
//    NSURLRequest *requestURL = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://www.google.com"]];
    [_webView loadRequest:requestURL];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
