//
//  WebViewController.h
//  URL Shortener
//
//  Created by Neel Bhoopalam on 3/20/13.
//  Copyright (c) 2013 Neeraj Baid. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WebViewController : UIViewController
{
    IBOutlet UIWebView *webView;
}

@property (weak, nonatomic) IBOutlet UIWebView *webView;

@end
