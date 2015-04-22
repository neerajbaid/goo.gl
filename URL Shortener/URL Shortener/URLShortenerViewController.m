#import "URLShortenerViewController.h"
#import "APIConnection.h"
#import "WebViewController.h"
#import "Mixpanel.h"

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

@property (weak, nonatomic) IBOutlet UIButton *facebookShareButton;
@property (weak, nonatomic) IBOutlet UIButton *twitterShareButton;
@property (weak, nonatomic) IBOutlet UIButton *messagesShareButton;
@property (weak, nonatomic) IBOutlet UIButton *shareButton;
@property (weak, nonatomic) IBOutlet UIButton *mailShareButton;

@property (strong, nonatomic) NSString *kKeychainItemName;
@property (strong, nonatomic) NSString *kMyClientID;
@property (strong, nonatomic) NSString *kMyClientSecret;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *signInBarButtonItem;

@end

@implementation URLShortenerViewController

- (APIConnection *)connection
{
    if (!_connection)
        _connection = [[APIConnection alloc] init];
    _connection.delegate = self;
    return _connection;
}

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
    if ([self validateUrl:string]) {
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
    NSLog(@"test3");
    [super viewDidLoad];
    
    self.textField.delegate = self;
    
    UITapGestureRecognizer *tapGR = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:tapGR];
    
    UILongPressGestureRecognizer *longPressGR = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(openWebView:)];
    [self.testButton addGestureRecognizer:longPressGR];
    
    [_arrow setAlpha:0];
    [_spinner setAlpha:0];
    [_urlHasBeenShortened setAlpha:0];
    [_urlDisplayUnderShortenedURL setAlpha:0];
    [_shortenedLinkHasBeenCopiedToTheClipboard setAlpha:0];
    if ([[[UIDevice currentDevice] systemVersion] doubleValue] > 6.9)
        [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"top bar iOS7.png"] forBarMetrics:UIBarMetricsDefault];
    else
        [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"top bar.png"] forBarMetrics:UIBarMetricsDefault];
    [_background setImage:[UIImage imageNamed:@"background2 @2x.jpg"]];
    [_testButton setAlpha:0];
    [_shareButton setAlpha:0];
    [_facebookShareButton setAlpha:0];
    [_twitterShareButton setAlpha:0];
    [_messagesShareButton setAlpha:0];
    [_mailShareButton setAlpha:0];
    _kKeychainItemName = @"OAuth2 Sample: Google+";
    _kMyClientID = @"87616694201-13uct6p1sdqf8juh97cnu0900bf1ip7n.apps.googleusercontent.com";  // pre-assigned by service
    _kMyClientSecret = @"dMAzn0VNV9G2a7LCgKQ-hoN7";                                             // pre-assigned by service
    if ([self handlePasteboardString]) {
        [self shortenURL:[UIPasteboard generalPasteboard].string];
    }
}

@end
