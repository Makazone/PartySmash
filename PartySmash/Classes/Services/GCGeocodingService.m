//#define kBgQueue dispatch_get_main_queue()(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0) //1

#import <GoogleMaps/GoogleMaps.h>
#import <CoreLocation/CoreLocation.h>
#import "GCGeocodingService.h"

@implementation GCGeocodingService {
    NSData *_data;
    NSOperationQueue *_geocodeQueue;

    NSArray *_addressComponents;
    NSDictionary *_locationComponents;

    GMSGeocoder *_reverseGeocoder;
}

- (id)init{
    self = [super init];
    if (self) {
        _geocode = [[NSDictionary alloc]initWithObjectsAndKeys:@"0.0",@"lat",@"0.0",@"lng",@"Null Island",@"address",nil];

        _reverseGeocoder = [[GMSGeocoder alloc] init];

        _geocodeQueue = [NSOperationQueue new];
        [_geocodeQueue setName:@"Geocode queue"];
    }
    return self;
}

- (void)geocodeAddress:(NSString *)address completion:(void (^)(NSError *))handler {
    NSString *geocodingBaseUrl = @"http://maps.googleapis.com/maps/api/geocode/json?";
    NSString *url = [NSString stringWithFormat:@"%@address=%@&sensor=false", geocodingBaseUrl,address];
    url = [url stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding];
    
    NSURL *queryUrl = [NSURL URLWithString:url];
//    [_geocodeQueue addOperationWithBlock:^{
        NSData *data = [NSData dataWithContentsOfURL:queryUrl];
        [self fetchedData:data withCompletion:handler];
//    }];
}

- (void)fetchedData:(NSData *)data withCompletion:(void (^)(NSError *error))handler {
    NSError *error;
    if (!data) {
        error = [NSError errorWithDomain:@"datanil" code:1 userInfo:nil];
        handler(error);
    } else {
        NSDictionary *json = [NSJSONSerialization
                JSONObjectWithData:data
                           options:kNilOptions
                             error:&error];

        if (![(NSString *)[json objectForKey:@"status"] isEqualToString:@"OK"]) {
            error = [[NSError alloc] initWithDomain:@"Geocoding" code:1 userInfo:nil];
            // TODO properly handle error
        } else {
            NSArray *results = [json objectForKey:@"results"];
            NSDictionary *result = [results objectAtIndex:0];

            self.formatted_address = [result objectForKey:@"formatted_address"];

            _addressComponents = [result objectForKey:@"address_components"];

            if (_addressComponents.count > 3) self.city = [[_addressComponents objectAtIndex:3] objectForKey:@"long_name"];
            if (_addressComponents.count > 1) self.street = [[_addressComponents objectAtIndex:1] objectForKey:@"short_name"];
            if (_addressComponents.count > 0) self.house = [[_addressComponents objectAtIndex:0] objectForKey:@"short_name"];

            NSDictionary *geometry = [result objectForKey:@"geometry"];
            _locationComponents = [geometry objectForKey:@"location"];

            self.longitude = [_locationComponents objectForKey:@"lng"];
            self.latitude = [_locationComponents objectForKey:@"lat"];

//            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                handler(error);
//            }];
        }
    }
}

- (void)geocodeCoordinate:(CLLocationCoordinate2D)coordinate2D completion:(void (^)(NSError *))handler {
    GMSReverseGeocodeCallback geocodeHandler = ^(GMSReverseGeocodeResponse *response, NSError *error) {
        GMSAddress *address = response.firstResult;
        if (address) {
            NSLog(@"Geocoder result: %@", address);

            NSMutableString *addressLine = [NSMutableString new];
            for (int i = 0; i < address.lines.count; i++){
                [addressLine appendString:address.lines[i]];
                [addressLine appendString:@" "];
            }
            self.formatted_address = addressLine;

            self.street = address.thoroughfare;

            NSMutableString *snippet = [[NSMutableString alloc] init];
            if (address.subLocality != NULL) {
                [snippet appendString:[NSString stringWithFormat:@"subLocality: %@\n",
                                                                 address.subLocality]];
            }
            if (address.locality != NULL) {
                [snippet appendString:[NSString stringWithFormat:@"locality: %@\n",
                                                                 address.locality]];
                self.city = address.locality;
            }
            if (address.administrativeArea != NULL) {
                [snippet appendString:[NSString stringWithFormat:@"administrativeArea: %@\n",
                                                                 address.administrativeArea]];
            }
            if (address.country != NULL) {
                [snippet appendString:[NSString stringWithFormat:@"country: %@\n",
                                                                 address.country]];
            }

            NSLog(@"snippet = %@", snippet);

            self.longitude = [NSNumber numberWithDouble:coordinate2D.longitude];
            self.latitude  = [NSNumber numberWithDouble:coordinate2D.latitude];

            handler(nil);

//            marker.snippet = snippet;
//
//            marker.appearAnimation = kGMSMarkerAnimationPop;
//            mapView.selectedMarker = marker;
//            marker.map = _mapView;
        } else {
            NSError *e = [NSError errorWithDomain:@"geocode" code:1 userInfo:nil];
            handler(e);
            NSLog(@"Could not reverse geocode point (%f,%f): %@",
                    coordinate2D.latitude, coordinate2D.longitude, error);
        }
    };
    [_reverseGeocoder reverseGeocodeCoordinate:coordinate2D completionHandler:geocodeHandler];
}

@end

