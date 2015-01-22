//
//  PushPermissionView.h
//  
//
//  Created by Thiago Castro on 17/10/14.
//
//

#import <UIKit/UIKit.h>

@interface PushPermissionView : UIView<QBActionStatusDelegate>

- (IBAction)btnPushPermission:(id)sender;
@property (strong, nonatomic) IBOutlet UIButton *btnPushPermission;

@end
