//
//  GeolocationHelper.h
//  AssassinVictim
//
//  Created by Mihriban Minaz on 14/11/15.
//  Copyright © 2015 Mihriban Minaz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@class Destination;

typedef void (^GeolocationHelperLocationCompletion)(CLLocation *,NSError *);
typedef void (^GeolocationHelperPlacemarkCompletion)(CLPlacemark *, NSError *);
typedef void (^GeolocationHelperAuthorizationStatusChange)(CLAuthorizationStatus);

extern NSString * kTryToRecoverLocationServices;
extern NSInteger const GeolocationHelperErrorLocationServicesDisabled;
extern NSString * kNearbyAvailableStatusChanged;

@interface GeolocationHelper : NSObject

@property (nonatomic, strong) CLPlacemark *lastKnownPlacemark;
@property (nonatomic, strong) CLLocation *lastKnownPosition;
@property (nonatomic, strong) Destination *lastClosestDestination;

+ (instancetype) shared;

- (void) startListeningWithLocationChange:(GeolocationHelperLocationCompletion)cBlock
                          placemarkChange:(GeolocationHelperPlacemarkCompletion)pBlock
                authorizationStatusChange:(GeolocationHelperAuthorizationStatusChange)aBlock
                            withReference:(id) reference;
- (void) isItOcean:(CLLocation *)location withSuccessBlock:(void (^)())successBlock withFailureBlock:(void(^)())failureBlock;

- (void) stopListeningForReference: (id) reference;

- (void) stopServices;
- (void) resumeServices;

- (void) resetPosition;
- (BOOL) locationServicesAreEnabled;

- (void) askForLocationServices;

- (NSInteger) distanceInMetersFrom: (CLLocationCoordinate2D) coordinates;
- (BOOL) isNearByPosition:(CLLocationCoordinate2D)coordinates;
- (BOOL) isCheckinAvailableforPosition: (CLLocationCoordinate2D)coordinates;

- (CLAuthorizationStatus) authorizationStatus;

@end
