//
//  APWeather.m
//  Athan
//
//  Created by Alex Agarkov on 21.01.16.
//  Copyright © 2016 Alex Agarkov. All rights reserved.
//

#import "APWeather.h"

@implementation APWeather

+ (APWeather*) weather
{
    APWeather* weather = [[APWeather alloc] init];
    weather.weatherImage = nil;
    weather.descriptionString = @"";
    weather.temperatureString = @"";
    return weather;
}

@end
