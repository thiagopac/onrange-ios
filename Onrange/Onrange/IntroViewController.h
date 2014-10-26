//
//  LoadingViewController.h
//  Onrange
//
//  Created by Thiago Castro on 16/10/14.
//  Copyright (c) 2014 Thiago Castro. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EAIntroView.h"
#import <FacebookSDK/FacebookSDK.h>

@interface IntroViewController : UIViewController<EAIntroDelegate>


@property (strong, nonatomic) id<FBGraphUser> user;

@end
