//
//  APIConnection.h
//  URL Shortener
//
//  Created by Neeraj Baid on 3/10/13.
//  Copyright (c) 2013 Neeraj Baid. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GTMOAuth2Authentication.h"

@protocol URLRecipient <NSObject>

- (void)recieveShortenedURL:(NSString *)shortenedURL;
- (BOOL)isSignedIn;
- (GTMOAuth2Authentication *)auth;

@end

@interface APIConnection : NSObject <NSURLConnectionDelegate>

-(void)shortenURL:(NSString*)originalURL;

@property (nonatomic, weak) id <URLRecipient> delegate;
@property (nonatomic, strong) NSString *longURL;

@end
