//
//  AP_API.h
//  Athan
//
//  Created by Alex Agarkov on 14.01.16.
//  Copyright © 2016 Alex Agarkov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <BAPrayerTimes/BAPrayerTimes.h>
#import "APWeather.h"

@import CoreLocation;

typedef NS_ENUM(NSInteger, APWTemperatureType) {
    APWTKelvin = 0,
    APWTCelcius,
    APWTFahrenheit
};

typedef void (^AP_APIBlock)(NSDictionary* dict, NSError* error);
typedef void (^AP_APIBlockArray)(NSArray* array, NSError* error);
typedef void (^AP_APIBlockDictionary)(NSDictionary* dict, NSError* error);
typedef void (^AP_APIBlockAPWeather)(APWeather* weath);

@protocol AP_API_Protocolo <NSObject>

@required

- (void) reloadPrayer:(NSDictionary*)dict;

@end

@interface AP_API : NSObject

+ (AP_API*)sharedController;

@property (strong, nonatomic) id<AP_API_Protocolo> delegat;

@property (strong, nonatomic) CLLocationManager* locationManager;
@property (strong, nonatomic) BAPrayerTimes* prayerTimes;
@property (strong, nonatomic) UIImage* fonImage;
@property (assign, nonatomic) APWTemperatureType weatherTemperatureType;

- (void) getInfo:(NSURL*)url DoneBlock:(AP_APIBlock)doneBlock;

- (void) showErrorAlert:(NSError*)error;
- (void) getWeather:(AP_APIBlockAPWeather)block;
- (void) getPrayer;

@end
