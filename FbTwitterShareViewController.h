
#import <UIKit/UIKit.h>
#import <FacebookSDK/FacebookSDK.h>
#import <Accounts/Accounts.h>
#import <Social/Social.h>
#import "FHSTwitterEngine.h"
#import "SocialController.h"
#import <unistd.h>
#import <netdb.h>

@interface FbTwitterShareViewController : UIViewController

- (IBAction)facebookPostImage:(id)sender;
- (IBAction)twitterTweetImage:(id)sender;


@end
