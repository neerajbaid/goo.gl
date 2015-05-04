#import <NotificationCenter/NotificationCenter.h>
#import <URLShortenerKit/URLShortenerKit.h>

#import "TodayViewController.h"

@interface TodayViewController () <NCWidgetProviding, USKShortenerDelegate>

@property (weak, nonatomic) IBOutlet UIButton *shortenButton;
@property (nonatomic, strong) USKShortener *shortener;

@end

@implementation TodayViewController

- (USKShortener *)shortener {
    if (!_shortener) {
        _shortener = [[USKShortener alloc] initWithDelegate:self];
    }
    return _shortener;
}

- (void)viewDidLoad {
    self.preferredContentSize = CGSizeMake(self.view.frame.size.width, 37);
}

- (void)widgetPerformUpdateWithCompletionHandler:(void (^)(NCUpdateResult))completionHandler {
    [self.shortenButton setTitle:@"shorten my url"
                        forState:UIControlStateNormal];
    completionHandler(NCUpdateResultNewData);
}

- (IBAction)shorten:(id)sender {
    NSString *string = [UIPasteboard generalPasteboard].string;
//    [[Mixpanel sharedInstance] track:@"Automatically Copy URL"];
    [self.shortener shortenURL:string];
}

- (void)shortener:(USKShortener *)shortener didShortenURL:(NSString *)originalURL toShortenedURL:(NSString *)shortenedURL {
    [[UIPasteboard generalPasteboard] setString:shortenedURL];
    [self.shortenButton setTitle:@"shortened & copied url!"
                        forState:UIControlStateNormal];
}

- (void)shortener:(USKShortener *)shortener
failedToShortenURL:(NSString *)originalURL {
    
}

@end
