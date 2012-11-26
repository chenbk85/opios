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


#import <hookflash/IAccount.h>
#import <hookflash/IContact.h>
#import <hookflash/IConversationThread.h>
#import <hookflash/IXML.h>

#import "HOPAccount_Internal.h"
#import "HOPContact_Internal.h"
#import "HOPAccountSubscription_Internal.h"
#import "OpenPeerStorageManager.h"

#import "HOPAccount.h"
#import "HOPContact.h"
#import "HOPConversationThread.h"
#import "HOPAccountSubscription.h"


@implementation HOPAccount

/**
 Converts State enum to string
 @param state OpenPeer_AccountStates enum
 @returns NSString representation of enum
 */
+ (NSString*) stateToString:(HOPAccountStates) state
{
  return [NSString stringWithUTF8String: IAccount::toString((hookflash::IAccount::AccountStates) state)];
}


/**
 Converts Error enum to string
 @param errorCode OpenPeer_AccountErrors enum
 @returns NSString representation of enum
 */
+ (NSString*) errorToString:(HOPAccountErrors) errorCode
{
  return [NSString stringWithUTF8String: IAccount::toString((hookflash::IAccount::AccountErrors) errorCode)];
}

/**
 Shutdown of the openpeer account.
 */
- (void) shutdown
{
    if (accountPtr)
        accountPtr->shutdown();
    else
        [NSException raise:NSInternalInconsistencyException format:@"Invalid OpenPeer account pointer!"];
}

/**
 Retrieves current openpeer account state
 @returns OpenPeer_AccountStates current state of the openpeer account
 */
- (HOPAccountStates) getState
{
    HOPAccountStates ret = HOPAccountStateShuttingDown;
    
    if (accountPtr)
    {
        ret = (HOPAccountStates) accountPtr->getState();
    }
    else
    {
        [NSException raise:NSInternalInconsistencyException format:@"Invalid OpenPeer account pointer!"];
    }
    return ret;
}


/**
 Retrieves last openpeer account error
 @returns OpenPeer_AccountStates current state of the openpeer account
 */
- (HOPAccountErrors) getLastError
{
    HOPAccountErrors ret = HOPAccountErrorInternalError;
    
    if (accountPtr)
    {
        ret = (HOPAccountErrors) accountPtr->getLastError();
    }
    else
    {
        [NSException raise:NSInvalidArgumentException format:@"Invalid OpenPeer account pointer!"];
    }
    return ret;
}


- (HOPAccountSubscription*) subscribe: (id<HOPAccountDelegate>) delegate
{
    HOPAccountSubscription* accountSubscription = nil;
    
    if (accountPtr)
    {
        boost::shared_ptr<OpenPeerAccountDelegate> openPeerAccountDelegatePtr = OpenPeerAccountDelegate::create(delegate);
        
        if (openPeerAccountDelegatePtr)
        {
            listOfOpenPeerAccountDelegates.push_back(openPeerAccountDelegatePtr);
            IAccountSubscriptionPtr accountSubscriptionPtr = accountPtr->subscribe(openPeerAccountDelegatePtr);
            
            accountSubscription = [[HOPAccountSubscription alloc] init];
            [accountSubscription setAccountSubscription:accountSubscriptionPtr];
            return [accountSubscription autorelease];
        }
    }
    else
    {
        [NSException raise:NSInvalidArgumentException format:@"Invalid OpenPeer account pointer!"];
    }
    return accountSubscription;
}

/**
 Retrieves self contact
 @returns HOPContact contact object for self
 */
- (HOPContact*) getSelfContact
{
    HOPContact* hopContact = nil;
    if (accountPtr)
    {
        IContactPtr contactPtr = accountPtr->getSelfContact();
        if (contactPtr)
        {
            hopContact = [[OpenPeerStorageManager sharedInstance] getContactForId:[NSString stringWithUTF8String:contactPtr->getContactID()]];
        }
    }
    else
    {
        [NSException raise:NSInvalidArgumentException format:@"Invalid OpenPeer account pointer!"];
    }
    return hopContact;
}

/**
 Retrieves openpeer account location ID
 @returns NSString representation of openpeer account location ID
 */
- (NSString*) getLocationID
{
    NSString* locationId = nil;
    
    if(accountPtr)
    {
        locationId = [NSString stringWithUTF8String: accountPtr->getLocationID()];
    }
    else
    {
        [NSException raise:NSInvalidArgumentException format:@"Invalid OpenPeer account pointer!"];
    }
    return locationId;
}

/**
 Saves private peer file.
 @returns NSString private peer xml file
 */
- (NSString*) privatePeerToString
{
    NSString* xml = nil;
    if(accountPtr)
    {
        zsLib::XML::ElementPtr element = accountPtr->savePrivatePeer();
        if (element)
        {
            xml = [NSString stringWithUTF8String: IXML::convertToString(element)];
        }
    }
    else
    {
        [NSException raise:NSInvalidArgumentException format:@"Invalid OpenPeer account pointer!"];
    }
    return xml;
}

/**
 Saves public peer file.
 @returns NSString public peer xml file
 */
- (NSString*) publicPeerToString
{
    NSString* xml = nil;
    if(accountPtr)
    {
        zsLib::XML::ElementPtr element = accountPtr->savePublicPeer();
        if (element)
        {
            xml = [NSString stringWithUTF8String: IXML::convertToString(element)];
        }
    }
    else
    {
        [NSException raise:NSInvalidArgumentException format:@"Invalid OpenPeer account pointer!"];
    }
    return xml;
}

/**
 Subscribe to the notification of specific contact.
 @param contact HOPContact contact to receive notifications about
 */
- (void) notifyAboutContact:(HOPContact*) contact
{
    if (accountPtr)
    {
        if (contact)
            accountPtr->notifyAboutContact([contact getContactPtr]);
    }
    else
    {
        [NSException raise:NSInvalidArgumentException format:@"Invalid OpenPeer account pointer!"];
    }
}

/**
 Hint about contact location.
 @param contact HOPContact contact to receive notifications about
 @param locationID NSString location id
 */
- (void) hintAboutContactLocation:(HOPContact*) contact locationID:(NSString*) locationID
{
    if (accountPtr)
    {
        if (contact)
            accountPtr->hintAboutContactLocation([contact getContactPtr], [locationID UTF8String]);
    }
    else
    {
        [NSException raise:NSInvalidArgumentException format:@"Invalid OpenPeer account pointer!"];
    }
}

/**
 Retrieves conversation thread object based on ts ID.
 @param threadID NSString conversation thread ID
 */
- (HOPConversationThread*) getConversationThreadByID:(NSString*) threadID
{
    HOPConversationThread* hopConversationThread = nil;
    if ([threadID length] > 0)
    {
        hopConversationThread = [[OpenPeerStorageManager sharedInstance] getConversationThreadForId:threadID];
    }
    
    //TODO_WARNING: This is not required. In case object is nil it should be created a new one
    /*if (hopConversationThread == nil)
    {
        if (accountPtr)
        {
            IConversationThreadPtr conversationThreadPtr = accountPtr->getConversationThreadByID([threadID UTF8String]);
            if (conversationThreadPtr)
            {
                hopConversationThread = [[OpenPeerStorageManager sharedInstance] getConversationThreadForId:[NSString stringWithUTF8String:conversationThreadPtr->getThreadID()]];
            }
        }
        else
        {
            [NSException raise:NSInvalidArgumentException format:@"Invalid OpenPeer account pointer!"];
        }
    }*/
    
    return hopConversationThread;
}

/**
 Retrieves all conversation threads
 @param outConversationThreads std::list<HOPConversationThread> list of conversation threads
 */
- (NSArray*) getConversationThreads
{
    return [[OpenPeerStorageManager sharedInstance] getConversationThreads];
    
    //TODO_WARNING: This is not required.
    /*
    if (accountPtr)
    {
        hookflash::IAccount::ConversationThreadList outConversationThreads;
        accountPtr->getConversationThreads(outConversationThreads);
        
        //std::list<IConversationThreadPtr>::iterator it;
        
        for (std::list<IConversationThreadPtr>::iterator conversationThread = outConversationThreads.begin(); conversationThread != outConversationThreads.end(); ++conversationThread)
        {
            IConversationThreadPtr conversationThreadPtr = *conversationThread;
           
        }
        
    }
    else
    {
        [NSException raise:NSInvalidArgumentException format:@"Invalid OpenPeer account pointer!"];
    }*/
}

- (void) setAccountPtr:(IAccountPtr) inAccountPtr
{
    accountPtr = inAccountPtr;
}

- (IAccountPtr) getAccountPtr
{
    return accountPtr;
}
@end
