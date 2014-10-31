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

#import "JSQSystemSoundPlayer+JSQMessages.h"

static NSString * const kJSQMessageReceivedSoundName = @"message_received";
static NSString * const kJSQMessageSentSoundName = @"message_sent";


@implementation JSQSystemSoundPlayer (JSQMessages)

+ (void)jsq_playMessageReceivedSound
{
    
    [[JSQSystemSoundPlayer sharedPlayer]playSoundWithFilename:kJSQMessageReceivedSoundName fileExtension:kJSQSystemSoundTypeAIFF];
    
//    para vibrar com som playAlertSoundWithFilename
    
}

+ (void)jsq_playMessageReceivedAlert
{
    [[JSQSystemSoundPlayer sharedPlayer]playSoundWithFilename:kJSQMessageReceivedSoundName fileExtension:kJSQSystemSoundTypeAIFF];
}

+ (void)jsq_playMessageSentSound
{
    [[JSQSystemSoundPlayer sharedPlayer]playSoundWithFilename:kJSQMessageReceivedSoundName fileExtension:kJSQSystemSoundTypeAIFF];
}

+ (void)jsq_playMessageSentAlert
{
    [[JSQSystemSoundPlayer sharedPlayer]playSoundWithFilename:kJSQMessageReceivedSoundName fileExtension:kJSQSystemSoundTypeAIFF];
}

@end
