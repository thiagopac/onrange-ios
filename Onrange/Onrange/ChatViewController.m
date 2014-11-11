    //
//  Created by Jesse Squires
//  http://www.hexedbits.com
//
//
//  Documentation
//  http://cocoadocs.org/docsets/JSQMessagesViewController
//
//
//  GitHub
//  https://github.com/jessesquires/JSQMessagesViewController
//
//
//  License
//  Copyright (c) 2014 Jesse Squires
//  Released under an MIT license: http://opensource.org/licenses/MIT
//

#import "ChatViewController.h"
#import "RestKit.h"
#import "MappingProvider.h"
#import "Match.h"
#import "MinhasCombinacoesTableViewController.h"

@implementation ChatViewController


#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.messages = [[NSMutableArray alloc]init];
    
    self.collectionView.collectionViewLayout.incomingAvatarViewSize = CGSizeZero;
    self.collectionView.collectionViewLayout.outgoingAvatarViewSize = CGSizeZero;
    
//configurando nome do usuário e oponente
    self.me = [NSString stringWithFormat:@"%d",[LocalStorageService shared].currentUser.ID];

    self.sender = self.me;
    
    QBUUser *recipient = [LocalStorageService shared].usersAsDictionary[@(self.dialog.recipientID)];
    self.oponenteID = recipient.login == nil ? recipient.email : recipient.fullName;
    self.title = self.oponenteID;
    
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor whiteColor]};
    self.navigationController.navigationBar.topItem.title = @"•";
    
    // Make the info button use the standard icon and hook it up to work
    UIButton *btnDeleteChat = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [btnDeleteChat setImage:[UIImage imageNamed:@"broken_heart"] forState:UIControlStateNormal];
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc]
                                   initWithImage:btnDeleteChat.currentImage style:UIBarButtonItemStylePlain target:self action:@selector(deleteChat)];
    self.navigationItem.rightBarButtonItem = barButton;
    
//removendo camera

    /**
     *  Remove camera button since media messages are not yet implemented
     *
     *   self.inputToolbar.contentView.leftBarButtonItem = nil;
     *
     *  Or, you can set a custom `leftBarButtonItem` and a custom `rightBarButtonItem`
     */
    self.inputToolbar.contentView.leftBarButtonItem = nil;    
    /**
     *  Create bubble images.
     *
     *  Be sure to create your avatars one time and reuse them for good performance.
     *
     */
    self.outgoingBubbleImageView = [JSQMessagesBubbleImageFactory
                                    outgoingMessageBubbleImageViewWithColor:[UIColor jsq_messageBubbleLightGrayColor]];
    
    self.incomingBubbleImageView = [JSQMessagesBubbleImageFactory
                                    incomingMessageBubbleImageViewWithColor:[UIColor jsq_messageBubbleGreenColor]];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    // Set chat notifications
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(chatDidReceiveMessageNotification:)
                                                 name:kNotificationDidReceiveNewMessage object:nil];
    
    if (self.delegateModal) {
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop
                                                                                              target:self
                                                                                              action:@selector(closePressed:)];
    }

    // get messages history
    [QBChat messagesWithDialogID:self.dialog.ID extendedRequest:nil delegate:self];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    /**
     *  Enable/disable springy bubbles, default is NO.
     *  You must set this from `viewDidAppear:`
     *  Note: this feature is mostly stable, but still experimental
     */
//Efeitos de balões deslizando    
    self.collectionView.collectionViewLayout.springinessEnabled = NO;
}

#pragma mark - Actions

- (void)chatDidReceiveMessageNotification:(NSNotification *)notification{
    
    self.showTypingIndicator = YES;
    [self scrollToBottomAnimated:YES];
    
    QBChatMessage *message = notification.userInfo[kMessage];
    if(message.senderID != self.dialog.recipientID){
        return;
    }
    // save message
//    [self.messages addObject:message];
    
    // mostrar na view
    JSQMessage *jsqVindoDoQB = [JSQMessage new];
    if (message.senderID == [LocalStorageService shared].currentUser.ID) {
        jsqVindoDoQB.sender = self.me;
    }else{
        jsqVindoDoQB.sender = self.oponenteID;
    }
    
    jsqVindoDoQB.date = message.datetime;
    jsqVindoDoQB.text = message.text;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.messages addObject:jsqVindoDoQB];
        [JSQSystemSoundPlayer jsq_playMessageReceivedSound];
        [self finishReceivingMessage];
    });
}

- (void)closePressed:(UIBarButtonItem *)sender
{
    [self.delegateModal didDismissJSQDemoViewController:self];
}

#pragma mark - JSQMessagesViewController method overrides

- (void)didPressSendButton:(UIButton *)button
           withMessageText:(NSString *)text
                    sender:(NSString *)sender
                      date:(NSDate *)date
{
    /**
     *  Sending a message. Your implementation of this method should do *at least* the following:
     *
     *  1. Play sound (optional)
     *  2. Add new id<JSQMessageData> object to your data source
     *  3. Call `finishSendingMessage`
     */
    [JSQSystemSoundPlayer jsq_playMessageSentSound];
    
    JSQMessage *message = [[JSQMessage alloc] initWithText:text sender:sender date:date];

    
    // create a message qb
    QBChatMessage *messageqb = [[QBChatMessage alloc] init];
    messageqb.text = text;
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"save_to_history"] = @YES;
    [messageqb setCustomParameters:params];
    
//personal chat 1-1
    messageqb.recipientID = [self.dialog recipientID];
    messageqb.senderID = [LocalStorageService shared].currentUser.ID;
    [[ChatService instance] sendMessage:messageqb];

    [self.messages addObject:message];
    [self finishSendingMessage];
}

- (void)didPressAccessoryButton:(UIButton *)sender
{
    NSLog(@"Camera pressed!");
    /**
     *  Accessory button has no default functionality, yet.
     */
}

#pragma mark - JSQMessages CollectionView DataSource

- (id<JSQMessageData>)collectionView:(JSQMessagesCollectionView *)collectionView messageDataForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return [self.messages objectAtIndex:indexPath.item];
}

- (UIImageView *)collectionView:(JSQMessagesCollectionView *)collectionView bubbleImageViewForItemAtIndexPath:(NSIndexPath *)indexPath
{
    /**
     *  You may return nil here if you do not want bubbles.
     *  In this case, you should set the background color of your collection view cell's textView.
     */
    
    /**
     *  Reuse created bubble images, but create new imageView to add to each cell
     *  Otherwise, each cell would be referencing the same imageView and bubbles would disappear from cells
     */
    
    JSQMessage *message = [self.messages objectAtIndex:indexPath.item];
    
    if ([message.sender isEqualToString:self.sender]) {
        return [[UIImageView alloc] initWithImage:self.outgoingBubbleImageView.image
                                 highlightedImage:self.outgoingBubbleImageView.highlightedImage];
    }
    
    return [[UIImageView alloc] initWithImage:self.incomingBubbleImageView.image
                             highlightedImage:self.incomingBubbleImageView.highlightedImage];
}

#pragma mark QBActionStatusDelegate

- (void)completedWithResult:(Result *)result
{
    if (result.success && [result isKindOfClass:QBChatHistoryMessageResult.class]) {
        QBChatHistoryMessageResult *res = (QBChatHistoryMessageResult *)result;
        NSArray *messages = res.messages;
        
        for (int i=0; i<[messages count]; i++) {
            QBChatAbstractMessage *msgQb = [messages objectAtIndex:i];
            JSQMessage *msgJSQ = [JSQMessage new];
            msgJSQ.text = msgQb.text;
            msgJSQ.sender = [NSString stringWithFormat:@"%d",msgQb.senderID];
            msgJSQ.date  = msgQb.datetime;
            [self.messages addObject:msgJSQ];
        }
    }
    [self finishSendingMessage];
    [self finishReceivingMessage];
}

- (UIImageView *)collectionView:(JSQMessagesCollectionView *)collectionView avatarImageViewForItemAtIndexPath:(NSIndexPath *)indexPath
{
    /**
     *  Return `nil` here if you do not want avatars.
     *  If you do return `nil`, be sure to do the following in `viewDidLoad`:
     *
     *  self.collectionView.collectionViewLayout.incomingAvatarViewSize = CGSizeZero;
     *  self.collectionView.collectionViewLayout.outgoingAvatarViewSize = CGSizeZero;
     *
     *  It is possible to have only outgoing avatars or only incoming avatars, too.
     */
    
    /**
     *  Reuse created avatar images, but create new imageView to add to each cell
     *  Otherwise, each cell would be referencing the same imageView and avatars would disappear from cells
     *
     *  Note: these images will be sized according to these values:
     *
     *  self.collectionView.collectionViewLayout.incomingAvatarViewSize
     *  self.collectionView.collectionViewLayout.outgoingAvatarViewSize
     *
     *  Override the defaults in `viewDidLoad`
     */
    return nil;
}

- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForCellTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    /**
     *  This logic should be consistent with what you return from `heightForCellTopLabelAtIndexPath:`
     *  The other label text delegate methods should follow a similar pattern.
     *
     *  Show a timestamp for every 3rd message
     */
    if (indexPath.item % 3 == 0) {
        JSQMessage *message = [self.messages objectAtIndex:indexPath.item];
        return [[JSQMessagesTimestampFormatter sharedFormatter] attributedTimestampForDate:message.date];
    }
    
    return nil;
}

- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForMessageBubbleTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    JSQMessage *message = [self.messages objectAtIndex:indexPath.item];
    
    /**
     *  iOS7-style sender name labels
     */
    if ([message.sender isEqualToString:self.sender]) {
        return nil;
    }
    
    if (indexPath.item - 1 > 0) {
        JSQMessage *previousMessage = [self.messages objectAtIndex:indexPath.item - 1];
        if ([[previousMessage sender] isEqualToString:message.sender]) {
            return nil;
        }
    }
    
    /**
     *  Don't specify attributes to use the defaults.
     */
    return [[NSAttributedString alloc] initWithString:self.oponentName];
}

- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForCellBottomLabelAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}

#pragma mark - UICollectionView DataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.messages count];
}

- (UICollectionViewCell *)collectionView:(JSQMessagesCollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    /**
     *  Override point for customizing cells
     */
    JSQMessagesCollectionViewCell *cell = (JSQMessagesCollectionViewCell *)[super collectionView:collectionView cellForItemAtIndexPath:indexPath];
    
    /**
     *  Configure almost *anything* on the cell
     *  
     *  Text colors, label text, label colors, etc.
     *
     *
     *  DO NOT set `cell.textView.font` !
     *  Instead, you need to set `self.collectionView.collectionViewLayout.messageBubbleFont` to the font you want in `viewDidLoad`
     *
     *  
     *  DO NOT manipulate cell layout information!
     *  Instead, override the properties you want on `self.collectionView.collectionViewLayout` from `viewDidLoad`
     */
    
    JSQMessage *msg = [self.messages objectAtIndex:indexPath.item];
    
    if ([msg.sender isEqualToString:self.sender]) {
        cell.textView.textColor = [UIColor blackColor];
    }
    else {
        cell.textView.textColor = [UIColor whiteColor];
    }
    
    cell.textView.linkTextAttributes = @{ NSForegroundColorAttributeName : cell.textView.textColor,
                                          NSUnderlineStyleAttributeName : @(NSUnderlineStyleSingle | NSUnderlinePatternSolid) };
    
    return cell;
}



#pragma mark - JSQMessages collection view flow layout delegate

- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
                   layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForCellTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    /**
     *  Each label in a cell has a `height` delegate method that corresponds to its text dataSource method
     */
    
    /**
     *  This logic should be consistent with what you return from `attributedTextForCellTopLabelAtIndexPath:`
     *  The other label height delegate methods should follow similarly
     *
     *  Show a timestamp for every 3rd message
     */
    if (indexPath.item % 3 == 0) {
        return kJSQMessagesCollectionViewCellLabelHeightDefault;
    }
    
    return 0.0f;
}

- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
                   layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForMessageBubbleTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    /**
     *  iOS7-style sender name labels
     */
    JSQMessage *currentMessage = [self.messages objectAtIndex:indexPath.item];
    if ([[currentMessage sender] isEqualToString:self.sender]) {
        return 0.0f;
    }
    
    if (indexPath.item - 1 > 0) {
        JSQMessage *previousMessage = [self.messages objectAtIndex:indexPath.item - 1];
        if ([[previousMessage sender] isEqualToString:[currentMessage sender]]) {
            return 0.0f;
        }
    }
    
    return kJSQMessagesCollectionViewCellLabelHeightDefault;
}

- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
                   layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForCellBottomLabelAtIndexPath:(NSIndexPath *)indexPath
{
    return 0.0f;
}

- (void)collectionView:(JSQMessagesCollectionView *)collectionView
                header:(JSQMessagesLoadEarlierHeaderView *)headerView didTapLoadEarlierMessagesButton:(UIButton *)sender
{
    NSLog(@"Load earlier messages!");
}

-(void)deleteChat{
    UIActionSheet* actionDeleteChat = [[UIActionSheet alloc]
                                       initWithTitle:[NSString stringWithFormat:@"Este chat será apagado e não será possível mais conversar com %@. Tem certeza de que deseja apagar esta conversa?", self.oponenteID]
                                       delegate:(id<UIActionSheetDelegate>)self
                                       cancelButtonTitle:@"Sim"
                                       destructiveButtonTitle:@"Não"
                                       otherButtonTitles:nil];
    [actionDeleteChat showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:   (NSInteger)buttonIndex {
        switch (buttonIndex) {
            case 0: //Não
                break;
            case 1: //Sim
                NSLog(@"Apagando chat");
                [self apagaChat];
                break;
        }
}

-(void)apagaChat{
    
    RKObjectMapping *requestMapping = [RKObjectMapping requestMapping];
    [requestMapping addAttributeMappingsFromArray:@[@"id_chat", @"qbtoken", @"facebook_usuario", @"facebook_usuario2"]];
    
    RKObjectMapping *responseMapping = [RKObjectMapping mappingForClass:[Match class]];
    [responseMapping addAttributeMappingsFromArray:@[@"id_output", @"desc_output"]];
    
    RKRequestDescriptor *requestDescriptor = [RKRequestDescriptor requestDescriptorWithMapping:requestMapping objectClass:[Match class] rootKeyPath:nil method:RKRequestMethodPUT];
    
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:responseMapping
                                                                                            method:RKRequestMethodPUT
                                                                                       pathPattern:nil
                                                                                           keyPath:@"Match"
                                                                                       statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    NSURL *url = [NSURL URLWithString:API];
    NSString  *path= @"match/unmatch";
    
    RKObjectManager *objectManager = [RKObjectManager managerWithBaseURL:url];
    [objectManager addRequestDescriptor:requestDescriptor];
    [objectManager addResponseDescriptor:responseDescriptor];
    
    objectManager.requestSerializationMIMEType = RKMIMETypeJSON;
    
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    
    
    QBUUser *recipient = [LocalStorageService shared].usersAsDictionary[@(self.dialog.recipientID)];


    Match *match= [Match new];
    
    match.facebook_usuario = [def objectForKey:@"facebook_usuario"];
    match.facebook_usuario2 = recipient.login;
    match.id_chat = self.dialog.ID;
    match.qbtoken = [[QBBaseModule sharedModule]token];
    
    [objectManager putObject:match path:path parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
          if(mappingResult != nil){
              Match *unMatchEfetuado = [mappingResult firstObject];
              if (unMatchEfetuado.id_output == 1) {
                  MinhasCombinacoesTableViewController *MinhasCombinacoesTVC = [self.navigationController.viewControllers objectAtIndex:1];
                  [self.navigationController popToViewController:MinhasCombinacoesTVC animated:YES];
              }
              
          }
      }failure:^(RKObjectRequestOperation *operation, NSError *error) {
          self.status = operation.HTTPRequestOperation.response.statusCode;
          
          if(self.status == 540){
              NSLog(@"Erro ao desfazer match");
              [self apagaChat];
          }else if(self.status == 544){
              NSLog(@"Erro ao apagar chat no QB");
              [self apagaChat];
          }else if(self.status == 545){
              [self apagaChat];
              NSLog(@"Erro ao buscar ID do usuario 2");
          }else{
              NSLog(@"ERRO FATAL - apagaChat");
              NSLog(@"Error: %@", error);
              [self apagaChat];
          }

      }];
}

@end
