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
#import "JMAnimatedImageView/JMAnimatedImageView.h"


@interface IntroViewController : UIViewController<EAIntroDelegate>


@property (strong, nonatomic) id<FBGraphUser> user;
@property (assign, nonatomic) NSInteger status;

@property (strong, nonatomic) IBOutlet JMAnimatedImageView *jmImageView;

@end
