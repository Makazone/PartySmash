#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface GCGeocodingService : NSObject

- (id)init;
- (void)geocodeAddress:(NSString *)address completion:(void (^)(NSError *))handler;
- (void)geocodeCoordinate:(CLLocationCoordinate2D)coordinate2D completion:(void (^)(NSError *))handler;

@property (nonatomic) NSString *city;
@property (nonatomic) NSString *street;
@property (nonatomic) NSString *house;

@property (nonatomic) NSNumber *longitude;
@property (nonatomic) NSNumber *latitude;

@property (nonatomic, strong) NSDictionary *geocode;

@end
