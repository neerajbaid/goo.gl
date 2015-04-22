//
//  URLShortenerAppDelegate.m
//  URL Shortener
//
//  Created by Neeraj Baid on 2/13/13.
//  Copyright (c) 2013 Neeraj Baid. All rights reserved.
//

#import "URLShortenerAppDelegate.h"
#import "URLShortenerViewController.h"
#import "Mixpanel.h"

@implementation URLShortenerAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [Mixpanel sharedInstanceWithToken:@"90698dd2657dcc2427c6cde3172c148a"];
    return YES;
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    [[Mixpanel sharedInstance] track:@"Opened App"];
    UINavigationController *UInc = (UINavigationController *)_window.rootViewController;
    UIViewController *UIvc = UInc.topViewController;
    if ([UIvc respondsToSelector:@selector(disappear)])
    {
        URLShortenerViewController *URLsvc = (URLShortenerViewController *)UIvc;
        [URLsvc disappear];
        if ([URLsvc handlePasteboardString]) {
            [URLsvc shortenURL:[UIPasteboard generalPasteboard].string];
        }
    }
}

@end
