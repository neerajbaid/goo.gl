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
    _longURL = originalURL;
    NSString *googString = @"https://www.googleapis.com/urlshortener/v1/url?key=AIzaSyDfghUKiLsiRK4NbsZWjWFUcM2GGqYVC-k";
    
    NSURL* googUrl = [NSURL URLWithString:googString];
    
    NSMutableURLRequest* googReq = [NSMutableURLRequest requestWithURL:googUrl
                                                           cachePolicy:NSURLRequestReloadIgnoringCacheData
                                                       timeoutInterval:60.0f];
    
    [googReq setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    if ([self.delegate isSignedIn])
    {
        NSLog(@"test1");
        [googReq setValue: [NSString stringWithFormat:@"Bearer %@", [[self.delegate auth] accessToken]] forHTTPHeaderField:@"Authorization"];
    }
    
    NSString* longUrlString = [NSString stringWithFormat:@"{\"longUrl\": \"%@\"}", originalURL];
        
    NSData* longUrlData = [longUrlString dataUsingEncoding:NSUTF8StringEncoding];
    [googReq setHTTPBody:longUrlData];
    [googReq setHTTPMethod:@"POST"];
    
    NSLog(@"test1.2");
    
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

- (void)refreshAccessToken
{
    NSURL *googURL = [NSURL URLWithString:@"https://accounts.google.com/o/oauth2/token"];

    NSMutableURLRequest *googReq = [NSMutableURLRequest requestWithURL:googURL
                                                           cachePolicy:NSURLRequestReloadIgnoringCacheData
                                                       timeoutInterval:60.0f];
    NSLog(@"test2");
    
    NSString *body;
    
    [googReq setHTTPMethod:@"POST"];
    
    body = [NSString stringWithFormat:@"client_id=%@&", [[self.delegate auth] clientID]];
    body = [body stringByAppendingString:[NSString stringWithFormat:@"client_secret=%@&", [[self.delegate auth] clientSecret]]];
    body = [body stringByAppendingString:[NSString stringWithFormat:@"refresh_token=%@&", [[self.delegate auth] refreshToken]]];
    body = [body stringByAppendingString:[NSString stringWithFormat:@"grant_type=refresh_token"]];
    
    [googReq setHTTPBody:[body dataUsingEncoding:NSUTF8StringEncoding]];

    NSURLConnection *connect = [[NSURLConnection alloc] initWithRequest:googReq delegate:self];
    connect = nil;
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    NSError* error = nil;
    
    if ([[[connection currentRequest] allHTTPHeaderFields] count] == 1 || [[[connection currentRequest] allHTTPHeaderFields] count] == 2)
    {
        NSLog(@"test3");
        NSArray* jsonArray = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&error];
        
        NSLog(@"%@", [jsonArray description]);
        
        if ([[[jsonArray valueForKey:@"error"] valueForKey:@"code"] isEqual:[NSNumber numberWithInt:401]])
        {
            NSLog(@"test4");
            [self refreshAccessToken];
        }
        else
        {
            NSLog(@"test5");
            NSString* sURL;
            if (error == nil)
            {
                NSLog(@"test6");
                if ([jsonArray valueForKey:@"id"] != nil)
                    sURL = [jsonArray valueForKey:@"id"];
            }
            else
            {
                NSLog(@"test7");
                NSLog(@"Error %@", error);
            }
            NSLog(@"test8");
            [self.delegate recieveShortenedURL:sURL];
        }
    }
    else
    {
        NSLog(@"test9");
        NSArray* jsonArray = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&error];
        NSLog(@"%@", [[self.delegate  auth] accessToken]);
        NSString *accessToken = [jsonArray valueForKey:@"access_token"];
        NSLog(@"%@", accessToken);
        [[self.delegate auth] setAccessToken:accessToken];
        [self shortenURL:_longURL];
    }
}

@end
