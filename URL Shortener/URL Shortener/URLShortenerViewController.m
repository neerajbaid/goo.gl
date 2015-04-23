#import <Mixpanel/Mixpanel.h>
#import <SVWebViewController/SVModalWebViewController.h>

#import "APIConnection.h"
#import "UIImage+URLShortener.h"
#import "URLShortenerViewController.h"

@interface URLShortenerViewController () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (weak, nonatomic) IBOutlet UILabel *shortenedURLLabel;
@property (weak, nonatomic) IBOutlet UILabel *urlDisplayUnderShortenedURL;
@property (weak, nonatomic) IBOutlet UIImageView *arrow;
@property (strong, nonatomic) NSString *url;
@property (strong, nonatomic) NSString *shortenedURL;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;
@property (strong, nonatomic) APIConnection *connection;

@end

@implementation URLShortenerViewController

- (APIConnection *)connection {
    if (!_connection) {
        _connection = [[APIConnection alloc] init];
        _connection.delegate = self;
    }
    return _connection;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    [self disappear];
}

- (BOOL)validateUrl:(NSString *)candidate {
    NSURL *temp = [NSURL URLWithString:candidate];
    BOOL doesNotContainGoogle = [candidate rangeOfString:@"goo.gl"].location == NSNotFound;
    if (temp && temp.scheme && doesNotContainGoogle)
        return TRUE;
    return FALSE;
}

- (BOOL)handlePasteboardString {
    NSString *string = [UIPasteboard generalPasteboard].string;
    if ([self validateUrl:string]) {
        Mixpanel *mixpanel = [Mixpanel sharedInstance];
        [mixpanel track:@"Automatically Copy URL"];
        self.textField.text = string;
        return YES;
    }
    return NO;
}

- (void)shortenURL:(NSString *)url {
    BOOL doesNotContainSpace = [url rangeOfString:@" "].location == NSNotFound;
    BOOL doesNotContainGoogle = [url rangeOfString:@"goo.gl"].location == NSNotFound;
    if (![url isEqualToString:@""] && doesNotContainSpace && doesNotContainGoogle) {
        [self.connection shortenURL:url];
        self.url = url;
        [self.spinner startAnimating];
        [self fadeInSpinner];
    }
}

- (void)apiConnection:(APIConnection *)connection
        didShortenURL:(NSString *)originalURL
       toShortenedURL:(NSString *)shortenedURL {
    if (shortenedURL) {
        self.shortenedURL = shortenedURL;
        NSString *display = @" ";
        self.urlDisplayUnderShortenedURL.text = [display stringByAppendingString:self.url];
        [self.spinner stopAnimating];
        [self fadeOutSpinner];
        [self appear];
        if (self.shortenedURL) {
            [[UIPasteboard generalPasteboard] setString:_shortenedURL];
            [[Mixpanel sharedInstance] track:@"URL Shortened"];
        }
        self.shortenedURLLabel.text = self.shortenedURL;
    } else {
        [self fadeOutSpinner];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    [self shortenURL:textField.text];
    return YES;
}

- (void)fadeInSpinner {
    [UIView animateWithDuration:.2 animations:^(void) {
        [self.spinner setAlpha:1];
    }];
}

- (void)fadeOutSpinner {
    [UIView animateWithDuration:.2 animations:^(void) {
        [self.spinner setAlpha:0];
    }];
}

- (void)appear {
    [UIView animateWithDuration:.2 animations:^(void) {
        self.arrow.alpha = 0.5;
        self.urlDisplayUnderShortenedURL.alpha = 1;
        self.shortenedURLLabel.alpha = 1;
    }];
}

- (void)disappear {
    [UIView animateWithDuration:.2 animations:^(void) {
        [self.arrow setAlpha:0];
    }];
    [self.textField setText:@""];
}

- (void)openWebView:(UIGestureRecognizer *)gestureRecognizer {
    if (gestureRecognizer.state == UIGestureRecognizerStateEnded) {
        [[Mixpanel sharedInstance] track:@"WebView Preview Button Pressed"];
        SVModalWebViewController *modalWebView = [[SVModalWebViewController alloc] initWithAddress:self.shortenedURL];
        [self presentViewController:modalWebView animated:YES completion:nil];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.textField.delegate = self;
    UILongPressGestureRecognizer *longPressGR = [[UILongPressGestureRecognizer alloc] initWithTarget:self
                                                                                              action:@selector(openWebView:)];
    [self hide];
}

- (void)viewWillAppear:(BOOL)animated {
    if ([self handlePasteboardString]) {
        [self shortenURL:[UIPasteboard generalPasteboard].string];
    }
}

- (void)hide {
    self.arrow.alpha = 0;
    self.spinner.alpha = 0;
    self.arrow.image = [[UIImage imageNamed:@"arrow"] tintedImageWithColor:[UIColor whiteColor]];
    self.urlDisplayUnderShortenedURL.alpha = 0;
    self.shortenedURLLabel.alpha = 0;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    [self.view endEditing:YES];
}

@end
