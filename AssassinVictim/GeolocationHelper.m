//
//  GeolocationHelper.m
//  AssassinVictim
//
//  Created by Mihriban Minaz on 14/11/15.
//  Copyright © 2015 Mihriban Minaz. All rights reserved.
//

#import "GeolocationHelper.h"

NSString *kTryToRecoverLocationServices = @"locationServicesRecoveryTrialTag";
NSInteger const GeolocationHelperErrorLocationServicesDisabled = 101;
NSString *kNearbyAvailableStatusChanged = @"NearbyAvailableStatusChangedNotification";

@interface Subscriber : NSObject

@property (nonatomic, weak) id subscriberReference;
@property (nonatomic, copy) GeolocationHelperLocationCompletion changeLocationBlock;
@property (nonatomic, copy) GeolocationHelperPlacemarkCompletion changePlacemarkBlock;
@property (nonatomic, copy) GeolocationHelperAuthorizationStatusChange authorizationStatusChangeBlock;

@end

@implementation Subscriber

- (id)initWithLocationChange: (GeolocationHelperLocationCompletion) changeLocationBlock
             placemarkChange: (GeolocationHelperPlacemarkCompletion)changePlacemarkBlock
   authorizationStatusChange:(GeolocationHelperAuthorizationStatusChange)authorizationStatusChangeBlock
                   forObject: (id) subscriber
{
    self = [super init];
    if (self)
    {
        self.changeLocationBlock = changeLocationBlock;
        self.changePlacemarkBlock = changePlacemarkBlock;
        self.authorizationStatusChangeBlock = authorizationStatusChangeBlock;
        self.subscriberReference = subscriber;
    }
    return self;
}

- (BOOL)isEqual:(id)object
{
    return [[(Subscriber *)object subscriberReference] isEqual:self.subscriberReference];
}

@end


@interface GeolocationHelper () <CLLocationManagerDelegate>

@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) NSMutableArray *subscribers;
@property (nonatomic, assign) BOOL running;

@end

@implementation GeolocationHelper

- (void)setLastClosestDestination:(Destination *)lastClosestDestination
{
    _lastClosestDestination = lastClosestDestination;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kNearbyAvailableStatusChanged object:self];
}

+ (instancetype) shared
{
    static GeolocationHelper *manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [GeolocationHelper new];
#ifdef CREATING_SCREENSHOTS
        manager.locationManager = nil;
#else
        manager.locationManager = [CLLocationManager new];
#endif
        manager.locationManager.desiredAccuracy = kCLLocationAccuracyKilometer;
        manager.locationManager.distanceFilter = 500;
        manager.locationManager.delegate = manager;
        manager.subscribers = [NSMutableArray array];
        manager.running = NO;
    });
    
    return manager;
}

- (void) resetPosition
{
    self.lastKnownPlacemark = nil;
    self.lastKnownPosition = nil;
}

- (BOOL) locationServicesAreEnabled
{
#ifdef CREATING_SCREENSHOTS
    return YES;
#endif
    
    CLAuthorizationStatus status = [self authorizationStatus];
    return status == kCLAuthorizationStatusAuthorizedWhenInUse || status == kCLAuthorizationStatusAuthorizedAlways;
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    switch (status)
    {
        case kCLAuthorizationStatusNotDetermined:
        case kCLAuthorizationStatusAuthorizedAlways:
        case kCLAuthorizationStatusAuthorizedWhenInUse:
            [self resumeServices];
            break;
        default:
            [self stopServices];
            break;
    }
    
    [self notifySubscribersNewAuthorizationStatus:status];
}

- (CLAuthorizationStatus)authorizationStatus
{
    CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
    return status;
}

- (void) locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    if (self.running)
    {
        if ([error domain] == kCLErrorDomain)
        {
            switch ([error code])
            {
                case kCLErrorLocationUnknown:
                    //Nothing to do here
                    break;
                case kCLErrorDenied:
                    [self notifySubscribersNewLocation:nil withError:error];
                    [self stopServices];
                    break;
                default:
                    [self notifySubscribersNewLocation:nil withError:error];
                    break;
            }
        }
    }
   
}

- (void) locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    CLLocation *newLocation = [locations lastObject];
    NSDate *eventDate = newLocation.timestamp;
    NSTimeInterval howRecent = [eventDate timeIntervalSinceNow];
    
    if (fabs(howRecent) < 500.0 && (!self.lastKnownPosition || !self.lastKnownPlacemark || [self.lastKnownPosition distanceFromLocation:newLocation] >= 150))
    {
        self.lastKnownPosition = newLocation;
        
        [self notifySubscribersNewLocation:newLocation withError:nil];
        CLGeocoder *geoCoder = [CLGeocoder new];
        __weak typeof(self) weakSelf = self;
        [geoCoder reverseGeocodeLocation:self.lastKnownPosition completionHandler:^(NSArray *placemarks, NSError *error) {
            weakSelf.lastKnownPlacemark = [placemarks firstObject];
            [weakSelf notifySubscribersNewPlacemark:weakSelf.lastKnownPlacemark withError:error];
        }];
    } else
    {
        [self notifySubscribersNewLocation:self.lastKnownPosition withError:nil];
        [self notifySubscribersNewPlacemark:self.lastKnownPlacemark withError:nil];
    }
}

- (void) isItOcean:(CLLocation *)location withSuccessBlock:(void (^)())successBlock withFailureBlock:(void(^)())failureBlock
{
    CLGeocoder *geoCoder = [CLGeocoder new];
    [geoCoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
        CLPlacemark *aPlaceMark = [placemarks firstObject];
        if ([aPlaceMark.ocean length] >0) {
            successBlock();
        }
        else {
            failureBlock();
        }
    }];
}

#pragma mark - Public methods

- (void) startListeningWithLocationChange:(GeolocationHelperLocationCompletion)cBlock
                          placemarkChange:(GeolocationHelperPlacemarkCompletion)pBlock
                authorizationStatusChange:(GeolocationHelperAuthorizationStatusChange)aBlock
                            withReference:(id)reference
{
    Subscriber *newSubscriber = [[Subscriber alloc] initWithLocationChange:cBlock
                                                           placemarkChange:pBlock
                                                 authorizationStatusChange:aBlock
                                                                 forObject:reference];
    [self subscribeToLocationNews:newSubscriber];
}

- (void) stopListeningForReference: (id) reference
{
    if ([self.subscribers indexOfObject:reference] != NSNotFound) {
        Subscriber * subcriber = self.subscribers[[self.subscribers indexOfObject:reference]];
        [self unsubscribeToLocationNews:subcriber];
    }
}

- (void) stopServices
{
    self.running = NO;
    [self.locationManager stopUpdatingLocation];
}

- (void)askForLocationServices
{
    if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)])
    {
        [self.locationManager requestWhenInUseAuthorization];
    }
    
    [self.locationManager startUpdatingLocation];
}

- (void) resumeServices
{
    if (self.running)
    {
        return;
    }
    
    if (![self locationServicesAreEnabled])
    {
        [self notifySubscribersNewLocation:nil withError:[NSError errorWithDomain:@"CLErrorDomain"
                                                                             code:GeolocationHelperErrorLocationServicesDisabled
                                                                         userInfo:nil]];
        self.running = YES;
        return;
    } else if ([self.subscribers count] > 0)
    {
        [self askForLocationServices];
        self.running = YES;
    }
    
}

- (NSInteger)distanceInMetersFrom:(CLLocationCoordinate2D)coordinates
{
    CLLocation *targetLocation = [[CLLocation alloc] initWithLatitude:coordinates.latitude longitude:coordinates.longitude];
    CLLocationDistance distance = [self.lastKnownPosition distanceFromLocation:targetLocation];
    
    return distance;
}

- (BOOL) isCheckinAvailableforPosition: (CLLocationCoordinate2D)coordinates
{
    if (!self.lastKnownPosition)
    {
        return NO;
    }
    
    return [self distanceInMetersFrom:coordinates] < 5000;
}

- (BOOL) isNearByPosition:(CLLocationCoordinate2D)coordinates
{
    if (!self.lastKnownPosition)
    {
        return NO;
    }
    
    return [self distanceInMetersFrom:coordinates] < 20000;
}

#pragma mark - Subscriber methods

- (void) subscribeToLocationNews: (Subscriber *) subscriber
{
    [self.subscribers addObject:subscriber];
    
    [self resumeServices];
    
    if (self.lastKnownPlacemark)
    {
        if (subscriber.changePlacemarkBlock)
        {
            subscriber.changePlacemarkBlock(self.lastKnownPlacemark, nil);
        }
    }
    
    if (self.lastKnownPosition)
    {
        if (subscriber.changeLocationBlock)
        {
            subscriber.changeLocationBlock(self.lastKnownPosition, nil);
        }
    } else
    {
        if (![self locationServicesAreEnabled] && subscriber.changeLocationBlock)
        {
            subscriber.changeLocationBlock(nil,[NSError errorWithDomain:@"CLErrorDomain" code:GeolocationHelperErrorLocationServicesDisabled userInfo:nil]);
        }
    }
    
    if (subscriber.authorizationStatusChangeBlock)
    {
        subscriber.authorizationStatusChangeBlock(self.authorizationStatus);
    }
}

- (void) unsubscribeToLocationNews: (Subscriber *) subscriber
{
    subscriber.changeLocationBlock=nil;
    subscriber.changePlacemarkBlock=nil;
    [self.subscribers removeObject:subscriber];
    
    if ([self.subscribers count] == 0)
    {
        [self stopServices];
    }
}

- (void) notifySubscribersNewAuthorizationStatus:(CLAuthorizationStatus)status
{
    for (Subscriber *subscriber in self.subscribers)
    {
        if (subscriber.authorizationStatusChangeBlock && subscriber.subscriberReference)
        {
            subscriber.authorizationStatusChangeBlock(status);
        }
    }
}

- (void) notifySubscribersNewLocation: (CLLocation *) location withError: (NSError *)error
{
    for (Subscriber *subscriber in self.subscribers)
    {
        if (subscriber.changeLocationBlock && subscriber.subscriberReference)
        {
            subscriber.changeLocationBlock(location, error);
        }
    }
}

- (void) notifySubscribersNewPlacemark: (CLPlacemark *) placemark withError: (NSError *)error
{
    for (Subscriber *subscriber in self.subscribers)
    {
        if (subscriber.changePlacemarkBlock && subscriber.subscriberReference)
        {
            subscriber.changePlacemarkBlock(placemark, error);
        }
    }
}

@end
