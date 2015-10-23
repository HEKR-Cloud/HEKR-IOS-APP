//
//  Tools.m
//  HekrSDK
//
//  Created by WangMike on 15/8/5.
//  Copyright (c) 2015年 Hekr. All rights reserved.
//

#import "Location.h"

@interface Location()<CLLocationManagerDelegate>
@property (nonatomic,strong) NSMutableArray * blocks;
@property (nonatomic,strong) CLLocationManager * manage;
@end

@implementation Location
-(instancetype) init{
    self = [super init];
    if (self) {
        self.blocks = [NSMutableArray array];
        self.manage = [[CLLocationManager alloc] init];
        self.manage.distanceFilter = kCLDistanceFilterNone;
        self.manage.delegate = self;
    }
    return self;
}
-(void) getLocation:(void (^)(BOOL,CLLocationCoordinate2D))block{
    if (![CLLocationManager locationServicesEnabled] || [CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied) {
        return !block?:block(NO,kCLLocationCoordinate2DInvalid);
    }
    [self.blocks addObject:block];
    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined) {
        [self.manage requestWhenInUseAuthorization];
    }else{
        [self.manage startUpdatingLocation];
    }
}

-(BOOL) acceptAccuracyOfLocation:(CLLocation*) location{
    return YES;
}
-(void) invokeAll:(CLLocation*) location{
    NSArray * arr = [NSArray arrayWithArray:self.blocks];
    [self.blocks removeAllObjects];
    
    for (void(^block)(BOOL,CLLocationCoordinate2D) in arr) {
        block(!!location,location?location.coordinate:kCLLocationCoordinate2DInvalid);
    }
}
- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status{
    if (status == kCLAuthorizationStatusDenied) {
        [self invokeAll:nil];
        [manager stopUpdatingLocation];
    }else{
        [manager startUpdatingLocation];
    }
}
-(void) locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations{
    CLLocation * location = manager.location;
    if (location && [self acceptAccuracyOfLocation:location]) {
        [self invokeAll:location];
        [manager stopUpdatingLocation];
    }
}
-(void) locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error{
    [self invokeAll:nil];
    [manager stopUpdatingLocation];
}
@end