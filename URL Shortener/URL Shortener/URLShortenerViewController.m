//
//  URLShortenerViewController.m
//  URL Shortener
//
//  Created by Neeraj Baid on 2/13/13.
//  Copyright (c) 2013 Neeraj Baid. All rights reserved.
//

#import "URLShortenerViewController.h"
#import "APIConnection.h"
#import "WebViewController.h"
#import "SignInViewController.h"
#import "Mixpanel.h"
#import "GTMOAuth2ViewControllerTouch.h"
#import "GTMHTTPFetcher.h"

@interface URLShortenerViewController () <UITextFieldDelegate, MFMessageComposeViewControllerDelegate, MFMailComposeViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UINavigationBar *navigationBar;
@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (weak, nonatomic) IBOutlet UILabel *shortenedURLLabel;
@property (weak, nonatomic) IBOutlet UILabel *urlHasBeenShortened;
@property (weak, nonatomic) IBOutlet UILabel *urlDisplayUnderShortenedURL;
@property (weak, nonatomic) IBOutlet UILabel *shortenedLinkHasBeenCopiedToTheClipboard;
@property (weak, nonatomic) IBOutlet UIImageView *background;
@property (weak, nonatomic) IBOutlet UIImageView *arrow;
@property NSString *url;
@property NSString *shortenedURL;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;
@property (strong, nonatomic) APIConnection *connection;
@property (weak, nonatomic) IBOutlet UIButton *testButton;
@property (nonatomic) BOOL isSignedIn;

@property (weak, nonatomic) IBOutlet UIButton *facebookShareButton;
@property (weak, nonatomic) IBOutlet UIButton *twitterShareButton;
@property (weak, nonatomic) IBOutlet UIButton *messagesShareButton;
@property (weak, nonatomic) IBOutlet UIButton *shareButton;
@property (weak, nonatomic) IBOutlet UIButton *mailShareButton;

@property (strong, nonatomic) NSString *kKeychainItemName;
@property (strong, nonatomic) NSString *kMyClientID;
@property (strong, nonatomic) NSString *kMyClientSecret;
@property (strong, nonatomic) GTMHTTPFetcher *fetcher;
@property (strong, nonatomic) GTMOAuth2Authentication *auth;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *signInBarButtonItem;

//@property (nonatomic) int test; //switcher variable

@end

@implementation URLShortenerViewController

- (GTMHTTPFetcher *)fetcher
{
    if (!_fetcher)
        _fetcher = [[GTMHTTPFetcher alloc] init];
    return _fetcher;
}

- (GTMOAuth2Authentication *)auth
{
    if (!_auth)
        _auth = [GTMOAuth2ViewControllerTouch authForGoogleFromKeychainForName:_kKeychainItemName
                                                                      clientID:_kMyClientID
                                                                  clientSecret:_kMyClientSecret];
    return _auth;
}

- (IBAction)signInOrOut:(id)sender
{
    if ([_signInBarButtonItem.title isEqualToString:@"Sign In"])
        [self signIn];
    else if ([_signInBarButtonItem.title isEqualToString:@"Sign Out"])
        [self signOut];
}

- (void)signIn
{
    NSString *scope = @"https://www.googleapis.com/auth/plus.me"; // scope for Google+ API
    
    GTMOAuth2ViewControllerTouch *viewController;
    viewController = [[GTMOAuth2ViewControllerTouch alloc] initWithScope:scope
                                                                 clientID:_kMyClientID
                                                             clientSecret:_kMyClientSecret
                                                         keychainItemName:_kKeychainItemName
                                                                 delegate:self
                                                         finishedSelector:@selector(viewController:finishedWithAuth:error:)];
    
    [[self navigationController] pushViewController:viewController
                                           animated:YES];
}

- (void)signOut
{
    [GTMOAuth2ViewControllerTouch removeAuthFromKeychainForName:_kKeychainItemName];
    [GTMOAuth2ViewControllerTouch revokeTokenForGoogleAuthentication:_auth];
    [_signInBarButtonItem setTitle:@"Sign In"];
    [[Mixpanel sharedInstance] track:@"Signed Out"];
    _isSignedIn = NO;
}

- (void)viewController:(GTMOAuth2ViewControllerTouch *)viewController finishedWithAuth:(GTMOAuth2Authentication *)auth error:(NSError *)error {
    if (error != nil)
    {
        // Authentication failed
    }
    else
    {
        [_signInBarButtonItem setTitle:@"Sign Out"];
        _isSignedIn = YES;
        [[Mixpanel sharedInstance] track:@"Signed In"];
        [_fetcher setAuthorizer:auth];
        [self setAuth:auth];
        NSMutableURLRequest *myURLRequest = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:@"test"]];
        [auth authorizeRequest:myURLRequest delegate:self didFinishSelector:@selector(authentication:request:finishedWithError:)];
    }
}

- (void)authentication:(GTMOAuth2Authentication *)auth request:(NSMutableURLRequest *)request finishedWithError:(NSError *)error
{
    if (error != nil)
    {
        // Authorization failed
    }
    else
    {
        // Authorization succeeded
    }
}

- (APIConnection *)connection
{
    if (!_connection)
        _connection = [[APIConnection alloc] init];
    _connection.delegate = self;
    return _connection;
}

//connection test method
/*
- (IBAction)testConnection:(id)sender
{
    [[self connection] shortenUrl:@"test"];
}
 */

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [self disappear];
}

- (BOOL)validateUrl:(NSString *)candidate
{
    //"http://" is required
    NSURL *temp = [NSURL URLWithString:candidate];
    BOOL doesNotContainGoogle = [candidate rangeOfString:@"goo.gl"].location == NSNotFound;
    if (temp && temp.scheme && doesNotContainGoogle)
        return TRUE;
    return FALSE;
}

- (BOOL)handlePasteboardString
{
    NSString *string = [UIPasteboard generalPasteboard].string;
    if ([self validateUrl:string])
    {
        Mixpanel *mixpanel = [Mixpanel sharedInstance];
        [mixpanel track:@"Automatically Copy URL"];
        
        NSString *text = @"  ";
        text = [text stringByAppendingString:string];
        
        [_textField setText:text];
        return YES;
    }
    return NO;
}

- (void)shortenURL:(NSString *)url
{
    BOOL doesNotContainSpace = [url rangeOfString:@" "].location == NSNotFound;
    BOOL doesNotContainGoogle = [url rangeOfString:@"goo.gl"].location == NSNotFound;
    if (![url isEqualToString:@""] && doesNotContainSpace && doesNotContainGoogle)
    {
        [[self connection] shortenURL:url];
        _url = url;
        [self fadeInSpinner];
        [_spinner startAnimating];
    }
}

- (void)recieveShortenedURL:(NSString *)shortenedURL
{
    if (shortenedURL != NULL)
    {
        NSString *display = @" ";
        self.urlDisplayUnderShortenedURL.text = [display stringByAppendingString:_url];
        [_spinner stopAnimating];
        [self fadeOutSpinner];
        [self appear];
        _shortenedURL = shortenedURL;
        if (_shortenedURL)
        {
            [[UIPasteboard generalPasteboard] setString:_shortenedURL];
            [[Mixpanel sharedInstance] track:@"URL Shortened"];
        }
        self.shortenedURLLabel.text = _shortenedURL;
    }
    else
        [self fadeOutSpinner];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    [UIView animateWithDuration:.2 animations:^(void)
     {
         [_shortenedLinkHasBeenCopiedToTheClipboard setAlpha:0];
     }];
    [self shortenURL:textField.text];
    return NO;
}

- (void)dismissKeyboard
{
    [_textField resignFirstResponder];
}

//sizeOfString
/*
- (CGRect)sizeOfString:(NSString *)string
{
    NSLog(@"sOS");
//    CGFloat width = [[UIScreen mainScreen] bounds].size.width;
//    CGFloat scale = [UIScreen mainScreen].scale;
    CGRect rect;
//    CGFloat height = self.view.frame.size.height;
//    if (scale == 1)
    {
        CGSize maximumSize = CGSizeMake(264, 21);
        UIFont *font = [UIFont fontWithName:@"Helvetica" size:10];
        CGSize size = [string sizeWithFont:font
                         constrainedToSize:maximumSize
                             lineBreakMode:self.urlDisplayUnderShortenedURL.lineBreakMode];
        CGFloat x = (320 - size.width)/2;
        rect = CGRectMake(x, 383, size.width, size.height);
    }
    else
    {
        NSLog(@"retina");
        CGSize maximumSize = CGSizeMake(528, 42);
        UIFont *font = [UIFont fontWithName:@"Helvetica" size:10];
        CGSize size = [string sizeWithFont:font
                         constrainedToSize:maximumSize
                             lineBreakMode:self.urlDisplayUnderShortenedURL.lineBreakMode];
        CGFloat x = (640 - size.width)/2;
        rect = CGRectMake(x, 766, size.width, size.height);
    }
//    NSLog(@"%f", rect.size.width);
//    NSLog(@"%f", rect.size.height);
    return rect;
}
 */

//switcher method
/*
- (IBAction)switch:(id)sender
{
    if (_test == 0)
    {
        [_background setImage:[UIImage imageNamed:@"background5 @2x.jpg"]];
        _test = 1;
    }
    else
    {
        [_background setImage:[UIImage imageNamed:@"background4 @2x.jpg"]];
        _test = 0;
    }
}
 */


- (void)fadeInSpinner
{
    [UIView animateWithDuration:.2 animations:^(void)
     {
         [_spinner setAlpha:1];
     }];
}

- (void)fadeOutSpinner
{
    [UIView animateWithDuration:.2 animations:^(void)
     {
         [_spinner setAlpha:0];
     }];
}

- (void)appear
{
    [UIView animateWithDuration:.4 animations:^(void)
     {
         [_arrow setAlpha:1];
         [_urlHasBeenShortened setAlpha:1];
         [_urlDisplayUnderShortenedURL setAlpha:1];
         [_urlDisplayUnderShortenedURL setBackgroundColor:[UIColor whiteColor]];
         [_testButton setAlpha:1];
         [_shareButton setAlpha:1];
     }];
}

- (void)disappear
{
    [UIView animateWithDuration:.4 animations:^(void)
     {
         [_arrow setAlpha:0];
         [_urlHasBeenShortened setAlpha:0];
     }];
    [_textField setText:@""];
}

- (IBAction)copyToPasteboard:(id)sender
{
    if (_shortenedURL != NULL)
        [[UIPasteboard generalPasteboard] setString:_shortenedURL];
    if (_arrow.alpha == 0 && _spinner.alpha == 0 && _urlHasBeenShortened.alpha == 0 && ![_shortenedURLLabel.text isEqualToString:@" "])
    {
        [UIView animateWithDuration:.2 animations:^(void)
         {
             [_shortenedLinkHasBeenCopiedToTheClipboard setAlpha:1];
         }];
    }
}

- (void)openWebView:(UIGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer.state == UIGestureRecognizerStateEnded)
    {
        Mixpanel *mixpanel = [Mixpanel sharedInstance];
        [mixpanel track:@"WebView Preview Button Pressed"];
        [self performSegueWithIdentifier:@"showWebView" sender:self];
    }
}

- (IBAction)doneSignIn:(UIStoryboardSegue *)segue
{
    if ([[segue identifier] isEqualToString:@"PassSignInCredentialsSegue"])
    {
        SignInViewController *sVC = [segue sourceViewController];
        _isSignedIn = [sVC isSignedIn];
        //do a bunch of changes in the api calling in APIConnection
    }
}

- (IBAction)shareButton:(id)sender
{
    if (_twitterShareButton.alpha == 0)
    {
        [_shareButton setBackgroundImage:[UIImage imageNamed:@"Close Share Button.png"] forState:UIControlStateNormal];
        [self appearShareButtons];
    }
    else if (_twitterShareButton.alpha == 1)
    {
        [_shareButton setBackgroundImage:[UIImage imageNamed:@"Share Button.png"] forState:UIControlStateNormal];
        [self disappearShareButtons];
    }
}

- (void)appearShareButtons
{    
    [UIView animateWithDuration:.2 animations:^(void)
     {
         [_twitterShareButton setAlpha:1];
         [_facebookShareButton setAlpha:1];
         [_messagesShareButton setAlpha:1];
         [_mailShareButton setAlpha:1];
     }];
}

- (void)disappearShareButtons
{    
    [UIView animateWithDuration:.2 animations:^(void)
     {
         [_twitterShareButton setAlpha:0];
         [_facebookShareButton setAlpha:0];
         [_messagesShareButton setAlpha:0];
         [_mailShareButton setAlpha:0];
     }];
}

- (IBAction)shareToTwitter:(id)sender
{  
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter])
    {
        SLComposeViewController *mySLComposerSheet = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
        NSString *initialText = [NSString stringWithFormat:@"Check this out!\n%@\n\nShortened using http://goo.gl/54iw0.", _shortenedURL];
        [mySLComposerSheet setInitialText:initialText];
        [mySLComposerSheet setCompletionHandler:^(SLComposeViewControllerResult result)
         {
             switch (result)
             {
                 case SLComposeViewControllerResultCancelled:
                     break;
                 case SLComposeViewControllerResultDone:
                 {
                     [[Mixpanel sharedInstance] track:@"Shortened Link Shared to Twitter"];
                     break;
                 }
                 default:
                     break;
             }
         }];
        [self presentViewController:mySLComposerSheet animated:YES completion:nil];
    }

}

- (IBAction)shareToFacebook:(id)sender
{    
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook])
    {
        SLComposeViewController *mySLComposerSheet = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
        NSString *initialText = [NSString stringWithFormat:@"Check this out!\n%@\n\nShortened using http://goo.gl/54iw0.", _shortenedURL];
        [mySLComposerSheet setInitialText:initialText];
        [mySLComposerSheet setCompletionHandler:^(SLComposeViewControllerResult result)
         {
             switch (result) {
                 case SLComposeViewControllerResultCancelled:
                     break;
                 case SLComposeViewControllerResultDone:
                 {
                     [[Mixpanel sharedInstance] track:@"Shortened Link Shared to Facebook"];
                     break;
                 }
                 default:
                     break;
             }
         }];
        
        [self presentViewController:mySLComposerSheet animated:YES completion:nil];
    }
}

- (IBAction)shareToMessages:(id)sender
{
    [self sendMessage];
}

- (IBAction)shareToMail:(id)sender
{
    [self sendMail];
}

- (void)sendMessage
{
    if ([MFMessageComposeViewController canSendText])
    {
        MFMessageComposeViewController *myMFMessageController = [[MFMessageComposeViewController alloc] init];
        NSString *initialText = [NSString stringWithFormat:@"Check this out!\n%@\n\nShortened using http://goo.gl/54iw0.", _shortenedURL];
        myMFMessageController.body = initialText;
        myMFMessageController.messageComposeDelegate = self;
        [self presentViewController:myMFMessageController animated:YES completion:nil];
    }
}

- (void)sendMail
{
    if ([MFMailComposeViewController canSendMail])
    {
        MFMailComposeViewController *myMFMailController = [[MFMailComposeViewController alloc] init];
        NSString *initialText = [NSString stringWithFormat:@"Check this out!\n%@\n\nShortened using http://goo.gl/54iw0.", _shortenedURL];
        [myMFMailController setMessageBody:initialText isHTML:FALSE];
        [myMFMailController setSubject:@"Check it out!"];
        myMFMailController.mailComposeDelegate = self;
        [self presentViewController:myMFMailController animated:YES completion:nil];
    }
}

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
{  
    [self dismissViewControllerAnimated:YES completion:nil];
    switch (result)
    {
        case MessageComposeResultCancelled:
            break;
        case MessageComposeResultFailed:
            break;
        case MessageComposeResultSent:
        {
            [[Mixpanel sharedInstance] track:@"Shortened Link Shared to Messages"];
            break;
        }
        default:
            break;
    }
}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    [self dismissViewControllerAnimated:YES completion:nil];
    switch (result)
    {
        case MFMailComposeResultCancelled:
            break;
        case MFMailComposeResultFailed:
            break;
        case MFMailComposeResultSaved:
            break;
        case MFMailComposeResultSent:
        {
            break;
            [[Mixpanel sharedInstance] track:@"Shortened Link Shared to Mail"];
        }
        default:
            break;
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"showWebView"])
        [segue.destinationViewController setURLToLoad:_shortenedURL];
}

- (void)viewDidLoad
{
    //[self setBarButtonAppearance];
    [super viewDidLoad];
    
    self.textField.delegate = self;
    
    UITapGestureRecognizer *tapGR = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:tapGR];
    
    UILongPressGestureRecognizer *longPressGR = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(openWebView:)];
    [self.testButton addGestureRecognizer:longPressGR];
    
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"top bar.png"] forBarMetrics:UIBarMetricsDefault];
    [_arrow setAlpha:0];
    [_spinner setAlpha:0];
    [_urlHasBeenShortened setAlpha:0];
    [_urlDisplayUnderShortenedURL setAlpha:0];
    [_shortenedLinkHasBeenCopiedToTheClipboard setAlpha:0];
    [_background setImage:[UIImage imageNamed:@"background5 @2x.jpg"]];
    [_testButton setAlpha:0];
    [_shareButton setAlpha:0];
    [_facebookShareButton setAlpha:0];
    [_twitterShareButton setAlpha:0];
    [_messagesShareButton setAlpha:0];
    [_mailShareButton setAlpha:0];
    _kKeychainItemName = @"OAuth2 Sample: Google+";
    _kMyClientID = @"87616694201-13uct6p1sdqf8juh97cnu0900bf1ip7n.apps.googleusercontent.com";  // pre-assigned by service
    _kMyClientSecret = @"dMAzn0VNV9G2a7LCgKQ-hoN7";                                             // pre-assigned by service
    /*
    [self validateUrl:@"aaa"];
    [self validateUrl:@"google.com"];
    [self validateUrl:@"www.google.com"];
    [self validateUrl:@"http://google.com"];
    [self validateUrl:@"http://www.google.com"];
    [_textField setText:[UIPasteboard generalPasteboard].string];
     */
    if ([self handlePasteboardString])
        [self shortenURL:[UIPasteboard generalPasteboard].string];
}

- (void)awakeFromNib
{
    // Get the saved authentication, if any, from the keychain.
    // Retain the authentication object, which holds the auth tokens
    //
    // We can determine later if the auth object contains an access token
    // by calling its -canAuthorize method
    [self setAuth:_auth];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
