#import <MobileCoreServices/MobileCoreServices.h>

#import "ActionViewController.h"

@interface ActionViewController ()

@property(strong,nonatomic) IBOutlet UIImageView *imageView;

@end

@implementation ActionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    BOOL found = NO;
    for (NSExtensionItem *item in self.extensionContext.inputItems) {
        for (NSItemProvider *itemProvider in item.attachments) {
            if ([itemProvider hasItemConformingToTypeIdentifier:(NSString *)kUTTypeURL]) {
                [itemProvider loadItemForTypeIdentifier:(NSString *)kUTTypeURL
                                                options:nil
                                      completionHandler:^(NSURL *url, NSError *error) {
                                          
                                      }];
                
                found = YES;
                break;
            }
        }
        if (found) {
            break;
        }
    }
}

- (IBAction)done {
    [self.extensionContext completeRequestReturningItems:self.extensionContext.inputItems completionHandler:nil];
}

@end
