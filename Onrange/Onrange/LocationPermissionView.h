//
//  LocationPermissionView.h
//  
//
//  Created by Thiago Castro on 17/10/14.
//
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@interface LocationPermissionView : UIView<CLLocationManagerDelegate>

@property (strong, nonatomic) CLLocationManager *locationManager;
- (IBAction)btnLocationPermission:(id)sender;
@property (strong, nonatomic) IBOutlet UIButton *btnLocationPermission;

@end
