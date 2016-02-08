//
//  AP_API.m
//  Athan
//
//  Created by Alex Agarkov on 14.01.16.
//  Copyright © 2016 Alex Agarkov. All rights reserved.
//

#import "AP_API.h"
#import <UIKit/UIKit.h>
#import "ASIHTTPRequest.h"
#import <GoogleMobileAds/GoogleMobileAds.h>
#import "OWMWeatherAPI.h"
#import "SQLConnect.h"


@interface AP_API () <CLLocationManagerDelegate>
{
    NSUserDefaults* defaults;
}
@end

@implementation AP_API

static AP_API* _sharedController = nil;


+ (AP_API*)sharedController
{
    @synchronized(self)
    {
        if (!_sharedController)
        {
            _sharedController = [[AP_API alloc] init];
            [_sharedController initController];
        }
    }
    return _sharedController;
}
 - (void) initController
{
    NSLog(@"Google Mobile Ads SDK version: %@", [GADRequest sdkVersion]);
    defaults = [NSUserDefaults standardUserDefaults];
    
    if ([defaults objectForKey:@"tem"]) {
        switch ((APWTemperatureType)[[defaults objectForKey:@"tem"] integerValue]) {
            case APWTKelvin:
                _weatherTemperatureType = APWTKelvin;
                break;
            case APWTFahrenheit:
                _weatherTemperatureType = APWTFahrenheit;
                break;
            case APWTCelcius:
                _weatherTemperatureType = APWTCelcius;
                break;
            default:
                break;
        }
    }
    else
    {
        _weatherTemperatureType = APWTCelcius;
    }
    _locationManager = [[CLLocationManager alloc] init];
    _locationManager.delegate = self;
    // Check for iOS 8. Without this guard the code will crash with "unknown selector" on iOS 7.
    if ([_locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        [_locationManager requestWhenInUseAuthorization];
    }
    [_locationManager startUpdatingLocation];
}

#pragma mark - CLLocationManagerDelegate -
// Location Manager Delegate Methods
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    NSLog(@"%@", [locations lastObject]);
    if (!_prayerTimes) {
        [self initPrayerTimes];
    }
}

- (void)requestAlwaysAuthorization
{
    CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
    
    // If the status is denied or only granted for when in use, display an alert
    if (status == kCLAuthorizationStatusAuthorizedWhenInUse || status == kCLAuthorizationStatusDenied) {
        NSString *title;
        title = (status == kCLAuthorizationStatusDenied) ? @"Location services are off" : @"Background location is not enabled";
        NSString *message = @"To use background location you must turn on 'Always' in the Location Services Settings";
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title
                                                            message:message
                                                           delegate:self
                                                  cancelButtonTitle:NSLocalizedString(@"Cancel", @"Кнопка отмена")
                                                  otherButtonTitles:NSLocalizedString(@"Settings", @"Настройки"), nil];
        [alertView show];
    }
    // The user has not enabled any location services. Request background authorization.
    else if (status == kCLAuthorizationStatusNotDetermined) {
        [_locationManager requestAlwaysAuthorization];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        // Send the user to the Settings for this app
        NSURL *settingsURL = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
        [[UIApplication sharedApplication] openURL:settingsURL];
    }
}


//Основной блок запроса к серверу
-(void) getInfo:(NSURL*)url DoneBlock:(AP_APIBlock)doneBlock
{
    NSLog(@"getInfo: \n %@ \n",url);
    
    __weak __block ASIHTTPRequest* request = [ASIHTTPRequest requestWithURL:url];
    [request setTimeOutSeconds:20];
    [request setCompletionBlock:^{
        NSError* error = nil;
        NSDictionary* json = [NSJSONSerialization JSONObjectWithData:[request responseData] options:kNilOptions error:&error];
        if (!error) {
            NSLog(@"getInfo json: \n %@",json);
            doneBlock(json,error);
        }
        else
        {
            doneBlock(nil,error);
        }
    }];
    
    [request setFailedBlock:^{
        NSError *error = [request error];
        doneBlock(nil,error);
    }];
    
    [request startAsynchronous];
}

//Вывод алерта об ошибке
- (void) showErrorAlert:(NSError*)error
{
    NSString* messageString = @"";
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"errorTitleAlert", @"Заголовок ошибки алерта в API") message:messageString delegate:nil cancelButtonTitle:NSLocalizedString(@"ok", @"Кнопка ОК") otherButtonTitles: nil];
    
    [alert show];
}

- (void) getWeather:(AP_APIBlockAPWeather)block
{
//    [self getInfo:[NSURL URLWithString:[NSString stringWithFormat:@"http://api.openweathermap.org/data/2.5/weather?lat=%f&lon=%f&appid=%@&lang=ru",_locationManager.location.coordinate.latitude,_locationManager.location.coordinate.longitude,WEATHER_APP_ID]] DoneBlock:^(NSDictionary *dict, NSError *error) {
//        
//        NSLog(@"%@",dict);
//        
//    }];

    APWeather* myWeater = [APWeather weather];
    
    OWMWeatherAPI *_weatherAPI;
    _weatherAPI = [[OWMWeatherAPI alloc] init]; // Replace the key with your own

    
    
    [_weatherAPI currentWeatherByCoordinate:myAPI.locationManager.location.coordinate withCallback:^(NSError *error, NSDictionary *result) {
        
        NSString *idIcon=result[@"weather"][0][@"icon"];
        
        UIImage *imageIcon=[UIImage imageNamed:idIcon];
        
        imageIcon?myWeater.weatherImage=imageIcon:nil;
        
        
        switch (_weatherTemperatureType) {
            case APWTCelcius:
                myWeater.temperatureString = [NSString stringWithFormat:@"%.1d°C", (int)[result[@"main"][@"temp"] floatValue] ];
                break;
            case APWTFahrenheit:
                myWeater.temperatureString = [NSString stringWithFormat:@"%.1d°F", (int)[result[@"main"][@"temp"] floatValue] ];
                break;
                
            default:
                myWeater.temperatureString = [NSString stringWithFormat:@"%.1d K", (int)[result[@"main"][@"temp"] floatValue] ];
                break;
        }
        
        NSString *weatherLabels=result[@"weather"][0][@"description"];
        
        if (weatherLabels && [weatherLabels length]>0) {
            //Yes. It is
            myWeater.descriptionString = [weatherLabels stringByReplacingCharactersInRange:NSMakeRange(0,1)
                                                                           withString:[[weatherLabels substringToIndex:1] capitalizedString]];
        }
        
        
        block(myWeater);
    }];
    
}

- (void) initPrayerTimes
{
   // [self getPrayerTimes];
    _prayerTimes = [[BAPrayerTimes alloc] initWithDate:[NSDate date]
                                              latitude:_locationManager.location.coordinate.latitude
                                             longitude:_locationManager.location.coordinate.longitude
                                              timeZone:[NSTimeZone systemTimeZone]
                                                method:BAPrayerMethodMWL
                                                madhab:BAPrayerMadhabShafi];
    
    
    NSDateFormatter* df_utc = [[NSDateFormatter alloc] init];
    [df_utc setTimeZone:[NSTimeZone systemTimeZone]];
    //[df_utc setDateFormat:@"yyyy.MM.dd G 'at' HH:mm:ss zzz"];
    [df_utc setDateFormat:@"HH:mm"];
    
    NSDictionary* dict = @{@"fajrTime":[df_utc stringFromDate:_prayerTimes.fajrTime],
                           @"sunriseTime":[df_utc stringFromDate:_prayerTimes.sunriseTime],
                           @"dhuhrTime":[df_utc stringFromDate:_prayerTimes.dhuhrTime],
                           @"asrTime":[df_utc stringFromDate:_prayerTimes.asrTime],
                           @"maghribTime":[df_utc stringFromDate:_prayerTimes.maghribTime],
                           @"ishaTime":[df_utc stringFromDate:_prayerTimes.ishaTime]};
    if (_delegat) {
        if ([_delegat respondsToSelector:@selector(reloadPrayer:)]) {
            [_delegat reloadPrayer:dict];
        }
    }
    
    NSLog(@"fajrTime: %@",[df_utc stringFromDate:_prayerTimes.fajrTime]);
    NSLog(@"sunriseTime: %@",[df_utc stringFromDate:_prayerTimes.sunriseTime]);
    NSLog(@"dhuhrTime: %@",[df_utc stringFromDate:_prayerTimes.dhuhrTime]);
    NSLog(@"asrTime: %@",[df_utc stringFromDate:_prayerTimes.asrTime]);
    NSLog(@"maghribTime: %@",[df_utc stringFromDate:_prayerTimes.maghribTime]);
    NSLog(@"ishaTime: %@",[df_utc stringFromDate:_prayerTimes.ishaTime]);
    
}

- (void) getPrayerTimes
{
    NSArray* array = [[SQLConnect sharedInstance] getSavedTips];
    NSLog(@"%@", array);
}
@end
