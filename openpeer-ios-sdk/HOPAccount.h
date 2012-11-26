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

#import <Foundation/Foundation.h>

#import "HOPTypes.h"
#import "HOPProtocols.h"

/**
 Forward declarations
 */
@class HOPAccountSubscription;
@class HOPContact;
@class HOPConversationThread;

/**
  Class to represent the openpeer account.
 */
@interface HOPAccount : NSObject

/**
 Converts State enum to string
 @param state OpenPeer_AccountStates enum
 @returns NSString representation of enum
 */
+ (NSString*) stateToString:(HOPAccountStates) state;

/**
 Converts Error enum to string
 @param errorCode OpenPeer_AccountErrors enum
 @returns NSString representation of enum
 */
+ (NSString*) errorToString:(HOPAccountErrors) errorCode;

/**
 Shutdown of the openpeer account.
 */
- (void) shutdown;

/**
 Retrieves current openpeer account state
 @returns OpenPeer_AccountStates current state of the openpeer account
 */
- (HOPAccountStates) getState;

/**
 Retrieves last openpeer account error
 @returns OpenPeer_AccountStates current state of the openpeer account
 */
- (HOPAccountErrors) getLastError;

//*********************** FIX ADD DELEGATE As INPUT PARAMETER
- (HOPAccountSubscription*) subscribe: (id<HOPAccountDelegate>) delegate;

/**
 Retrieves self contact
 @returns HOPContact contact object for self
 */
- (HOPContact*) getSelfContact;

/**
 Retrieves openpeer account location ID
 @returns NSString representation of openpeer account location ID
 */
- (NSString*) getLocationID;

/**
 Saves private peer file.
 @returns NSString private peer xml file
 */
- (NSString*) privatePeerToString;

/**
 Saves public peer file.
 @returns HOPXml public peer xml file
 */
- (NSString*) publicPeerToString;

/**
 Subscribe to the notification of specific contact.
 @param contact HOPContact contact to receive notifications about
 */
- (void) notifyAboutContact:(HOPContact*) contact;

/**
 Hint about contact location.
 @param contact HOPContact contact to receive notifications about
 @param locationID NSString location id
 */
- (void) hintAboutContactLocation:(HOPContact*) contact locationID:(NSString*) locationID;

/**
 Retrieves conversation thread object based on ts ID.
 @param threadID NSString conversation thread ID
 */
- (HOPConversationThread*) getConversationThreadByID:(NSString*) threadID;

/**
 Retrieves all conversation threads
 @param outConversationThreads std::list<HOPConversationThread> list of conversation threads
 */
- (NSArray*) getConversationThreads;

@end
