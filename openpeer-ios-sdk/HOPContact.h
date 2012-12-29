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
- (id) initWithPeerFile:(NSString*) publicPeerFile userId:(NSString*) inUserId contactId:(NSString*) inContactId;


/**
 Retrieves contact ID from the contact object
 @returns NSString representation of contact ID
 */
- (NSString*) getContactID;

/**
 Return user ID 
 @returns NSString representation of user ID
 */
- (NSString*) getUserID;

/**
 Check if contact object is self contact
 @returns YES if contact is self, NO if contact is remote
 */
- (BOOL) isSelf;

/**
 Retrieves contact type
 @returns Contact type enum
 */
- (HOPContactTypes) getContactType;

/**
 Check if contact is editable
 @returns YES if contact is editable, NO if isn't
 */
- (BOOL) isEditable;

/**
 Check if public XML is editable
 @returns YES if public XML is editable, NO if isn't
 */
- (BOOL) isPublicXMLEditable;

/**
 Retrieves public XML for the contact object
 @returns NSString representation of public XML
 */
- (NSString*) getPublicXML;

/**
 Retrieves private XML for the contact object
 @returns NSString representation of private XML
 */
- (NSString*) getPrivateXML;

/**
 Updates contact profile with provided information
 @param publicXML NSString Pointer to the information in public XML
 @param privateXML NSString Pointer to the information in public XML
 @returns YES if update succeed, NO if it fails
 */
- (BOOL) updateProfile:(NSString*) publicXML privateXML:(NSString*) privateXML;

/**
 Retrieves contact profile version
 @returns Contact profile version number
 */
- (unsigned long) getProfileVersion;


/**
 Retrieves contact peer file
 @returns Contact peer file
 */
- (NSString*) getPeerFile;

/**
 Retrieves associated identities for contact
 @returns List of contact associated identities
 */
- (NSArray*) getIdentities;
@end
