//
//  ViewController.m
//  Athan
//
//  Created by Alex Agarkov on 14.01.16.
//  Copyright © 2016 Alex Agarkov. All rights reserved.
//

#import "ViewController.h"
#import "BTGlassScrollView.h"

@interface ViewController ()<BTGlassScrollViewDelegate, UITableViewDataSource, UITableViewDelegate, AP_API_Protocolo>
{
    NSInteger otst;
    NSInteger radius;
    float h1;
    float h2;
    NSDictionary* prayerDict;
    
}
@property (weak, nonatomic) IBOutlet UIView *bgView;

@property (strong, nonatomic) BTGlassScrollView* scrollView;
@property (strong, nonatomic) UITableView* table;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    prayerDict = [NSDictionary dictionary];
    [myAPI setDelegat:self];
    
    UIView *view = [self customView];
    
    _scrollView = [[BTGlassScrollView alloc] initWithFrame:_bgView.frame BackgroundImage:[UIImage imageNamed:@"fon"] blurredImage:nil viewDistanceFromBottom:otst*2.5f+h1*2 foregroundView:view];
    
    [_bgView addSubview:_scrollView];
    
    // Do any additional setup after loading the view, typically from a nib.
    
}

- (UIView *)customView
{
    otst = 5;
    radius = 5;
    UIColor* bgColor = [UIColor colorWithWhite:0 alpha:.33];
    
    CGRect sView = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height*0.9f);
    
    h1 = (sView.size.height-otst*6)/9;
    h2 = h1*5;
    
    UIView *view = [[UIView alloc] initWithFrame:sView];
    
//    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(5, 5, 310, 120)];
//    [label setText:[NSString stringWithFormat:@"%i℉",arc4random_uniform(20) + 60]];
//    [label setTextColor:[UIColor whiteColor]];
//    [label setFont:[UIFont fontWithName:@"HelveticaNeue-UltraLight" size:120]];
//    [label setShadowColor:[UIColor blackColor]];
//    [label setShadowOffset:CGSizeMake(1, 1)];
//    [view addSubview:label];
    
//-------------------------------------------------------------------------------------------------------
    //CGRectMake(CGFloat x, CGFloat y, CGFloat width, CGFloat height)
    UIView *box1 = [[UIView alloc] initWithFrame:CGRectMake(otst, otst, sView.size.width-otst*2, h1)];
    box1.layer.cornerRadius = radius;
    box1.backgroundColor = bgColor;
    
    [view addSubview:box1];
//-------------------------------------------------------------------------------------------------------
    UIView *box2 = [[UIView alloc] initWithFrame:CGRectMake(otst, otst*2+h1, sView.size.width-otst*2, h1)];
    box2.layer.cornerRadius = radius;
    box2.backgroundColor = bgColor;

    [view addSubview:box2];
//-------------------------------------------------------------------------------------------------------
    UIView *box3 = [[UIView alloc] initWithFrame:CGRectMake(otst, otst*3+h1*2, sView.size.width-otst*2, h2)];
    box3.layer.cornerRadius = radius;
    box3.backgroundColor = bgColor;
    
    _table = [[UITableView alloc] initWithFrame:CGRectMake(5, 5, sView.size.width-otst*2, h2) style:UITableViewStyleGrouped];
    [_table setBackgroundColor:[UIColor clearColor]];
    _table.delegate = self;
    _table.dataSource = self;
    [_table setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [box3 addSubview:_table];
    
    [view addSubview:box3];
//-------------------------------------------------------------------------------------------------------
    UIView *box4 = [[UIView alloc] initWithFrame:CGRectMake(otst, otst*4+h1*2+h2, sView.size.width-otst*2, h1)];
    box4.layer.cornerRadius = radius;
    box4.backgroundColor = bgColor;
    
    [view addSubview:box4];
//-------------------------------------------------------------------------------------------------------
    UIView *box5 = [[UIView alloc] initWithFrame:CGRectMake(otst, otst*5+h1*3+h2, sView.size.width-otst*2, h1)];
    box5.layer.cornerRadius = radius;
    box5.backgroundColor = bgColor;
    
    [myAPI getWeather:^(APWeather *weath) {
        UILabel* label = [[UILabel alloc] initWithFrame:CGRectMake(5, 5, box2.frame.size.width-10, box2.frame.size.height)];
        [label setText:weath.temperatureString];
        [label setTextColor:[UIColor whiteColor]];
        [box5 addSubview:label];
        
    }];
    
    [view addSubview:box5];
//-------------------------------------------------------------------------------------------------------
    return view;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
    
}

#pragma mark - BTGlassScrollViewDelegate - 

- (void)glassScrollView:(BTGlassScrollView *)glassScrollView didChangedToFrame:(CGRect)frame
{
    
}
//make custom blur without messing with default settings
- (UIImage*)glassScrollView:(BTGlassScrollView *)glassScrollView blurForImage:(UIImage *)image
{
    return nil;
}

#pragma mark - UITableViewDataSource -

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[prayerDict allKeys] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell* cell = [[UITableViewCell alloc] init];
   
    [cell setBackgroundColor:[UIColor clearColor]];
    
    UILabel* prayerName = [[UILabel alloc] initWithFrame:CGRectMake(otst, otst, (self.view.frame.size.width-otst*4)/2 , ((h2-otst*2)/7)-otst*2)];
    [prayerName setTextColor:[UIColor whiteColor]];
    [prayerName setFont:[UIFont systemFontOfSize:prayerName.frame.size.height*0.6f]];
    [cell addSubview:prayerName];
    
    UILabel* prayerTime = [[UILabel alloc] initWithFrame:CGRectMake((self.view.frame.size.width-otst*4)/2+otst, otst, (self.view.frame.size.width-otst*4)*0.2f , (((h2-otst*2)/7)-otst*2))];
    [prayerTime setTextColor:[UIColor whiteColor]];
    [prayerTime setFont:[UIFont systemFontOfSize:prayerName.frame.size.height*0.6f]];
    [cell addSubview:prayerTime];
    
    NSDateFormatter* df_utc = [[NSDateFormatter alloc] init];
    [df_utc setTimeZone:[NSTimeZone systemTimeZone]];
    //[df_utc setDateFormat:@"yyyy.MM.dd G 'at' HH:mm:ss zzz"];
    [df_utc setDateFormat:@"HH:mm"];

    switch (indexPath.row) {
        case 0:
            [prayerName setText:@"fajrTime"];
            [prayerTime setText:[prayerDict objectForKey:@"fajrTime"]];
            break;
        case 1:
            [prayerName setText:@"sunriseTime"];
            [prayerTime setText:[prayerDict objectForKey:@"sunriseTime"]];
            break;
        case 2:
            [prayerName setText:@"dhuhrTime"];
            [prayerTime setText:[prayerDict objectForKey:@"dhuhrTime"]];
            break;
        case 3:
            [prayerName setText:@"asrTime"];
            [prayerTime setText:[prayerDict objectForKey:@"asrTime"]];
            break;
        case 4:
            [prayerName setText:@"maghribTime"];
            [prayerTime setText:[prayerDict objectForKey:@"maghribTime"]];
            break;
        case 5:
            [prayerName setText:@"ishaTime"];
            [prayerTime setText:[prayerDict objectForKey:@"ishaTime"]];
            break;
            
        default:
            break;
    }
    
    return cell;
    
}

#pragma mark - UITableViewDelegate -

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return (h2-otst*2)/7;
}

#pragma mark - AP_API_Protocolo -

- (void) reloadPrayer:(NSDictionary*)dict
{
    prayerDict = [NSDictionary dictionaryWithDictionary:dict];
    [_table reloadData];
}
@end
