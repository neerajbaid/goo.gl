#import <Foundation/Foundation.h>

@class USKShortener;
@protocol USKShortenerDelegate <NSObject>

- (void)shortener:(USKShortener *)shortener
    didShortenURL:(NSString *)originalURL
   toShortenedURL:(NSString *)shortenedURL;
- (void)shortener:(USKShortener *)shortener failedToShortenURL:(NSString *)originalURL;

@end

@interface USKShortener : NSObject

- (instancetype)initWithDelegate:(id<USKShortenerDelegate>)delegate;
- (void)shortenURL:(NSString *)originalURL;

@property (nonatomic, weak) id<USKShortenerDelegate> delegate;

@end
