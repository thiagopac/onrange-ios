//
//  ChatViewController.h
//  Onrange
//
//  Created by Thiago Castro on 16/10/14.
//  Copyright (c) 2014 Thiago Castro. All rights reserved.
//

#import "JSQMessages.h"

@class ChatViewController;


@protocol JSQDemoViewControllerDelegate <NSObject>

- (void)didDismissJSQDemoViewController:(ChatViewController *)vc;

@end

@interface ChatViewController : JSQMessagesViewController<QBActionStatusDelegate, QBChatDelegate, UITextViewDelegate>

@property (nonatomic, strong) QBChatDialog *dialog;

@property (weak, nonatomic) id<JSQDemoViewControllerDelegate> delegateModal;

@property (strong, nonatomic) NSMutableArray *messages;
@property (copy, nonatomic) NSDictionary *avatars;

@property (strong, nonatomic) UIImageView *outgoingBubbleImageView;
@property (strong, nonatomic) UIImageView *incomingBubbleImageView;

@property (strong, nonatomic) NSString *oponenteID;
@property (assign, nonatomic) NSString *me;
@property (assign, nonatomic) NSString *oponentName;

- (void)closePressed:(UIBarButtonItem *)sender;

@property (assign, nonatomic) NSInteger status;

@end
