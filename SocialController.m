
#import "SocialController.h"

NSString * urlFromString;
NSString * imageStringFromURL;
NSString * linkStringFromURL;
NSData *imgDataFromYourVC;

TwitterTweetCompletionBlock completionBlockForTwitter;
BOOL permissionsGiven;
BOOL errorForSettings;

@implementation SocialController
{
    ACAccount * facebookAccount;
    NSArray *fbAccounts; // array containing all facebook accounts.
    ACAccountType *twitterAccountType;
    NSArray *arrContainingTwitterAccounts; // array containing all twitter accounts.
    NSArray * userNamesInTwitter; // array containing loggedin user names.
    UIViewController * rootViewController;
    NSDictionary * twitterUserData;
    ACAccountStore * accountStore;
    NSString * key;
    NSMutableArray * completionArray;
    NSString * twitterKey;
    NSString * twitterSecret;
    BOOL sessionFlag;
    FacebookPostCompletionBlock completionBlockForFacebook;
}
@synthesize tempImgDataFromYourVC;

-(void)viewDidLoad
{
    
}

// method to send post using facebook.
-(void)UserSelectedFacebook:(UIViewController *)vc withStatus:(NSString *)string withAppId:(NSString *)appId withLink:(NSURL *)link completionBlock:(FacebookPostCompletionBlock) completionBlock
{
    
    completionBlockForFacebook = completionBlock; // getting the completion block to Global variable of completion block.
    NSLog(@"%@",fbAccounts);
   
    urlFromString=[NSString stringWithFormat:@"%@",string]; // converting the obtained url to string.
    //imageStringFromURL=[NSString stringWithFormat:@"%@",imageURL]; // converting the obtained url to string.
    linkStringFromURL=[NSString stringWithFormat:@"%@",link]; // converting the obtained url to string.
   
    
    key= appId; // Facebook App Id
    NSThread * thread = [[NSThread alloc] initWithTarget:self selector:@selector(loadThread) object:nil];
    [thread start];
    
}

-(void)loadThread
{
    @autoreleasepool {
        
        
        accountStore = [[ACAccountStore alloc] init]; // accountStore object is initialised;
        ACAccountType * facebookAcct = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierFacebook]; // giving facebook identifier to ACAccount store.
        
        NSDictionary *dictionaryFB = [NSDictionary dictionaryWithObjectsAndKeys:key,ACFacebookAppIdKey,@[@"email",@"publish_actions"],ACFacebookPermissionsKey, ACFacebookAudienceEveryone,ACFacebookAudienceKey,nil]; // A dictionary consisting of the parameters to be requested;
        
        [accountStore requestAccessToAccountsWithType:facebookAcct options:dictionaryFB completion:^(BOOL granted, NSError *error)
         {
             if(granted)
             {
                 
                  permissionsGiven=YES;
                 
             }
             else
             {
                 permissionsGiven=NO;
                 
             }
             if(error.userInfo.allValues.count!=0)
             {
                 errorForSettings=YES;
             }
             else
             {
                 errorForSettings=NO;
             }
                 
             
             fbAccounts = [accountStore accountsWithAccountType:facebookAcct]; // An array of facebook accounts are obtained from the account store;
             facebookAccount=[fbAccounts lastObject];
             NSLog(@"%lu",(unsigned long)[fbAccounts count]);
             NSLog(@"%@",error.description);
             if([fbAccounts count]!=0)
             {
                 
                 [self performSelectorOnMainThread:@selector(postViaSettingsFacebookAccount) withObject:nil waitUntilDone:YES];
             }
             else
             {
                 
                 //[self performSelectorOnMainThread:@selector(postViaFacebookBrowser:) withObject:nil waitUntilDone:YES]; // calling the selector after getting the accounts in ACAccount store.
                 [self performSelectorOnMainThread:@selector(postViaFacebookBrowser) withObject:nil waitUntilDone:YES]; // calling the selector after getting the accounts in ACAccount store.
             }
         }];
    }
}

-(NSString *)dateString
{
    //getting date
    NSCalendar *calendar1= [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSCalendarUnit unitFlags1 = NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit;
    NSDate *todayDate1 = [NSDate date];
    NSDateComponents *dateComponents1 = [calendar1 components:unitFlags1 fromDate:todayDate1];
    
    NSInteger year = [dateComponents1 year];//year
    NSInteger month = [dateComponents1 month];//month
    NSInteger day = [dateComponents1 day];//day
    NSInteger hour=[dateComponents1 hour];
    NSInteger minute=[dateComponents1 minute];
    NSInteger second=[dateComponents1 second];
    
    NSString * ampm;
    if(hour<12)
    {
        ampm=@"AM";
        
    }
    else
    {
        ampm=@"PM";
    }
    
    NSString * calenderString=[NSString stringWithFormat:@"%d:%d:%d %@                           %d-%d-%d",hour,minute,second,ampm,day,month,year];
    
    return calenderString;
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex==[userNamesInTwitter count])
    {
        completionBlockForTwitter(@"cancelled",nil);
    }
    else
    {
        NSURL *url = [NSURL URLWithString:@"https://api.twitter.com"
                      @"/1.1/statuses/update_with_media.json"];
        //NSDictionary *params = @{@"screen_name" :userNamesInTwitter[indexPath.row],@"include_rts" : @"0", @"trim_user" : @"1", @"count" : @"1"};
        NSString *tweetString=[NSString stringWithFormat:@"Picture from Your App on %@",[self dateString]];
        NSDictionary * params=@{@"status": tweetString};
        SLRequest *request = [SLRequest requestForServiceType:SLServiceTypeTwitter requestMethod:SLRequestMethodPOST  URL:url  parameters:params];
        // [request addMultipartData:imageData withName:@"media[]" type:@"image/jpeg"
        // filename:@"image.jpg"];
        //  Attach an account to the request
        
        
        //UIImage *image = [UIImage imageNamed:@"twitterShare.png"];
        
        //NSData *imageData = UIImageJPEGRepresentation(image, 1.0f);
//        [request addMultipartData:imageData
//                         withName:@"image"
//                             type:@"image/jpeg"
//                         filename:nil];
        if(tempImgDataFromYourVC)
        {
            imgDataFromYourVC=tempImgDataFromYourVC;
            [request addMultipartData:tempImgDataFromYourVC
                             withName:@"media[]"
                                 type:@"image/jpeg"
                             filename:@"image.jpg"];
        }
        
       
        [request setAccount:arrContainingTwitterAccounts[buttonIndex]];
        
        [request performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error)
         {
             
             if (responseData)
             {
                 if (urlResponse.statusCode >= 200 && urlResponse.statusCode < 300)
                 {
                     
                     NSError *jsonError;
                     twitterUserData =[NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingAllowFragments error:&jsonError];
                     if (twitterUserData) // if data obtainedfrom the Slrequest
                     {
                         NSLog(@"Userdata Response: %@\n", twitterUserData);
                         completionBlockForTwitter(@"Tweeted Successfully",error); // setting the values of response and error in completioblock
                     }
                     else
                     {
                         // Our JSON deserialization went awry
                         NSLog(@"JSON Error: %@", [jsonError localizedDescription]);
                         completionBlockForTwitter(@"Not Success",error); // setting the values of response and error as not success and obtainede error.
                     }
                     
                 }
                 else
                 {
                     // The server did not respond ... were we rate-limited?
                     NSLog(@"The response status code is %ld",
                           (long)urlResponse.statusCode);
                     completionBlockForTwitter(@"Sorry try again later",error);
                 }
             }
         }];// performing request to get the desired data;
        
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

//facebook share via settings
-(void)postViaSettingsFacebookAccount
{
    if (facebookAccount&&permissionsGiven&&errorForSettings==NO)
    {
        
        [accountStore renewCredentialsForAccount:facebookAccount completion:^(ACAccountCredentialRenewResult renewResult, NSError *error) // requesting the account store to renew credentials;
         {
             switch (renewResult) // renewresult returns integers
             {
                 case ACAccountCredentialRenewResultRenewed: // if account credentials are renewed;
                 {
                     NSLog(@"Renewed");
                     break;
                 }
                 case ACAccountCredentialRenewResultFailed: // if account credentials renewal is failed;
                 {
                     NSLog(@"Renewed Failed");
                     facebookAccount = nil;
                     break;
                 }
                 case ACAccountCredentialRenewResultRejected: // if account credentials renewal is rejected;
                 {
                     NSLog(@"Renewed Rejected");
                     break;
                 }
                 default:
                     break;
             }
             
         }];
        
        ACAccountCredential *fbCredential = [facebookAccount credential];
        NSString *accessToken = [fbCredential oauthToken];
        NSString *userId = [NSString stringWithFormat:@"%@", [[facebookAccount valueForKey:@"properties"] valueForKey:@"uid"]]; // To get userId from the device logged facebook account;
        NSString *urlString = [NSString stringWithFormat:@"https://graph.facebook.com/%@/photos?access_token=%@",userId,accessToken]; // initializing the string to post using graph api.
        NSLog(@" uid :%@    accToken:%@",userId,accessToken);
        NSURL * postURL=[NSURL URLWithString:urlString];
        
        //NSDictionary *  parameters = @{@"message":@"chijmes"};
        SLRequest *feedRequest = [SLRequest requestForServiceType:SLServiceTypeFacebook requestMethod:SLRequestMethodPOST URL:postURL parameters:nil]; // initializing the SLRequest with the url.
        
        if(tempImgDataFromYourVC)
        {
            [feedRequest addMultipartData: tempImgDataFromYourVC
                             withName:@"source"
                                 type:@"multipart/form-data"
                             filename:@"TestImage"];
        }
        //  Attach an account to the request
        
        
        feedRequest.account = facebookAccount;
        [feedRequest performRequestWithHandler:^(NSData *responseData,NSHTTPURLResponse *urlResponse, NSError *error)
         {
             NSString * response=[[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
             NSRange equalRange = [response rangeOfString:@"error" options:NSBackwardsSearch];
             if (equalRange.location != NSNotFound)
             {
                 NSLog(@"%@",response);
                 
                 id json = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingAllowFragments error:nil];
                 
                 NSLog(@"%@",[[json objectForKey:@"error"]objectForKey:@"message"]);
                 NSString * result=[[json objectForKey:@"error"]objectForKey:@"message"];
                 
                 [self performSelectorOnMainThread:@selector(statusFeedBackForFaceBook:) withObject:result waitUntilDone:YES];
                 
                 
             } else
             {
                 [self performSelectorOnMainThread:@selector(statusFeedBackForFaceBook:) withObject:@"Posted Successfully" waitUntilDone:YES];
             }
         }];
    }//end if
    else
    {
        if(errorForSettings==NO)
        {
            [self performSelectorOnMainThread:@selector(statusFeedBackForFaceBook:) withObject:@"Grant Permissions and try later" waitUntilDone:YES];
        }
        else
        {
            [self performSelectorOnMainThread:@selector(statusFeedBackForFaceBook:) withObject:@"Error: This may be because the user changed the password since the time the session was created or Facebook has changed the session for security reasons" waitUntilDone:YES];
            
        }
    }
    
}

//facebook share via browser
-(void)postViaFacebookBrowser
{
    // Initialize a session object
    FBSession *session = [[FBSession alloc]initWithPermissions:@[@"publish_actions"]];// Set the active session
    [FBSession setActiveSession:session];
    // Open the session
    sessionFlag=TRUE;
    
    [session openWithBehavior:FBSessionLoginBehaviorWithFallbackToWebView completionHandler:^(FBSession *session,FBSessionState status,NSError *error)
     {
         
         // Respond to session state changes,
         // ex: updating the view
         NSLog(@"session status :%u",status);
         NSLog(@"%@",error.description);
         
         if(status==257||status==258)
         {
             [FBSession.activeSession closeAndClearTokenInformation];
             //completionBlockForFacebook(@"Try after some time",nil);
            
         }
         else if(status==513)
         {
             //NSLog(@"%lu",(unsigned long)[FBSession.activeSession.permissions indexOfObject:@"publish_actions"]);
            
             if([FBSession.activeSession isOpen])
             {
                 
                 FBRequestConnection *connection = [[FBRequestConnection alloc] init]; // requesting connection
                 connection.errorBehavior = FBRequestConnectionErrorBehaviorReconnectSession | FBRequestConnectionErrorBehaviorAlertUser | FBRequestConnectionErrorBehaviorRetry;
                 if(tempImgDataFromYourVC)
                 {
                 [connection addRequest:[FBRequest requestForUploadPhoto:[UIImage imageWithData:tempImgDataFromYourVC]]
                      completionHandler:^(FBRequestConnection *connection, id result, NSError *error)
                  {
                      
                      if(!error)
                      {
                          
                          UIAlertView * alertMessage=[[UIAlertView alloc]initWithTitle:@"Facebook" message:@"Posted Successfully" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                          [alertMessage show];
                      }
                      else
                      {
                          UIAlertView * alertMessage=[[UIAlertView alloc]initWithTitle:@"Sorry" message:[NSString stringWithFormat:@"error:%@",error.description] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                          [alertMessage show];
                      }
                  }]; // Requseting to post image
                 }
                 [connection start];
                 
                 
             }
             
         }
         [session close];
         
     }];
}

-(void)statusFeedBackForFaceBook:(NSString *)str
{
    UIAlertView * alert=[[UIAlertView alloc]initWithTitle:@"Facebook" message:str delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [alert show];
    
}

// method to send the post using the twitter
-(void)shareViaTwitter:(UIViewController *)vc  withTweet:(NSString *)string withLink:(NSURL *)url withKey:(NSString *)keyForFHST withTwitterSecret:(NSString *)secretForFHST completionBlock:(TwitterTweetCompletionBlock) completionBlock
{
    
    twitterKey=keyForFHST; // string which contains the FHSTwitterEngine Consumerkey
    twitterSecret=secretForFHST; // string which contains the FHSTwitterEngine secretKey
    accountStore = [[ACAccountStore alloc] init]; // accountStore object is initialised;
    urlFromString=[NSString stringWithFormat:@"%@",string];// getting the url data into the string.
    [[FHSTwitterEngine sharedEngine]permanentlySetConsumerKey:twitterKey andSecret:twitterSecret]; // To set the twitter key and twitter secret permenantely to fhst twitter engine;
    
    NSThread * twitterThread = [[NSThread alloc] initWithTarget:self selector:@selector(loadTwitterThread) object:nil];
    [twitterThread start];
    rootViewController=vc;
    completionBlockForTwitter=completionBlock;
    
}

-(void)loadTwitterThread
{
    @autoreleasepool
    {
        twitterAccountType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter]; // giving twitter identifier to the ACAccountstore.
        [accountStore requestAccessToAccountsWithType:twitterAccountType options:nil completion:^(BOOL granted, NSError *error)
         {
             // on completion getting all logged in user details in to the array.
             arrContainingTwitterAccounts = [accountStore accountsWithAccountType:twitterAccountType];
             if(urlFromString.length<=140)
             {
                 [self performSelectorOnMainThread:@selector(twitterPost:) withObject:rootViewController waitUntilDone:YES]; // calling the selector after getting the accounts in ACAccount store.
             }
             else
             {
                 completionBlockForTwitter(@"Tweet must be of 140 characters only",nil);
             }
             
             
         }];
    }
    
}


// To store access token
- (void)storeAccessToken:(NSString *)accessToken
{
    [[NSUserDefaults standardUserDefaults]setObject:accessToken forKey:@"SavedAccessHTTPBody"];
}
- (NSString *)loadAccessToken // To load access token
{
    
    return [[NSUserDefaults standardUserDefaults]objectForKey:@"SavedAccessHTTPBody"];
}


-(void)twitterPost:(UIViewController *)vc
{
    if ([arrContainingTwitterAccounts count]!=0) // if twitter accounts available in ACAccount store i.e(user logged in through settings)
    {
        
        userNamesInTwitter=[arrContainingTwitterAccounts valueForKey:@"username"]; // getting the usenames of all logged in users to array.
        UIActionSheet * actionSheet = [[UIActionSheet alloc] initWithTitle:@"ChooseAccount" delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles: nil]; //  an action sheet is initialised;
        userNamesInTwitter=[arrContainingTwitterAccounts valueForKey:@"username"];
        for(int userAccountCounter=0;userAccountCounter<[userNamesInTwitter count];userAccountCounter++) // adding the accounts present in account store to action sheet;
        {
            [actionSheet addButtonWithTitle:userNamesInTwitter[userAccountCounter]];
        }
        
        [actionSheet addButtonWithTitle:@"Cancel"];
        
        //  self.view.backgroundColor=[UIColor clearColor];
        [self.view setBackgroundColor:[UIColor colorWithRed:255.0 green:255.0 blue:255.0 alpha:0]];
        vc.modalPresentationStyle = UIModalPresentationCustom;
        
        [vc presentViewController:self animated:YES completion:^{
            [actionSheet showInView:self.view];
            
        }];
        
        
        //[self.tableView reloadData]; // loading the tableview
        //[vc presentViewController:self animated:YES completion:nil]; // presenting the tableview on mainview controller.
    }
    else // if twitter accounts unavailable in ACAccount store i.e(user is not logged in through settings)
        
    {
        NSLog(@"User is Loggedin Through Browser");
        NSLog(@"%@",urlFromString);
        // [[FHSTwitterEngine sharedEngine]permanentlySetConsumerKey:@"NSWwZMB5j46S7jXIC0G9" andSecret:@"8apwItKksdb1oi7fgsy8knB8oZJOMQzKLY8PCwjkMeg"]; // initializing the twitter engine providing the consumerkey and secret key
        imgDataFromYourVC=tempImgDataFromYourVC;
        
        [[FHSTwitterEngine sharedEngine]setDelegate:vc]; // setting delegate
        
        [[FHSTwitterEngine sharedEngine]showOAuthLoginControllerFromViewController:vc withCompletion:^(BOOL success)
         {
             [SocialController post];
             
         }];
        
    }
    
}

+(void)post
{
    @autoreleasepool
    {
        NSError *returnCode = [[FHSTwitterEngine sharedEngine]postTweet:urlFromString withImageData:imgDataFromYourVC];

        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        NSString *title = nil;
        NSString *message = nil;
        if (returnCode) // if there exixts an error code
        {
            title = [NSString stringWithFormat:@"Error %ld",(long)returnCode.code];
            message = returnCode.domain;
        }
        else
        {
            title = @"Twitter";
            message = @"Tweeted Successfully";
        }
        completionBlockForTwitter(message,returnCode);
    }
    
}


//// tableview delegate methods
//-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
//{
//    return [userNamesInTwitter count]; // returning userNamesInTwitter array count
//}
//
//-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    UITableViewCell * cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
//    cell.textLabel.text = [userNamesInTwitter objectAtIndex:indexPath.row];
//    return cell;
//}
//
//-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    
//    NSLog(@"%ld",(long)indexPath.row);
//    NSURL *url = [NSURL URLWithString:@"https://api.twitter.com/1/statuses/update.json"];
//    //NSDictionary *params = @{@"screen_name" :userNamesInTwitter[indexPath.row],@"include_rts" : @"0", @"trim_user" : @"1", @"count" : @"1"};
//    NSDictionary * params=@{@"status": urlFromString};
//    SLRequest *request = [SLRequest requestForServiceType:SLServiceTypeTwitter requestMethod:SLRequestMethodPOST  URL:url  parameters:params];
//    
//    //  Attach an account to the request
//    [request setAccount:arrContainingTwitterAccounts[indexPath.row]];
//    [request performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error)
//     {
//         
//         if (responseData)
//         {
//             if (urlResponse.statusCode >= 200 && urlResponse.statusCode < 300)
//             {
//                 
//                 NSError *jsonError;
//                 twitterUserData =[NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingAllowFragments error:&jsonError];
//                 if (twitterUserData) // if data obtainedfrom the Slrequest
//                 {
//                     NSLog(@"Userdata Response: %@\n", twitterUserData);
//                     completionBlockForTwitter(@"Tweeted successfully",error); // setting the values of response and error in completioblock
//                 }
//                 else
//                 {
//                     // Our JSON deserialization went awry
//                     NSLog(@"JSON Error: %@", [jsonError localizedDescription]);
//                     completionBlockForTwitter(@"Cannot tweet",error); // setting the values of response and error as not success and obtainede error.
//                 }
//                 
//                 
//                 
//             }
//             else
//             {
//                 // The server did not respond ... were we rate-limited?
//                 NSLog(@"The response status code is %ld",
//                       (long)urlResponse.statusCode);
//                 completionBlockForTwitter(@"Sorry cannot tweet",error);
//             }
//         }
//     }];// performing request to get the desired data;
//    [rootViewController dismissViewControllerAnimated:YES completion:nil];
//}
//- (BOOL)userHasAccessToTwitter // method to decide whether slcompose viewController available or not
//{
//    return [SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter];
//}

//// delegate method to increase the height of the header in section
//-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
//{
//    return 70.0;
//}
//// delegaet method to give the headerview
//-(UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
//{
//    
//    UIButton *cancelButton=[UIButton buttonWithType:UIButtonTypeSystem];
//    cancelButton.frame=CGRectMake(0, 0, 70, 70);
//    [cancelButton setTitle:@"Cancel" forState:UIControlStateNormal];
//    [cancelButton addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
//    
//    return  cancelButton; // returning cacel button to headerview.
//}
//
//// on click of cancel button in headerview in tableview
//-(void)dismiss
//{
//    [rootViewController dismissViewControllerAnimated:YES completion:nil]; // dismissing the rootview controller
//}

@end
