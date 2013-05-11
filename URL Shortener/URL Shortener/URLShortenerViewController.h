//
//  URLShortenerViewController.h
//  URL Shortener
//
//  Created by Neeraj Baid on 2/13/13.
//  Copyright (c) 2013 Neeraj Baid. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "APIConnection.h"
#import <Social/Social.h>
#import <Accounts/Accounts.h>
#import <MessageUI/MessageUI.h>
#import <Security/Security.h>
#import <SystemConfiguration/SystemConfiguration.h>

@interface URLShortenerViewController : UIViewController <URLRecipient>

- (BOOL)validateUrl:(NSString *)candidate;
- (BOOL)handlePasteboardString;
- (void)shortenURL:(NSString *)url;
- (void)disappear;

@property (nonatomic) SLComposeViewController *mySLComposerSheet;
@property (nonatomic) GTMOAuth2Authentication *auth;
@property (nonatomic) BOOL isSignedIn;
@property (weak, nonatomic) IBOutlet UIImageView *signInReminder;

@end
