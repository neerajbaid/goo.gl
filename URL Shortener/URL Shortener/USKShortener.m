#import "USKShortener.h"

@implementation USKShortener

- (instancetype)initWithDelegate:(id<USKShortenerDelegate>)delegate {
    self = [super init];
    if (self) {
        self.delegate = delegate;
    }
    return self;
}

- (void)shortenURL:(NSString*)originalURL {
    NSString *googString = @"https://www.googleapis.com/urlshortener/v1/url?key=AIzaSyDfghUKiLsiRK4NbsZWjWFUcM2GGqYVC-k";
    NSMutableURLRequest* googReq = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:googString]
                                                           cachePolicy:NSURLRequestReloadIgnoringCacheData
                                                       timeoutInterval:60.0f];
    [googReq setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    NSString* longUrlString = [NSString stringWithFormat:@"{\"longUrl\": \"%@\"}", originalURL];
    NSData* longUrlData = [longUrlString dataUsingEncoding:NSUTF8StringEncoding];
    [googReq setHTTPBody:longUrlData];
    [googReq setHTTPMethod:@"POST"];
    [NSURLConnection sendAsynchronousRequest:googReq
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                               if (data) {
                                   NSDictionary *info = [NSJSONSerialization JSONObjectWithData:data
                                                                                        options:NSJSONReadingAllowFragments
                                                                                          error:nil];
                                   NSString *shortenedURL = info[@"id"];
                                   if (shortenedURL) {
                                       [self.delegate shortener:self didShortenURL:originalURL toShortenedURL:info[@"id"]];
                                   } else {
                                       [self.delegate shortener:self failedToShortenURL:originalURL];
                                   }
                               } else {
                                   [self.delegate shortener:self failedToShortenURL:originalURL];
                               }
                           }];
}

@end
