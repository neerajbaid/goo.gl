#import "APIConnection.h"

@implementation APIConnection

- (void)shortenURL:(NSString*)originalURL {
    _longURL = originalURL;
    NSString *googString = @"https://www.googleapis.com/urlshortener/v1/url?key=AIzaSyDfghUKiLsiRK4NbsZWjWFUcM2GGqYVC-k";
    
    NSURL* googUrl = [NSURL URLWithString:googString];
    
    NSMutableURLRequest* googReq = [NSMutableURLRequest requestWithURL:googUrl
                                                           cachePolicy:NSURLRequestReloadIgnoringCacheData
                                                       timeoutInterval:60.0f];
    
    [googReq setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    NSString* longUrlString = [NSString stringWithFormat:@"{\"longUrl\": \"%@\"}", originalURL];
    
    NSData* longUrlData = [longUrlString dataUsingEncoding:NSUTF8StringEncoding];
    [googReq setHTTPBody:longUrlData];
    [googReq setHTTPMethod:@"POST"];
    
    NSURLConnection* connect = [[NSURLConnection alloc] initWithRequest:googReq delegate:self];
    connect = nil;
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    NSError* error = nil;
    if ([[[connection currentRequest] allHTTPHeaderFields] count] == 1 || [[[connection currentRequest] allHTTPHeaderFields] count] == 2) {
        NSArray* jsonArray = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&error];
        NSString* sURL;
        if (error == nil) {
            if ([jsonArray valueForKey:@"id"] != nil) {
                sURL = [jsonArray valueForKey:@"id"];
            }
        }
        [self.delegate apiConnection:self didShortenURL:self.longURL toShortenedURL:sURL];
    } else {
        [self shortenURL:self.longURL];
    }
}

@end
