//
//  APWeather.h
//  Athan
//
//  Created by Alex Agarkov on 21.01.16.
//  Copyright © 2016 Alex Agarkov. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface APWeather : NSObject

@property (strong, nonatomic) UIImage* weatherImage;
@property (strong, nonatomic) NSString* temperatureString;
@property (strong, nonatomic) NSString* descriptionString;

+ (APWeather*) weather;
@end
