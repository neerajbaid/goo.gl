#import <Mixpanel/Mixpanel.h>
#import <SVProgressHUD/SVProgressHUD.h>

#import "URLShortenerAppDelegate.h"
#import "URLShortenerViewController.h"

@implementation URLShortenerAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [Mixpanel sharedInstanceWithToken:@"90698dd2657dcc2427c6cde3172c148a"];
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    [SVProgressHUD setForegroundColor:[UIColor whiteColor]];
    [SVProgressHUD setBackgroundColor:[UIColor blackColor]];
    [SVProgressHUD setFont:[UIFont fontWithName:@"Avenir-Light" size:17]];
    [[UITextField appearance] setTintColor:[UIColor whiteColor]];
    return YES;
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    [[Mixpanel sharedInstance] track:@"Opened App"];
}

@end
