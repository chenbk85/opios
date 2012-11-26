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


#import <hookflash/IConversationThread.h>
#import <hookflash/IContact.h>
#import <hookflash/IXML.h>

#import "HOPConversationThread_Internal.h"
#import "HOPConversationThread.h"
#import "HOPContact_Internal.h"
#import "HOPContact.h"
#import "HOPAccount_Internal.h"
#import "HOPAccount.h"
#import "OpenPeerUtility.h"

#import "OpenPeerStorageManager.h"

using namespace hookflash;

@implementation HOPConversationThread

+ (NSString*) deliveryStateToString: (HOPConversationThreadMessageDeliveryStates) state
{
    return [NSString stringWithUTF8String: IConversationThread::toString((IConversationThread::MessageDeliveryStates) state)];
}

+ (NSString*) stateToString: (HOPConversationThreadContactStates) state
{
    return [NSString stringWithUTF8String: IConversationThread::toString((hookflash::IConversationThread::ContactStates) state)];
}

- (BOOL) createConversationThread: (HOPAccount*) account profileBundleEl:(NSString*) profileBundleEl
{
    BOOL created = NO;
    if (account != nil)
    {
        zsLib::XML::ElementPtr elementPtr;
        if ([profileBundleEl length] > 0)
            elementPtr = IXML::createFromString([profileBundleEl UTF8String]);
        else
            elementPtr = zsLib::XML::ElementPtr();
        
        conversationThreadPtr = IConversationThread::create([account getAccountPtr], elementPtr);
        if (conversationThreadPtr)
            created = YES;
    }
    return YES;
}

- (NSString*) getThreadId
{
    NSString* threadId = nil;
    
    if(conversationThreadPtr)
    {
        threadId = [NSString stringWithUTF8String: conversationThreadPtr->getThreadID()];
    }
    else
    {
        [NSException raise:NSInvalidArgumentException format:@"Invalid OpenPeer conversation thread pointer!"];
    }
    return threadId;
}

- (BOOL) amIHost
{
    BOOL ret = NO;
    if (conversationThreadPtr)
    {
        ret = conversationThreadPtr->amIHost();
    }
    else
    {
        [NSException raise:NSInvalidArgumentException format:@"Invalid OpenPeer conversation thread pointer!"];
    }
    return ret;
}

- (NSArray*) getContacts
{
    NSMutableArray* contactArray = nil;
    if (conversationThreadPtr)
    {
        contactArray = [[NSMutableArray alloc] init];
        IConversationThread::ContactList contactList;
        conversationThreadPtr->getContacts(contactList);
        
        for (IConversationThread::ContactList::iterator contact = contactList.begin(); contact != contactList.end(); ++contact)
        {
            IContactPtr contactPtr = *contact;
            HOPContact* tempContact = [[OpenPeerStorageManager sharedInstance] getContactForId:[NSString stringWithUTF8String:contactPtr->getContactID()]];
            [contactArray addObject:tempContact];
        }
        
    }
    else
    {
        [NSException raise:NSInvalidArgumentException format:@"Invalid OpenPeer conversation thread pointer!"];
    }
    
    return [contactArray autorelease];
}

- (NSString*) getProfileBundle: (HOPContact*) contact
{
    NSString* ret = nil;
    if (conversationThreadPtr)
    {
        ret = [NSString stringWithUTF8String:IXML::convertToString(conversationThreadPtr->getProfileBundle([contact getContactPtr]))];
    }
    else
    {
        [NSException raise:NSInvalidArgumentException format:@"Invalid OpenPeer conversation thread pointer!"];
    }
    return ret;
}

- (HOPConversationThreadContactStates) getContactState: (HOPContact*) contact
{
    HOPConversationThreadContactStates ret = HOPConversationThreadContactStateNotApplicable;
    if(conversationThreadPtr)
    {
        ret = (HOPConversationThreadContactStates) conversationThreadPtr->getContactState([contact getContactPtr]);
    }
    else
    {
        [NSException raise:NSInvalidArgumentException format:@"Invalid OpenPeer conversation thread pointer!"];
    }
    
    return ret;
}

- (void) addContacts: (NSArray*) contacts
{
    if(conversationThreadPtr)
    {
        if ([contacts count] > 0)
        {
            IConversationThread::ContactInfoList contactList;
            for (HOPContact* contact in contacts)
            {
                hookflash::IConversationThread::ContactInfo contactInfo;
                contactInfo.mContact = [contact getContactPtr];
                contactInfo.mProfileBundleEl = zsLib::XML::ElementPtr();
                
                contactList.push_back(contactInfo);
            }
            conversationThreadPtr->addContacts(contactList);
        }
    }
    else
    {
        [NSException raise:NSInvalidArgumentException format:@"Invalid OpenPeer conversation thread pointer!"];
    }
}

- (void) removeContacts: (NSArray*) contacts
{
    if(conversationThreadPtr)
    {
        if ([contacts count] > 0)
        {
            IConversationThread::ContactList contactList;
            for (HOPContact* contact in contacts)
            {
                contactList.push_back([contact getContactPtr]);
            }
            conversationThreadPtr->removeContacts(contactList);
        }
    }
    else
    {
        [NSException raise:NSInvalidArgumentException format:@"Invalid OpenPeer conversation thread pointer!"];
    }

}

- (void) sendMessage: (NSString*) messageID messageType:(NSString*) messageType message:(NSString*) message
{
    if(conversationThreadPtr)
    {
        conversationThreadPtr->sendMessage([messageID UTF8String], [messageType UTF8String], [message UTF8String]);
    }
    else
    {
        [NSException raise:NSInvalidArgumentException format:@"Invalid OpenPeer conversation thread pointer!"];
    }
}


- (BOOL) getMessage: (NSString*) messageID outFrom:(HOPContact**) outFrom outMessageType:(NSString**) outMessageType outMessage:(NSString**) outMessage outTime:(NSDate**) outTime
{
    BOOL ret = NO;
    if(conversationThreadPtr)
    {
        IContactPtr fromContact;
        zsLib::String messageType;
        zsLib::String message;
        zsLib::Time messageTime;
    
        conversationThreadPtr->getMessage([messageID UTF8String], fromContact, messageType, message, messageTime);
        
        if (fromContact && messageType && message)
        {
            *outFrom = [[OpenPeerStorageManager sharedInstance] getContactForId:[NSString stringWithUTF8String:fromContact->getContactID()]];
            *outMessageType = [NSString stringWithUTF8String:messageType];
            *outMessage = [NSString stringWithUTF8String:message];
            *outTime = [OpenPeerUtility convertPosixTimeToDate:messageTime];
            ret = YES;
        }
        
    }
    else
    {
        [NSException raise:NSInvalidArgumentException format:@"Invalid OpenPeer conversation thread pointer!"];
    }
    return ret;
}

- (BOOL) getMessageDeliveryState: (NSString*) messageID outDeliveryState:(HOPConversationThreadMessageDeliveryStates*) outDeliveryState
{
    BOOL ret = NO;
    hookflash::IConversationThread::MessageDeliveryStates tmpState;

    if(conversationThreadPtr)
    {
        if ([messageID length] > 0)
        {
            ret = conversationThreadPtr->getMessageDeliveryState([messageID UTF8String], tmpState);
            *outDeliveryState = (HOPConversationThreadMessageDeliveryStates) tmpState;
        }
    }
    else
    {
        [NSException raise:NSInvalidArgumentException format:@"Invalid OpenPeer conversation thread pointer!"];
    }
    return ret;
}

#pragma mark - Internal methods
- (IConversationThreadPtr) getConversationThreadPtr
{
    return conversationThreadPtr;
}
@end
