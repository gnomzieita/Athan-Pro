//
//  OWMWeatherAPI.m
//  OpenWeatherMapAPI
//
//  Created by Adrian Bak on 20/6/13.
//  Copyright (c) 2013 Adrian Bak. All rights reserved.
//

#import "OWMWeatherAPI.h"
#import "ASIHTTPRequest.h"

@interface OWMWeatherAPI () {
    NSString *_baseURL;
    NSString *_apiKey;
    NSString *_apiVersion;
    NSOperationQueue *_weatherQueue;
    
    NSString *_lang;
}

@end

@implementation OWMWeatherAPI

- (instancetype) init{
    self = [super init];
    if (self) {
        _baseURL = @"http://api.openweathermap.org/data/";
        _apiKey  = WEATHER_APP_ID;
        _apiVersion = @"2.5";
        
        _weatherQueue = [[NSOperationQueue alloc] init];
        _weatherQueue.name = @"OMWWeatherQueue";
        
        [self setLangWithPreferedLanguage];
    }
    return self;
}

#pragma mark - private parts

+ (NSNumber *) tempToCelcius:(NSNumber *) tempKelvin
{
    return @(tempKelvin.floatValue - 273.15);
}

+ (NSNumber *) tempToFahrenheit:(NSNumber *) tempKelvin
{
    return @((tempKelvin.floatValue * 9/5) - 459.67);
}


- (NSNumber *) convertTemp:(NSNumber *) temp {
    switch (myAPI.weatherTemperatureType) {
        case APWTCelcius:
            return [OWMWeatherAPI tempToCelcius:temp];
            break;
        case APWTFahrenheit:
            return [OWMWeatherAPI tempToFahrenheit:temp];
            break;
            
        default:
            return temp;
            break;
    }
}

- (NSDate *) convertToDate:(NSNumber *) num {
    return [NSDate dateWithTimeIntervalSince1970:num.intValue];
}

/**
 * Recursivly change temperatures in result data
 **/
- (NSDictionary *) convertResult:(NSDictionary *) res {
    
    NSMutableDictionary *dic = [res mutableCopy];
    
    NSMutableDictionary *main = [[dic objectForKey:@"main"] mutableCopy];
    if (main) {
        main[@"temp"] = [self convertTemp:main[@"temp"]];
        main[@"temp_min"] = [self convertTemp:main[@"temp_min"]];
        main[@"temp_max"] = [self convertTemp:main[@"temp_max"]];
        
        dic[@"main"] = [main copy];
        
    }
    
    NSMutableDictionary *temp = [[dic objectForKey:@"temp"] mutableCopy];
    if (temp) {
        temp[@"day"] = [self convertTemp:temp[@"day"]];
        temp[@"eve"] = [self convertTemp:temp[@"eve"]];
        temp[@"max"] = [self convertTemp:temp[@"max"]];
        temp[@"min"] = [self convertTemp:temp[@"min"]];
        temp[@"morn"] = [self convertTemp:temp[@"morn"]];
        temp[@"night"] = [self convertTemp:temp[@"night"]];
        
        dic[@"temp"] = [temp copy];
    }
    
    
    NSMutableDictionary *sys = [[dic objectForKey:@"sys"] mutableCopy];
    if (sys) {
        
        sys[@"sunrise"] = [self convertToDate: sys[@"sunrise"]];
        sys[@"sunset"] = [self convertToDate: sys[@"sunset"]];
        
        dic[@"sys"] = [sys copy];
    }
    
    
    NSMutableArray *list = [[dic objectForKey:@"list"] mutableCopy];
    if (list) {
        
        for (int i = 0; i < list.count; i++) {
            [list replaceObjectAtIndex:i withObject:[self convertResult: list[i]]];
        }
        
        dic[@"list"] = [list copy];
    }
    
    dic[@"dt"] = [self convertToDate:dic[@"dt"]];
    
    return [dic copy];
}

/**
 * Calls the web api, and converts the result. Then it calls the callback on the caller-queue
 **/
- (void) callMethod:(NSString *) method withCallback:(OWMWeather_APIBlock)callback
{
    
    // build the lang paramter
    NSString *langString;
    if (_lang && _lang.length > 0) {
        langString = [NSString stringWithFormat:@"&lang=%@", _lang];
    } else {
        langString = @"";
    }
    
    NSString *urlString = [NSString stringWithFormat:@"%@%@%@&APPID=%@%@", _baseURL, _apiVersion, method, _apiKey, langString];
    
    NSURL *url = [NSURL URLWithString:urlString];
    //NSDictionary *res = [self convertResult:responseObject];
    [myAPI getInfo:url DoneBlock:^(NSDictionary *dict, NSError *error)
    {
        if (!error) {
            callback(nil,[self convertResult:dict]);
        }
        else
        {
            [myAPI showErrorAlert:error];
        }
        
    }];
    
    
    
//    NSURLRequest *request = [NSURLRequest requestWithURL:url];
//    
//    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
//    
//    operation.responseSerializer = [AFJSONResponseSerializer serializer];
//    
//    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
//        // callback on the caller queue
//        NSDictionary *res = [self convertResult:responseObject];
//        [callerQueue addOperationWithBlock:^{
//            callback(nil, res);
//        }];
//    } failure:^(AFHTTPRequestOperation *operation, NSError *error){
//        // callback on the caller queue
//        [callerQueue addOperationWithBlock:^{
//            callback(error, nil);
//        }];
//    }];
//    
//    [_weatherQueue addOperation:operation];
}

- (void) callMethodReturnRawData:(NSString *) method withCallback:(OWMWeather_APIBlock)callback
{
//    
//    NSOperationQueue *callerQueue = [NSOperationQueue currentQueue];
//    
    // build the lang paramter
    NSString *langString;
    if (_lang && _lang.length > 0) {
        langString = [NSString stringWithFormat:@"&lang=%@", _lang];
    } else {
        langString = @"";
    }
    
    NSString *urlString = [NSString stringWithFormat:@"%@%@%@&APPID=%@%@", _baseURL, _apiVersion, method, _apiKey, langString];
    
    NSURL *url = [NSURL URLWithString:[urlString stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding]];
    
    [myAPI getInfo:url DoneBlock:^(NSDictionary *dict, NSError *error)
     {
         if (!error) {
             callback(nil,[self convertResult:dict]);
         }
         else
         {
             [myAPI showErrorAlert:error];
         }
         
     }];
//    NSURLRequest *request = [NSURLRequest requestWithURL:url];
//    
//    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc]
//                                         initWithRequest:request];
//    operation.responseSerializer = [AFJSONResponseSerializer serializer];
//    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
//        // callback on the caller queue
//        NSDictionary *res = [self convertResult:responseObject];
//        [callerQueue addOperationWithBlock:^{
//            callback(nil, res);
//        }];
//    } failure:^(AFHTTPRequestOperation *operation, NSError *error){
//        // callback on the caller queue
//        [callerQueue addOperationWithBlock:^{
//            callback(error, nil);
//        }];
//    }];
//    
//    [_weatherQueue addOperation:operation];
}

//- (void) callMethodWithExplicitUrl:(NSString *) urlString withCallback:( void (^)( NSError* error, NSDictionary *result ) )callback
//{
//
//    NSOperationQueue *callerQueue = [NSOperationQueue currentQueue];
//
//    NSURL *url = [NSURL URLWithString:urlString];
//
//    NSURLRequest *request = [NSURLRequest requestWithURL:url];
//
//    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
//
//        // callback on the caller queue
////        NSDictionary *res = [self convertResult:JSON];
//        [callerQueue addOperationWithBlock:^{
//            callback(nil, JSON);
//        }];
//
//
//    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
//
//        // callback on the caller queue
//        [callerQueue addOperationWithBlock:^{
//            callback(error, nil);
//        }];
//
//    }];
//    [_weatherQueue addOperation:operation];
//}

#pragma mark - public api

- (void) setApiVersion:(NSString *) version {
    _apiVersion = version;
}

- (NSString *) apiVersion {
    return _apiVersion;
}

- (void) setLangWithPreferedLanguage {

    NSString *lang=[[NSLocale preferredLanguages] objectAtIndex:0];
    if(lang.length>=2)
        lang=[lang substringToIndex:2];
    
    // look up, lang and convert it to the format that openweathermap.org accepts.
    NSDictionary *langCodes = @{
                                @"sv" : @"se",
                                @"es" : @"sp",
                                @"en-GB": @"en",
                                @"uk" : @"ua",
                                @"pt-PT" : @"pt",
                                @"zh-Hans" : @"zh_cn",
                                @"zh-Hant" : @"zh_tw",
                                };
    
    NSString *l = [langCodes objectForKey:lang];
    if (l) {
        lang = l;
    }
    
    
    _lang = lang;
}

#pragma mark current weather

-(void) currentWeatherByCityName:(NSString *) name
                    withCallback:(OWMWeather_APIBlock)callback
{
    
    NSString *method = [NSString stringWithFormat:@"/weather?q=%@", name];
    [self callMethod:method withCallback:callback];
    
}

-(void) currentWeatherByCoordinate:(CLLocationCoordinate2D) coordinate
                      withCallback:(OWMWeather_APIBlock)callback
{
    
    NSString *method = [NSString stringWithFormat:@"/weather?lat=%f&lon=%f",
                        coordinate.latitude, coordinate.longitude ];
    [self callMethod:method withCallback:callback];
    
}

-(void) currentWeatherByCityId:(NSString *) cityId
                  withCallback:(OWMWeather_APIBlock)callback
{
    NSString *method = [NSString stringWithFormat:@"/weather?id=%@", cityId];
    [self callMethod:method withCallback:callback];
}


#pragma mark forcast

-(void) forecastWeatherByCityName:(NSString *) name
                     withCallback:(OWMWeather_APIBlock)callback
{
    
    NSString *method = [NSString stringWithFormat:@"/forecast?q=%@", name];
    [self callMethod:method withCallback:callback];
    
}

-(void) forecastWeatherByCoordinate:(CLLocationCoordinate2D) coordinate
                       withCallback:(OWMWeather_APIBlock)callback
{
    
    NSString *method = [NSString stringWithFormat:@"/forecast?lat=%f&lon=%f",
                        coordinate.latitude, coordinate.longitude ];
    [self callMethod:method withCallback:callback];
    
}

-(void) forecastWeatherByCityId:(NSString *) cityId
                   withCallback:(OWMWeather_APIBlock)callback
{
    NSString *method = [NSString stringWithFormat:@"/forecast?id=%@", cityId];
    [self callMethod:method withCallback:callback];
}

#pragma mark forcast - n days

-(void) dailyForecastWeatherByCityName:(NSString *) name
                             withCount:(int) count
                           andCallback:(OWMWeather_APIBlock)callback
{
    
    NSString *method = [NSString stringWithFormat:@"/forecast/daily?q=%@&cnt=%d", name, count];
    [self callMethod:method withCallback:callback];
    
}

-(void) dailyForecastWeatherByCoordinate:(CLLocationCoordinate2D) coordinate
                               withCount:(int) count
                             andCallback:(OWMWeather_APIBlock)callback
{
    
    NSString *method = [NSString stringWithFormat:@"/forecast/daily?lat=%f&lon=%f&cnt=%d",
                        coordinate.latitude, coordinate.longitude, count ];
    [self callMethod:method withCallback:callback];
    
}

-(void) dailyForecastWeatherByCityId:(NSString *) cityId
                           withCount:(int) count
                         andCallback:(OWMWeather_APIBlock)callback
{
    NSString *method = [NSString stringWithFormat:@"/forecast?id=%@&cnt=%d", cityId, count];
    [self callMethod:method withCallback:callback];
}



#pragma mark custom - get cities

-(void) getCities:(NSString *)searchTerm andCallback:(OWMWeather_APIBlock)callback{
    NSString *method = [NSString stringWithFormat:@"/find?q=%@&type=like&mode=json", searchTerm];
    [self callMethodReturnRawData:method withCallback:callback];
}


//-(void) getCities:(NSString *)searchTerm andCallback:(void (^)(NSError *, NSDictionary *))callback{
//    NSString *method = [NSString stringWithFormat:@"http://gd.geobytes.com/AutoCompleteCity?q=%@", searchTerm];
//    [self callMethodWithExplicitUrl:method withCallback:callback];
//}


@end