
#import <Foundation/Foundation.h>
#import <Social/Social.h>
#import <Accounts/Accounts.h>
#import <FacebookSDK/FacebookSDK.h>
#import "FHSTwitterEngine.h"

typedef void (^FacebookPostCompletionBlock)(NSString *responseData,NSError *error);
typedef void (^TwitterTweetCompletionBlock)(NSString *responseData,NSError *error);

@interface SocialController : UIViewController<FHSTwitterEngineAccessTokenDelegate,UIActionSheetDelegate>
{
    
}
-(void)UserSelectedFacebook:(UIViewController *)vc withStatus:(NSString *)string withAppId:(NSString *)appId withLink:(NSURL *)link completionBlock:(FacebookPostCompletionBlock) completionBlock;//appid is required

-(void)shareViaTwitter:(UIViewController *)vc  withTweet:(NSString *)string withLink:(NSURL *)url withKey:(NSString *)keyForFHST withTwitterSecret:(NSString *)secretForFHST completionBlock:(TwitterTweetCompletionBlock) completionBlock;

@property(nonatomic,strong)NSData *tempImgDataFromYourVC;

@end
