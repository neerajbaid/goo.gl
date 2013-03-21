//
//  WebViewController.m
//  URL Shortener
//
//  Created by Neel Bhoopalam on 3/20/13.
//  Copyright (c) 2013 Neeraj Baid. All rights reserved.
//

#import "WebViewController.h"


@interface WebViewController ()

@property NSString *url;

@end

@implementation WebViewController

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
    
//    NSURLRequest *requestURL = [NSURLRequest requestWithURL:[NSURL URLWithString:_url]];
    
    NSURLRequest *requestURL = [NSURLRequest requestWithURL:[NSURL URLWithString:@"www.google.com"]];
    
    [webView loadRequest:requestURL];

    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
