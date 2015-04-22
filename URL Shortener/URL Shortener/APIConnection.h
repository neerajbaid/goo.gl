#import <Foundation/Foundation.h>

@protocol URLRecipient <NSObject>

- (void)recieveShortenedURL:(NSString *)shortenedURL;
- (BOOL)isSignedIn;

@end

@interface APIConnection : NSObject <NSURLConnectionDelegate>

-(void)shortenURL:(NSString*)originalURL;

@property (nonatomic, weak) id <URLRecipient> delegate;
@property (nonatomic, strong) NSString *longURL;

@end
