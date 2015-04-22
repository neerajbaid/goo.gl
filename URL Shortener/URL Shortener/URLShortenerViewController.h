#import <UIKit/UIKit.h>
#import "APIConnection.h"
#import <Security/Security.h>
#import <SystemConfiguration/SystemConfiguration.h>

@interface URLShortenerViewController : UIViewController <URLRecipient>

- (BOOL)validateUrl:(NSString *)candidate;
- (BOOL)handlePasteboardString;
- (void)shortenURL:(NSString *)url;
- (void)disappear;

@end
