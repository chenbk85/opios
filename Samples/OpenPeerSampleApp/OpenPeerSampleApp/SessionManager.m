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
#import "MessageManager.h"
#import "ActiveSessionViewController.h"

#import "Utility.h"
#import "Contact.h"
#import "Session.h"
#import "OpenPeerUser.h"
#import "OpenPeer.h"
#import "Constants.h"

#import <OpenpeerSDK/HOPConversationThread.h>
#import <OpenpeerSDK/HOPContact.h>
#import <OpenpeerSDK/HOPMessage.h>
#import <OpenpeerSDK/HOPCall.h>
#import <OpenpeerSDK/HOPMediaEngine.h>

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
        self.sessionsDictionary = [[NSMutableDictionary alloc] init];
    }
    return self;
}


/**
 Creates a session for selected contacts
 @param contact Contact Contact for which session will be created.
*/
- (Session*)createSessionForContact:(Contact *)contact
{
    Session* ret = [self getSessionForContact:contact];
    
    if (!ret)
    {
        NSLog(@"Create session for contact");
        
        //Create user profile which will be passed to other partie.
        NSString* profileBundle = [[OpenPeerUser sharedOpenPeerUser] createProfileBundle];
        //Create a conversation thread
        HOPConversationThread* conversationThread = [HOPConversationThread conversationThreadWithProfileBundle:profileBundle];
        //Create a session with new conversation thread
        ret = [[Session alloc] initWithContact:contact conversationThread:conversationThread];
        
        //Add list of all participants. Currently only one participant is added
        if (ret && contact.hopContact && [contact.hopContact hasPeerFilePublic])
        {
            NSArray* participants = [NSArray arrayWithObject:contact.hopContact];
            [conversationThread addContacts:participants];
        }
        
        if (ret)
        {
            //Store session object in dictionary
            [self.sessionsDictionary setObject:ret forKey:[conversationThread getThreadId]];
        }
        
        return ret;
    }
    
    return ret;
}

/**
 Creates a incoming session.
 @param contacts NSArray List of participants.
 @param inConversationThread HOPConversationThread Incoming conversation thread
*/
- (Session*) createSessionForContacts:(NSArray*) contacts andConversationThread:(HOPConversationThread*) inConversationThread
{
    NSLog(@"Create session for contacts");
    Session* ret = [[Session alloc] initWithContacts:contacts conversationThread:inConversationThread];
    
    if (ret)
    {
        [self.sessionsDictionary setObject:ret forKey:[inConversationThread getThreadId]];
    }
    return ret;
}

/**
 Creates a new session initiate from other session.
 @param inSession Session is initiate of new session.
 @param userIds NSString list of userIds separated by comma which will take a part in new session. Currently group sessions are not supported, so userIds contains just one user id.
 */
- (Session*) createSessionInitiatedFromSession:(Session*) inSession forContactUserIds:(NSString*) userIds
{
    Session* session = nil;
    NSArray *strings = [userIds componentsSeparatedByString:@","];
    if ([strings count] > 0)
    {
        //If userId is valid string, find a contact with that user id
        NSString* userId = [strings objectAtIndex:0];
        if ([userId length] > 0)
        {
            Contact* contact = [[ContactsManager sharedContactsManager] getContactForID:userId];
            if (contact)
            {
                //Create a session for contact
                session = [self createSessionForContact:contact];
                if (session)
                {
                    //If session is created sucessfully, start a video call
                    [[[OpenPeer sharedOpenPeer] mainViewController] showSessionViewControllerForSession:session forIncomingCall:NO];
                    
                    [self makeCallForSession:session includeVideo:YES isRedial:NO];
                }
            }
        }
    }
    
    return session;
}

/**
 Creates a session that will initiate creation of other session between contacts passed in the list .
 @param participants NSArray* List of remote session participants.
 @return session with participant
 */
- (Session*) createRemoteSessionForContacts:(NSArray*) participants
{
    Session* sessionThatWillInitiateRemoteSession = nil;
    //Check if list has at least 2 contacts
    if ([participants count] > 1)
    {
        //First contact is master and he will be remote session host
        Contact* masterContact = [participants objectAtIndex:0];
        Contact* slaveContact = [participants objectAtIndex:1];
        
        //Create a session with the master contact, that will be used to send system message for creating a remote session
        sessionThatWillInitiateRemoteSession = [self createSessionForContact:masterContact];
        if (sessionThatWillInitiateRemoteSession)
        {
            //Send system message, where is passed the slave contacts. Session will be established between slave contacts and master contact.
            [[MessageManager sharedMessageManager] sendSystemMessageToInitSessionBetweenPeers:[NSArray arrayWithObject:slaveContact.hopContact] forSession:sessionThatWillInitiateRemoteSession];
        }
    }
    return sessionThatWillInitiateRemoteSession;
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

/**
 Make call for session.
 @param inSession Session session.
 @param includeVideo BOOL If YES make video call
 @param isRedial BOOL If trying to reestablish call that was ended because of network problems 
 */
- (void) makeCallForSession:(Session*) inSession includeVideo:(BOOL) includeVideo isRedial:(BOOL) isRedial
{
    if (!inSession.currentCall)
    {
        NSLog(@"Make call for sesison - making call");
        //Currently we are not supporting group conferences, so only one participant is possible
        HOPContact* contact = [[[inSession participantsArray] objectAtIndex:0] hopContact];
        //Place a audio or video call for chosen contact
        inSession.isRedial = isRedial;
        inSession.currentCall = [HOPCall placeCall:inSession.conversationThread toContact:contact includeAudio:YES includeVideo:includeVideo];
        [self setCallFlag:YES forSession:inSession];
    }
    else
    {
        NSLog(@"Make call for sesison - already made");
    }
}

/**
 Answer an incoming call
 @param inSession Session session.
 */
- (void) answerCallForSession:(Session*) inSession
{
    NSLog(@"Answer call for session");
    //Answer an incoming call
    [[inSession currentCall] answer];
}

/**
 End call
 @param inSession Session session.
 */
- (void) endCallForSession:(Session*) inSession
{
    NSLog(@"End call for sesison");
    //Hangup current active call
    [[inSession currentCall] hangup:HOPCallClosedReasonUser];
    //Set flag that there is no active call
    [self setCallFlag:NO forSession:inSession];
}

/**
 Handle incoming call.
 @param call HOPCall Incomin call
 @param inSession Session session.
 */
- (void) handleIncomingCall:(HOPCall*) call forSession:(Session*) inSession
{
    NSLog(@"Handle incoming call for sesison");
    
    //Set current call
    BOOL callFlagIsSet = [self setCallFlag:YES forSession:inSession];
    
    //If callFlagIsSet is YES, show incoming call view, and move call to ringing state
    if (callFlagIsSet)
    {
        inSession.currentCall = call;
        
        if (!inSession.isRedial)
        {
            [[[OpenPeer sharedOpenPeer] mainViewController] showIncominCallForSession:inSession];
            
            //TODO_S: Check is it necessary to ring, before answer
            [call ring];
        }
        else
            //if (inSession.isRedial)
            [call answer];
    }
    else //If callFlagIsSet is NO, hangup incoming call. 
    {
        [call hangup:HOPCallClosedReasonUser];
    }
}

/**
 Set session with active call.
 @param activeCall BOOL Flag if call is being active or it is ended
 @param inSession Session session.
 */
- (BOOL) setCallFlag:(BOOL) activeCall forSession:(Session*) inSession
{
    BOOL ret = NO;
    @synchronized(self)
    {
        if (activeCall && self.sessionWithActiveCall == nil)
        {
            //If there is no session with active call, set it
            self.sessionWithActiveCall = inSession;
            ret = YES;
        }
        else if (!activeCall && self.sessionWithActiveCall)
        {
            //If there is session with active call, set it to nil, because call is ended
            self.sessionWithActiveCall = nil;
            ret = YES;
        }
    }
    return ret;
}

/**
 Sends message for session.
 @param message NSString Message text
 @param inSession Session session.
 */
- (void) sendMessage:(NSString*) message forSession:(Session*) inSession
{
    NSLog(@"Send message");
    
    //Currently it is not available group chat, so we can have only one message recipients
    HOPContact* contact = [[[inSession participantsArray] objectAtIndex:0] hopContact];
    //Create a message object
    HOPMessage* hopMessage = [[HOPMessage alloc] initWithMessageId:[Utility getGUIDstring] andMessage:message andContact:contact andMessageType:messageTypeText andMessageDate:[NSDate date]];
    //Send message
    [inSession.conversationThread sendMessage:hopMessage];
}

/**
 Handles received message. For text message just display alert view, and for the system message perform appropriate action.
 @param message HOPMessage Message
 @param sessionId NSString Session id of session for which message is received.
 */
- (void) onMessageReceived:(HOPMessage*) message forSessionId:(NSString*) sessionId
{
    NSLog(@"Message received");
    
    if ([message.type isEqualToString:messageTypeText])
    {
        //If session view controller with message sender is not yet shown, show it
        [[[OpenPeer sharedOpenPeer] mainViewController] showSessionViewControllerForSession:[self.sessionsDictionary objectForKey:sessionId]  forIncomingCall:NO];
        //Get message sender
        Contact* contact  = [[ContactsManager sharedContactsManager] getContactForID:[message.contact getStableUniqueID]];
        NSString* from = [[NSString alloc] initWithFormat:@"Message from %@",[contact fullName]];
        UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:from
                                                            message:message.text
                                                           delegate:self
                                                  cancelButtonTitle:@"Ok"
                                                  otherButtonTitles:nil];
        [alertView show];
    }
    else
    {
        Session* session = [self.sessionsDictionary objectForKey:sessionId];
        if (session)
            [[MessageManager sharedMessageManager] parseSystemMessage:message forSession:session];
    }
}
/**
 Sends message for session.
 @param message HOPMessage Message
 @param sessionId NSString Session id.
 */
- (void) onAvailabilityCheckReceivedForSession:(Session*) inSession
{
    NSString* messageResponse = @"";
    if (self.sessionWithActiveCall)
    {
        if ([self.sessionWithActiveCall.participantsArray count] > 0)
            messageResponse = [[[self.sessionWithActiveCall.participantsArray objectAtIndex:0] hopContact] getStableUniqueID];
    }
    
    [[MessageManager sharedMessageManager] sendSystemMessageToCheckAvailabilityResponseForSession:inSession message:messageResponse];
}

/**
 Redials for session.
 @param inSession Session session with failed call which needs to be redialed.
 */
- (void) redialCallForSession:(Session*) inSession
{
    if (inSession == self.lastEndedCallSession )
    {
        //Check interval since last attempt, and if last call is ended 10 seconds ago, or earlier try to redial.
        NSTimeInterval timeInterval = [[inSession.currentCall getClosedTime] timeIntervalSinceDate:[NSDate date]];
        if (timeInterval < 10)
            [self makeCallForSession:inSession includeVideo:NO isRedial:YES];
    }
}

/**
 Handles ended call.
 @param inSession Session with call that is ended.
 */
- (void) onCallEnded:(Session*) inSession
{
    [self setLastEndedCallSession: inSession];
    //If it is callee side, check the reasons why call is ended, and if it is not ended properly, try to redial
    if (![[inSession.currentCall getCaller] isSelf] && ((OpenPeer*)[OpenPeer sharedOpenPeer]).isRedialModeOn)
    {
        if ([inSession.currentCall getClosedReason] == HOPCallClosedReasonNone || [inSession.currentCall getClosedReason] == HOPCallClosedReasonRequestTerminated || [inSession.currentCall getClosedReason] == HOPCallClosedReasonTemporarilyUnavailable)
        {
            [[MessageManager sharedMessageManager] sendSystemMessageToCallAgainForSession:inSession];
            inSession.isRedial = YES;
        }
        else
        {
            inSession.isRedial = NO;
        }
    }
    else
    {
        inSession.isRedial = NO;
    }
    
    inSession.currentCall = nil;
}

/**
 Handle face detected event
 */
- (void) onFaceDetected
{
    
}

- (void) startVideoRecording
{
    NSLog(@"Video recording stopped.");
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"dd-MM-yyyy-HH-mm"];
    
    NSString* filename = [NSString stringWithFormat:@"OpenPeer_%@.mp4",[formatter stringFromDate:[NSDate date]]];
    [[HOPMediaEngine sharedInstance] setRecordVideoOrientation:HOPMediaEngineVideoOrientationPortrait];
    //For saving video file in application boundle, provide file path an set saveToLibrary to NO. In case just file name is provided and saveToLibrary is set to YES, video file will be saved in ios media library
    [[HOPMediaEngine sharedInstance] startRecordVideoCapture:filename saveToLibrary:YES];
}
- (void) stopVideoRecording
{
    NSLog(@"Video recording stopped.");
    //Stop video recording
    [[HOPMediaEngine sharedInstance] stopRecordVideoCapture];
}

@end
