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

#import "SessionManager.h"
#import "ContactsManager.h"
#import "MainViewController.h"
#import "ActiveSessionViewController.h"

#import "Utility.h"
#import "Contact.h"
#import "Session.h"
#import "OpenPeerUser.h"
#import "OpenPeer.h"
#import <OpenpeerSDK/HOPConversationThread.h>
#import <OpenpeerSDK/HOPContact.h>
#import <OpenpeerSDK/HOPMessage.h>
#import <OpenpeerSDK/HOPCall.h>

@interface SessionManager()

@property (nonatomic, assign) Session* sessionWithActiveCall;
- (id) initSingleton;
- (BOOL) setCallFlag:(BOOL) activeCall forSession:(Session*) inSession;

@end

@implementation SessionManager

/**
 Retrieves singleton object of the Login Manager.
 @return Singleton object of the Login Manager.
 */
+ (id) sharedSessionManager
{
    static dispatch_once_t pred = 0;
    __strong static id _sharedObject = nil;
    dispatch_once(&pred, ^{
        _sharedObject = [[self alloc] initSingleton];
    });
    return _sharedObject;
}

/**
 Initialize singleton object of the Login Manager.
 @return Singleton object of the Login Manager.
 */
- (id) initSingleton
{
    self = [super init];
    if (self)
    {
        self.sessionsDictionary = [[[NSMutableDictionary alloc] init] autorelease];
    }
    return self;
}

- (void)dealloc
{
    [_sessionsDictionary release];
    
    [super dealloc];
}

/**
 Creates a session for selected contacts
 @param contact Contact Contact for which session will be created.
*/
- (Session*)createSessionForContact:(Contact *)contact
{
    Session* ret = nil;
    
    //Create user profile which will be passed to other partie.
    NSString* profileBundle = [[OpenPeerUser sharedOpenPeerUser] createProfileBundle];
    //Create a conversation thread 
    HOPConversationThread* conversationThread = [HOPConversationThread conversationThreadWithProfileBundle:profileBundle];
    //Create a session with new conversation thread
    ret = [[Session alloc] initWithContact:contact conversationThread:conversationThread];
    
    //Add list of all participants. Currently only one participant is added
    if (ret && contact.hopContact && [[contact.hopContact getPeerFile] length] > 0)
    {
        NSArray* participants = [NSArray arrayWithObject:contact.hopContact];
        [conversationThread addContacts:participants];
    }
    
    if (ret)
    {
        //Store session object in dictionary
        [self.sessionsDictionary setObject:ret forKey:[conversationThread getThreadId]];
    }
    
    return [ret autorelease];
}

/**
 Creates a incoming session.
 @param contacts NSArray List of participants.
 @param inConversationThread HOPConversationThread Incoming conversation thread
*/
- (Session*) createSessionForContacts:(NSArray*) contacts andConversationThread:(HOPConversationThread*) inConversationThread
{
    Session* ret = [[Session alloc] initWithContacts:contacts conversationThread:inConversationThread];
    
    if (ret)
    {
        [self.sessionsDictionary setObject:ret forKey:[inConversationThread getThreadId]];
    }
    return [ret autorelease];
}

/**
 Get active session for contact.
 @param contacts Contact One of the participants.
 @return session with participant
*/
- (Session*) getSessionForContact:(Contact*) contact
{
    for (Session* session in [self.sessionsDictionary allValues])
    {
        if ([session.participantsArray containsObject:contact])
            return session;
    }
    return nil;
}

- (void)endSession:(Session *)session
{

}

- (void) makeCallForSession:(Session*) inSession includeVideo:(BOOL) includeVideo
{
    HOPContact* contact = [[[inSession participantsArray] objectAtIndex:0] hopContact];
    inSession.currentCall = [HOPCall placeCall:inSession.conversationThread toContact:contact includeAudio:YES includeVideo:includeVideo];
}

- (void) endCallForSession:(Session*) inSession
{
    [[inSession currentCall] hangup:HOPCallClosedReasonUser];
}

- (void) handleIncomingCall:(HOPCall*) call forSession:(Session*) inSession
{
    BOOL callFlagIsSet = [self setCallFlag:YES forSession:inSession];
    if (callFlagIsSet)
    {
        inSession.currentCall = call;
        
        [[[OpenPeer sharedOpenPeer] mainViewController] showIncominCallForSession:inSession];

        [call ring];
    }
}

- (BOOL) setCallFlag:(BOOL) activeCall forSession:(Session*) inSession
{
    BOOL ret = NO;
    @synchronized(self)
    {
        if (activeCall && self.sessionWithActiveCall == nil)
        {
            self.sessionWithActiveCall = inSession;
            ret = YES;
        }
        else if (!activeCall && self.sessionWithActiveCall)
        {
            self.sessionWithActiveCall = nil;
            ret = YES;
        }
    }
    return ret;
}

- (void) sendMessage:(NSString*) message forSession:(Session*) inSession
{
    HOPContact* contact = [[[inSession participantsArray] objectAtIndex:0] hopContact];
    HOPMessage* hopMessage = [[HOPMessage alloc] initWithMessageId:[Utility getGUIDstring] andMessage:message andContact:contact andMessageType:@"text" andMessageDate:[NSDate date]];
    [inSession.conversationThread sendMessage:hopMessage];
    [hopMessage release];
}

- (void) onMessageReceived:(HOPMessage*) message forSessionId:(NSString*) sessionId
{
    [[[OpenPeer sharedOpenPeer] mainViewController] showSessionViewControllerForSession:[self.sessionsDictionary objectForKey:sessionId]  forIncomingCall:NO];
    
    Contact* contact  = [[ContactsManager sharedContactsManager] getContactForIdentities:[message.contact getIdentities]];
    NSString* from = [NSString stringWithFormat:@"Message from %@",[contact fullName] ];
    UIAlertView* alertView = [[[UIAlertView alloc] initWithTitle:from
                                                         message:message.text
                                                        delegate:self
                                               cancelButtonTitle:@"Ok"
                                               otherButtonTitles:nil] autorelease];
    [alertView show];
}
@end
