#import "NSString+URLShortener.h"

@implementation NSString (URLShortener)

- (BOOL)isValidURL {
    BOOL doesNotContainGoogle = [self rangeOfString:@"goo.gl"].location == NSNotFound;
    if (doesNotContainGoogle) {
        return TRUE;
    }
    return FALSE;
}

@end
