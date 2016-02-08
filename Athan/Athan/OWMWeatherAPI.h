//
//  OWMWeatherAPI.h
//  OpenWeatherMapAPI
//
//  Created by Adrian Bak on 20/6/13.
//  Copyright (c) 2013 Adrian Bak. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

typedef void (^OWMWeather_APIBlock)( NSError* error, NSDictionary *result );

@interface OWMWeatherAPI : NSObject

- (void) setApiVersion:(NSString *) version;
- (NSString *) apiVersion;

#pragma mark - current weather

-(void) currentWeatherByCityName:(NSString *) name
                    withCallback:(OWMWeather_APIBlock)callback;


-(void) currentWeatherByCoordinate:(CLLocationCoordinate2D) coordinate
                      withCallback:(OWMWeather_APIBlock)callback;

-(void) currentWeatherByCityId:(NSString *) cityId
                  withCallback:(OWMWeather_APIBlock)callback;

#pragma mark - forecast

-(void) forecastWeatherByCityName:(NSString *) name
                     withCallback:(OWMWeather_APIBlock)callback;

-(void) forecastWeatherByCoordinate:(CLLocationCoordinate2D) coordinate
                       withCallback:(OWMWeather_APIBlock)callback;

-(void) forecastWeatherByCityId:(NSString *) cityId
                   withCallback:(OWMWeather_APIBlock)callback;

#pragma mark forcast - n days

-(void) dailyForecastWeatherByCityName:(NSString *) name
                             withCount:(int) count
                           andCallback:(OWMWeather_APIBlock)callback;

-(void) dailyForecastWeatherByCoordinate:(CLLocationCoordinate2D) coordinate
                               withCount:(int) count
                             andCallback:(OWMWeather_APIBlock)callback;

-(void) dailyForecastWeatherByCityId:(NSString *) cityId
                           withCount:(int) count
                         andCallback:(OWMWeather_APIBlock)callback;

#pragma mark custom - get cities

-(void) getCities:(NSString*) searchTerm andCallback:(OWMWeather_APIBlock)callback;

@end