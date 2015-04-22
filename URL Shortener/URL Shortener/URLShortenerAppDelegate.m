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
    // Override point for customization after application launch.
    if ([[[UIDevice currentDevice] systemVersion] doubleValue] < 6.9)
        [self setBarButtonAppearance];
//    [self setBarButtonAppearance];
    [Mixpanel sharedInstanceWithToken:@"90698dd2657dcc2427c6cde3172c148a"];
    [[Mixpanel sharedInstance] track:@"Opened App"];
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    UINavigationController *UInc = (UINavigationController *)_window.rootViewController;
    UIViewController *UIvc = UInc.topViewController;
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if ([UIvc respondsToSelector:@selector(signInReminder)])
    {
        URLShortenerViewController *URLsvc = (URLShortenerViewController *)UIvc;
        URLsvc.signInReminder.alpha = 0;
    }
    if ([userDefaults boolForKey:@"hasSignedIn"] && [UIvc respondsToSelector:@selector(auth)])
    {
        NSLog(@"test1");
        URLShortenerViewController *URLsvc = (URLShortenerViewController *)UIvc;
        if (!URLsvc.isSignedIn)
        {
            URLsvc.signInReminder.alpha = 1;
            NSLog(@"test2");
        }
        
    }
    if ([UIvc respondsToSelector:@selector(disappear)])
    {
        URLShortenerViewController *URLsvc = (URLShortenerViewController *)UIvc;
        [URLsvc disappear];
        if ([URLsvc handlePasteboardString])
            [URLsvc shortenURL:[UIPasteboard generalPasteboard].string];
    }
    if ([UIvc respondsToSelector:@selector(auth)])
    {
        URLShortenerViewController *URLsvc = (URLShortenerViewController *)UIvc;
        if (![[URLsvc auth] canAuthorize])
        {
            NSLog(@"cant authorize");
        }
    }
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)setBarButtonAppearance
{
    [[UIBarButtonItem appearance] setTintColor:[UIColor whiteColor]];
    [[UIBarButtonItem appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                          [UIColor blackColor], UITextAttributeTextColor,
                                                          [UIColor whiteColor], UITextAttributeTextShadowColor,
                                                          nil]
                                                forState:UIControlStateNormal];
    [[UIBarButtonItem appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                          [UIColor grayColor], UITextAttributeTextColor,
                                                          [UIColor whiteColor], UITextAttributeTextShadowColor,
                                                          nil]
                                                forState:UIControlStateHighlighted];
}

@end
