#import <Mixpanel/Mixpanel.h>
#import <SVProgressHUD/SVProgressHUD.h>

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
        self.textField.text = [string formattedURL];
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
        [self appear];
        [[UIPasteboard generalPasteboard] setString:self.shortenedURL];
        [SVProgressHUD showSuccessWithStatus:@"Shortened & copied URL!"];
        [[Mixpanel sharedInstance] track:@"URL Shortened"];
        [self.shortenedURLButton setTitle:[self.shortenedURL formattedURL] forState:UIControlStateNormal];
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
        self.arrow.alpha = 1;
        self.urlDisplayUnderShortenedURL.alpha = 0;
        self.shortenedURLButton.alpha = 1;
    }];
}

- (void)disappear {
    [UIView animateWithDuration:.2 animations:^(void) {
        self.arrow.alpha = 0;
        if (self.shortenedURL && self.url) {
            self.urlDisplayUnderShortenedURL.text = [self.url formattedURL];
            self.urlDisplayUnderShortenedURL.alpha = 1;
        }
    }];
    self.textField.text = nil;
}

- (void)openWebView:(UIGestureRecognizer *)gestureRecognizer {
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        [[Mixpanel sharedInstance] track:@"WebView Preview Button Pressed"];
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        [alertController addAction:[UIAlertAction actionWithTitle:@"Open in Safari"
                                                            style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction *action) {
                                                              [[UIApplication sharedApplication] openURL:[NSURL URLWithString:self.shortenedURL]];
                                                          }]];
        [alertController addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
        [self presentViewController:alertController animated:YES completion:nil];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.textField.delegate = self;
    self.textField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"put link here"
                                                                           attributes:@{NSForegroundColorAttributeName: [UIColor lightGrayColor]}];
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
    self.arrow.image = [[UIImage imageNamed:@"arrow"] tintedImageWithColor:[UIColor colorWithWhite:0.25 alpha:1]];
    self.urlDisplayUnderShortenedURL.alpha = 0;
    self.shortenedURLButton.alpha = 0;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    [self.view endEditing:YES];
}

@end
