//
//  BBLocationManager.m
//  BroBox
//
//  Created by Tanguy Hélesbeux on 04/02/2015.
//  Copyright (c) 2015 Brobox. All rights reserved.
//

#import "BBLocationManager.h"

// Managers
#import "BBParseManager.h"

static BBLocationManager *sharedManager;

@interface BBLocationManager () <CLLocationManagerDelegate>

@property (strong, nonatomic) CLLocationManager *locationManager;

@end

@implementation BBLocationManager

#pragma mark - Singleton

+ (BBLocationManager *)sharedManager {
    if (!sharedManager) {
        sharedManager = [BBLocationManager new];
        [sharedManager initializeManager];
    }
    return sharedManager;
}

#pragma mark - Services

+ (void)startUpdatingLocation {
    [[BBLocationManager sharedManager] initializeManager];
}

+ (CLLocation *)userLocation {
    return [[BBLocationManager sharedManager].locationManager location];
}

#pragma mark - Initialization


- (void)initializeManager {
    switch ([CLLocationManager authorizationStatus]) {
            
        case kCLAuthorizationStatusDenied:
        case kCLAuthorizationStatusRestricted: {
            [[NSNotificationCenter defaultCenter] postNotificationName:BBNotificationLocationAuthorizationDenied
                                                                object:nil];
        }
            
        case kCLAuthorizationStatusNotDetermined: {
            [sharedManager.locationManager requestWhenInUseAuthorization];
            break;
        }
            
        case kCLAuthorizationStatusAuthorizedWhenInUse:
        case kCLAuthorizationStatusAuthorizedAlways: {
            [sharedManager.locationManager startMonitoringSignificantLocationChanges];
            break;
        }
    }
}

#pragma mark - Getters @ Setters

- (CLLocationManager *)locationManager {
    if (!_locationManager) {
        _locationManager = [CLLocationManager new];
        _locationManager.delegate = self;
    }
    return _locationManager;
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    [self initializeManager];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    BBParseUser *user = [BBParseUser currentUser];
    user.location =[PFGeoPoint geoPointWithLocation:manager.location];
    [user saveEventually];
}

@end
