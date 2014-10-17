//
//  FBIntegrationView.h
//  
//
//  Created by Thiago Castro on 17/10/14.
//
//

#import <UIKit/UIKit.h>
#import <FacebookSDK.h>

@interface FBIntegrationView : UIView
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (strong, nonatomic) IBOutlet UIView *viewContainer;
@property (strong, nonatomic) IBOutlet FBProfilePictureView *imgProfileUsuario;
@property (strong, nonatomic) IBOutlet UILabel *lblNomeUsuario;
@property (strong, nonatomic) NSDictionary<FBGraphUser> *user;
@property (strong, nonatomic) IBOutlet UIButton *btnFB;

@end
