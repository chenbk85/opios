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

@class HOPAccount;

@interface HOPContact : NSObject


/**
 Contact initialization method
 @param publicPeerFile NSString Public peer file of the contact that will be created (self or remote)
 @returns Ponter to the created contact object
 */
//+ (id) contactWithPeerFile:(NSString*) publicPeerFile userId:(NSString*) inUserId contactId:(NSString*) inContactId;

/**
 Contact init method used for creating HOPContact object when contact data (userId, contactId and peerFile) are stored locally
 @param publicPeerFile NSString Public peer file of the contact that will be created (self or remote). This is passed if peer file is sored locally. Otherwise it is nil
 @param inUserId user Id string stored locally (initialy is received for identity lookup). This argument is mandatory.
 @param inContactId contact Id string stored locally (initialy is received for identity lookup). This argument is mandatory.
 @returns Ponter to the created contact object
 */
- (id) initWithPeerFile:(NSString*) publicPeerFile previousStableUniqueID:(NSString*) previousStableUniqueID;

- (id) initFromPeerURI:(NSString*) peerURI findSecret:(NSString*) findSecret previousStableUniqueID:(NSString*) previousStableUniqueID;

+ (HOPContact*) getForSelf;
/**
 Check if contact object is self contact
 @returns YES if contact is self, NO if contact is remote
 */
- (BOOL) isSelf;

/**
 Retrieves peer URI from the contact object
 @returns NSString representation of peer URI
 */
- (NSString*) getPeerURI;

- (NSString*) getFindSecret;
- (NSString*) getStableUniqueID;


/**
 Check contact object has public peer file
 @returns YES if it has
 */
- (BOOL) hasPeerFilePublic;


- (NSString*) savePeerFilePublic;


- (HOPAccount*) getAssociatedAccount;

- (void) hintAboutLocation:(NSString*) contactsLocationID;
@end
