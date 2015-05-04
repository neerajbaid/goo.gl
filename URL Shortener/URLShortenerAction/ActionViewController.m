#import <Mixpanel/Mixpanel.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import <URLShortenerKit/URLShortenerKit.h>

#import "ActionViewController.h"

@interface ActionViewController () <USKShortenerDelegate>

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (strong, nonatomic) USKShortener *shortener;

@end

@implementation ActionViewController

- (USKShortener *)shortener {
    if (!_shortener) {
        _shortener = [[USKShortener alloc] initWithDelegate:self];
    }
    return _shortener;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    BOOL found = NO;
    for (NSExtensionItem *item in self.extensionContext.inputItems) {
        for (NSItemProvider *itemProvider in item.attachments) {
            if ([itemProvider hasItemConformingToTypeIdentifier:(NSString *)kUTTypeURL]) {
                [itemProvider loadItemForTypeIdentifier:(NSString *)kUTTypeURL
                                                options:nil
                                      completionHandler:^(NSURL *url, NSError *error) {
                                          dispatch_async(dispatch_get_main_queue(), ^{
                                              [self.spinner startAnimating];
                                          });
                                          [self.shortener shortenURL:[url absoluteString]];
                                      }];
                
                found = YES;
                break;
            }
        }
        if (found) {
            break;
        }
    }
}

- (void)shortener:(USKShortener *)shortener
    didShortenURL:(NSString *)originalURL
   toShortenedURL:(NSString *)shortenedURL {
    self.statusLabel.text = @"shortened & copied URL!";
    [[UIPasteboard generalPasteboard] setString:shortenedURL];
    [[Mixpanel sharedInstance] track:@"URL Shortened" properties:@{@"source":@"action"}];
    [self done];
}

- (void)shortener:(USKShortener *)shortener failedToShortenURL:(NSString *)originalURL {
    self.statusLabel.text = @"shorten failed";
    [self done];
}

- (void)done {
    [UIView animateWithDuration:0.2 animations:^{
        self.spinner.alpha = 0;
        self.statusLabel.alpha = 1;
    } completion:^(BOOL finished) {
        [self.spinner stopAnimating];
        [self performSelector:@selector(complete)
                   withObject:nil
                   afterDelay:1];
    }];
}

- (void)complete {
    [self.extensionContext completeRequestReturningItems:self.extensionContext.inputItems
                                       completionHandler:nil];
}

@end
