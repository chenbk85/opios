/*
 
 Copyright (c) 2012, SMB Phone Inc.
 All rights reserved.
 
 Redistribution and use in source and binary forms, with or without
 modification, are permitted provided that the following conditions are met:
 
 1. Redistributions of source code must retain the above copyright notice, this
 list of conditions and the following disclaimer.
 2. Redistributions in binary form must reproduce the above copyright notice,
 this list of conditions and the following disclaimer in the documentation
 and/or other materials provided with the distribution.
 
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR
 ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 
 The views and conclusions contained in the software and documentation are those
 of the authors and should not be interpreted as representing official policies,
 either expressed or implied, of the FreeBSD Project.
 
 */

#import "ConversationThreadDelegate.h"
#import "SessionManager.h"
#import "ContactsManager.h"
#import "MessageManager.h"

#import <OpenpeerSDK/HOPConversationThread.h>
#import <OpenpeerSDK/HOPContact.h>

@implementation ConversationThreadDelegate

- (void) onConversationThreadNew:(HOPConversationThread*) conversationThread
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (conversationThread)
        {
            NSMutableArray* contacts = [[NSMutableArray alloc] init];
            NSArray* participants = [conversationThread getContacts];
            for (HOPContact* hopContact in participants)
            {
                if (![hopContact isSelf])
                {
                    //In case profile bundle is required you can get it this way
                    NSString* profile = [conversationThread getProfileBundle:hopContact];
                    //Here you can parse element to identifier contact who initiated communication. This is necessary in case contact is in the list, but it is not marked as openpeer user.
                    Contact* contact = [[ContactsManager sharedContactsManager] getContactForID:[hopContact getStableUniqueID]];
                    
                    if (contact)
                      [contacts addObject:contact];
                    
                }
            }
            
            [[SessionManager sharedSessionManager] createSessionForContacts:contacts andConversationThread:conversationThread];
        }
    });
}
- (void) onConversationThreadContactsChanged:(HOPConversationThread*) conversationThread
{
    dispatch_async(dispatch_get_main_queue(), ^{
    });
}
- (void) onConversationThreadContactStateChanged:(HOPConversationThread*) conversationThread contact:(HOPContact*) contact contactState:(HOPConversationThreadContactStates) contactState
{
    dispatch_async(dispatch_get_main_queue(), ^{
    });
}
- (void) onConversationThreadMessage:(HOPConversationThread*) conversationThread messageID:(NSString*) messageID
{
    dispatch_async(dispatch_get_main_queue(), ^{
        HOPMessage* message = [conversationThread getMessageForID:messageID];
        if (message)
        {
            [[MessageManager sharedMessageManager] onMessageReceived:message forSessionId:[conversationThread getThreadId]];
        }
    });
}
- (void) onConversationThreadMessageDeliveryStateChanged:(HOPConversationThread*) conversationThread messageID:(NSString*) messageID messageDeliveryStates:(HOPConversationThreadMessageDeliveryStates) messageDeliveryStates
{
    dispatch_async(dispatch_get_main_queue(), ^{
    });
}
- (void) onConversationThreadPushMessage:(HOPConversationThread*) conversationThread messageID:(NSString*) messageID contact:(HOPContact*) contact
{
    dispatch_async(dispatch_get_main_queue(), ^{
    });
}
@end
