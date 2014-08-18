//
//  UsuarioFotoCollectionCell.h
//  Pods
//
//  Created by Thiago Castro on 06/03/14.
//
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import <CSAnimationView.h>

@interface UsuarioFotoCollectionCell : UICollectionViewCell

@property (strong, nonatomic) IBOutlet FBProfilePictureView *userProfilePictureView;
@property (strong, nonatomic) IBOutlet UIImageView *imgLiked;
@property (strong, nonatomic) IBOutlet CSAnimationView *viewContainerUsuarios;

@end
