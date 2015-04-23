#import <Mixpanel/Mixpanel.h>
#import <SVProgressHUD/SVProgressHUD.h>
#import <SVWebViewController/SVModalWebViewController.h>

#import "APIConnection.h"
#import "NSString+URLShortener.h"
#import "UIImage+URLShortener.h"
#import "URLShortenerViewController.h"

@interface URLShortenerViewController () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (weak, nonatomic) IBOutlet UIButton *shortenedURLButton;
@property (weak, nonatomic) IBOutlet UILabel *urlDisplayUnderShortenedURL;
@property (weak, nonatomic) IBOutlet UIImageView *arrow;
@property (strong, nonatomic) NSString *url;
@property (strong, nonatomic) NSString *shortenedURL;
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

- (void)handlePasteboardString {
    NSString *string = [UIPasteboard generalPasteboard].string;
    if ([string isValidURL]) {
        [[Mixpanel sharedInstance] track:@"Automatically Copy URL"];
        self.textField.text = string;
        [self shortenURL:string];
    }
}

- (void)shortenURL:(NSString *)url {
    if ([url isValidURL]) {
        [self.connection shortenURL:url];
        self.url = url;
        [SVProgressHUD show];
    } else {
        [SVProgressHUD showErrorWithStatus:@"Invalid URL"];
    }
}

- (void)apiConnection:(APIConnection *)connection
        didShortenURL:(NSString *)originalURL
       toShortenedURL:(NSString *)shortenedURL {
    if (shortenedURL) {
        self.shortenedURL = shortenedURL;
        NSString *display = @" ";
        self.urlDisplayUnderShortenedURL.text = [display stringByAppendingString:self.url];
        [self appear];
        [[UIPasteboard generalPasteboard] setString:self.shortenedURL];
        [SVProgressHUD showSuccessWithStatus:@"Shortened & copied URL!"];
        [[Mixpanel sharedInstance] track:@"URL Shortened"];
        [self.shortenedURLButton setTitle:self.shortenedURL forState:UIControlStateNormal];
    } else {
        [SVProgressHUD showErrorWithStatus:@"Error"];
    }
}

- (IBAction)copyShortenedURL:(id)sender {
    [[UIPasteboard generalPasteboard] setString:self.shortenedURL];
    [SVProgressHUD showSuccessWithStatus:@"Copied!"];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    [self shortenURL:textField.text];
    return YES;
}

- (void)appear {
    [UIView animateWithDuration:.2 animations:^(void) {
        self.arrow.alpha = 0.5;
        self.urlDisplayUnderShortenedURL.alpha = 1;
        self.shortenedURLButton.alpha = 1;
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
    [self.shortenedURLButton addGestureRecognizer:longPressGR];
    [self hide];
    [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationWillResignActiveNotification
                                                      object:nil
                                                       queue:[NSOperationQueue mainQueue]
                                                  usingBlock:^(NSNotification *note) {
                                                      [self disappear];
                                                  }];
    [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationWillEnterForegroundNotification
                                                      object:nil
                                                       queue:[NSOperationQueue mainQueue]
                                                  usingBlock:^(NSNotification *note) {
                                                      [self handlePasteboardString];
                                                  }];
}

- (void)hide {
    self.arrow.alpha = 0;
    self.arrow.image = [[UIImage imageNamed:@"arrow"] tintedImageWithColor:[UIColor whiteColor]];
    self.urlDisplayUnderShortenedURL.alpha = 0;
    self.shortenedURLButton.alpha = 0;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    [self.view endEditing:YES];
}

@end
