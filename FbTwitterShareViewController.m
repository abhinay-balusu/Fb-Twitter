
#import "FbTwitterShareViewController.h"

@interface FbTwitterShareViewController ()
{
    SocialController *sc;
}

@end

@implementation FbTwitterShareViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    sc=[[SocialController alloc]init];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)facebookPostImage:(id)sender
{
    if(![self isNetworkAvailable])
    {
        return;
    }
    UIImage *yourImage=[UIImage imageNamed:@"cabDetails.jpg"];
    NSData *capturedImageData=UIImageJPEGRepresentation(yourImage, 1.0f);
    sc.tempImgDataFromYourVC=capturedImageData;
    
    [sc UserSelectedFacebook:self withStatus:[NSString stringWithFormat:@"Picture from Your App on %@",[self currentDateString]] withAppId:@"Your App ID" withLink:nil completionBlock:^(NSString *responseData, NSError *error) {
        
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Facebook" message:responseData delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        
        sc.tempImgDataFromYourVC=nil;
        
    }];
}


- (IBAction)twitterTweetImage:(id)sender
{
    if(![self isNetworkAvailable])
    {
        return;
    }
//if image is available in the form of data
    UIImage *yourImage=[UIImage imageNamed:@"cabDetails.jpg"];
    NSData *capturedImageData=UIImageJPEGRepresentation(yourImage, 1.0f);
    sc.tempImgDataFromYourVC=capturedImageData;
    
    
    [sc shareViaTwitter:self withTweet:[NSString stringWithFormat:@"Picture from Your App on %@",[self currentDateString]] withLink:nil withKey:@"Your App Key" withTwitterSecret:@"Your Twitter Secret"  completionBlock:^(NSString *responseData, NSError *error)
        {
         UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Twitter" message:responseData delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
         [alert show];
         
         sc.tempImgDataFromYourVC=nil;
     }];
}

-(NSString *)currentDateString
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
    
    NSString * calenderString=[NSString stringWithFormat:@"%d:%d:%d %@ %d-%d-%d",hour,minute,second,ampm,day,month,year];
    
    return calenderString;
}

-(BOOL)isNetworkAvailable
{
    char *hostname;
    struct hostent *hostinfo;
    hostname = "google.com";
    hostinfo = gethostbyname (hostname);
    if (hostinfo == NULL)
    {
        NSLog(@"-> no connection!\n");
        
        UIAlertView * alert=[[UIAlertView alloc]initWithTitle:@"Network Status" message:@"Please make sure Connection is available" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alert show];
        
        self.navigationController.view.userInteractionEnabled=YES;
        return NO;
    }
    else
    {
        NSLog(@"-> connection established!\n");
        return YES;
    }
}

@end
