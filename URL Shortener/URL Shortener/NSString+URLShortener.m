#import "NSString+URLShortener.h"

@implementation NSString (URLShortener)

- (BOOL)isValidURL {
    BOOL doesNotContainGoogle = [self rangeOfString:@"goo.gl"].location == NSNotFound;
    if (doesNotContainGoogle) {
        return TRUE;
    }
    return FALSE;
}

- (NSString *)formattedURL {
    NSURL *selfURL = [NSURL URLWithString:self];
    if (selfURL.host) {
        return [selfURL.absoluteString substringFromIndex:[selfURL.absoluteString rangeOfString:selfURL.host].location];
    } else {
        return self;
    }
}

@end
