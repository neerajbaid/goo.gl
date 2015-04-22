#import <Foundation/Foundation.h>

@class APIConnection;
@protocol URLRecipient <NSObject>

- (void)apiConnection:(APIConnection *)connection didShortenURL:(NSString *)originalURL toShortenedURL:(NSString *)shortenedURL;

@end

@interface APIConnection : NSObject <NSURLConnectionDelegate>

- (void)shortenURL:(NSString*)originalURL;

@property (nonatomic, weak) id <URLRecipient> delegate;
@property (nonatomic, strong) NSString *longURL;

@end
