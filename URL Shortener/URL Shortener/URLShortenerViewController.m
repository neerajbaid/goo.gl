//
//  URLShortenerViewController.m
//  URL Shortener
//
//  Created by Neeraj Baid on 2/13/13.
//  Copyright (c) 2013 Neeraj Baid. All rights reserved.
//

#import "URLShortenerViewController.h"
#import "APIConnection.h"

@interface URLShortenerViewController () <UITextFieldDelegate>

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




//@property (nonatomic) int test; //switcher variable

@end

@implementation URLShortenerViewController

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
        [_textField setText:string];
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
            [[UIPasteboard generalPasteboard] setString:_shortenedURL];
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

- (void)openWebView
{
        [self performSegueWithIdentifier:@"showWebView" sender:self];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.textField.delegate = self;
    
    UITapGestureRecognizer *tapGR = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:tapGR];
    
    UILongPressGestureRecognizer *longPressGR = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(openWebView)];
    [self.testButton addGestureRecognizer:longPressGR];
    
	//[_navigationBar setBackgroundImage:[UIImage imageNamed:@"top bar.png"] forBarMetrics:UIBarMetricsDefault];
    [_arrow setAlpha:0];
    [_spinner setAlpha:0];
    [_urlHasBeenShortened setAlpha:0];
    [_urlDisplayUnderShortenedURL setAlpha:0];
    [_shortenedLinkHasBeenCopiedToTheClipboard setAlpha:0];
    [_background setImage:[UIImage imageNamed:@"background5 @2x.jpg"]];
    [_testButton setAlpha:0];
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
