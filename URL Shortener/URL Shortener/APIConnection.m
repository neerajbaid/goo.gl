//
//  APIConnection.m
//  URL Shortener
//
//  Created by Neeraj Baid on 3/10/13.
//  Copyright (c) 2013 Neeraj Baid. All rights reserved.
//

#import "APIConnection.h"

@implementation APIConnection

- (void)shortenURL:(NSString*)originalURL
{
    NSString *googString;
    /*
    if ([self.delegate isSignedIn])
    {
        googString = @"https://www.googleapis.com/urlshortener/v1/url?fields=id&key=AIzaSyDfghUKiLsiRK4NbsZWjWFUcM2GGqYVC-k";
    }
    else
    {
     */
        googString = @"https://www.googleapis.com/urlshortener/v1/url?key=AIzaSyDfghUKiLsiRK4NbsZWjWFUcM2GGqYVC-k";
//    }
    
    NSURL* googUrl = [NSURL URLWithString:googString];
    
    NSMutableURLRequest* googReq = [NSMutableURLRequest requestWithURL:googUrl
                                                           cachePolicy:NSURLRequestReloadIgnoringCacheData
                                                       timeoutInterval:60.0f];
    
    [googReq setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    if ([self.delegate isSignedIn])
        [googReq setValue: [NSString stringWithFormat:@"Bearer %@", [[self.delegate auth] accessToken]] forHTTPHeaderField:@"Authorization"];
        
    NSString* longUrlString = [NSString stringWithFormat:@"{\"longUrl\": \"%@\"}", originalURL];
        
    NSData* longUrlData = [longUrlString dataUsingEncoding:NSUTF8StringEncoding];
    [googReq setHTTPBody:longUrlData];
    [googReq setHTTPMethod:@"POST"];
    
    NSURLConnection* connect = [[NSURLConnection alloc] initWithRequest:googReq delegate:self];
    connect = nil;
}

/*
 - (void)shortenURL:(NSString*)originalURL
 {
 NSString *googString;
 googString = @"https://www.googleapis.com/urlshortener/v1/url?key=AIzaSyDfghUKiLsiRK4NbsZWjWFUcM2GGqYVC-k";
 
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
 */

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    NSError* error = nil;
 
    NSArray* jsonArray = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&error];
    
//    NSLog(@"%@", [jsonArray description]);
    
    NSString* sURL;
    if (error == nil)
    {
        NSLog(@"%@", [jsonArray description]);
        if ([jsonArray valueForKey:@"id"] != nil)
            sURL = [jsonArray valueForKey:@"id"];
    }
    else
        NSLog(@"Error %@", error);
    
    [self.delegate recieveShortenedURL:sURL];
    
//    NSLog(@"Returned URL: %@", sURL);
}

@end
