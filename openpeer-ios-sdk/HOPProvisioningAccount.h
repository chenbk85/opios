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
#import "HOPProtocols.h"




/*@interface IdentityInfo : NSObject

  @property (assign) HOPProvisioningAccountIdentityTypes mType;
  @property (retain) NSString* mUniqueID;
  
  @property (retain) NSString* mUniqueIDProof;                      // only set if known (will automatically be set)
  
  @property (assign) HOPProvisioningAccountIdentityValidationStates mValidationState;  // only set if known (i.e. being restored for relogin)
  @property (retain) NSString* mValidationID;                       // only set if known (i.e. being restored for relogin)
  
  @property (assign) unsigned short mPriority;
  @property (assign) unsigned short mWeight;
  
- (id)init;

- (BOOL) hasData;

@end*/

/*@interface LookupProfileInfo : NSObject
  
  @property (assign) HOPProvisioningAccountIdentityTypes mType;
  @property (retain) NSString* mIdentityUniqueID;

  @property (retain) NSString* mUserID;
  @property (retain) NSString* mContactID;

  @property (retain) NSDate* mLastProfileUpdateTimestamp;
  
  @property (assign) unsigned short mPriority;
  @property (assign) unsigned short mWeight;

  @property (retain) NSString* mAvatarURL;
  
- (id)init;

- (BOOL) hasData;

@end*/

@class HOPStack;
@class HOPProvisioningAccountDelegate;
@class HOPAccountDelegate;
@class HOPProvisioningAccountOAuthIdentityAssociation;
@class HOPProvisioningAccountOAuthIdentityAssociationDelegate;
@class HOPProvisioningAccountPush;
@class HOPAPNSDelegate;
@class HOPProvisioningAccountIdentityLookupQuery;
@class HOPProvisioningAccountIdentityLookupQueryDelegate;
@class HOPProvisioningAccountPeerFileLookupQuery;
@class HOPAccountPeerFileLookupQueryDelegate;
@class HOPIdentity;

@interface HOPProvisioningAccount : NSObject

/**
 Returns singleton object of this class.
 */
+ (id)sharedInstance;


#pragma mark Conversions to string
+ (NSString*) accountStatesToString:(HOPProvisioningAccountStates) state;
+ (NSString*) accountErrorCodesToString:(HOPProvisioningAccountErrorCodes) errorCode;
+ (NSString*) identityValidationStatesToString:(HOPProvisioningAccountIdentityValidationStates) state;
+ (NSString*) identityValidationResultCodeToString:(HOPProvisioningAccountIdentityValidationResultCode) resultCode;
+ (NSString*) identityTypesToString:(HOPProvisioningAccountIdentityTypes) type;

+ (BOOL) isTraditionalIdentity: (HOPProvisioningAccountIdentityTypes) type;
+ (BOOL) isSocialIdentity:  (HOPProvisioningAccountIdentityTypes) type;
+ (NSString*) toCodeString:  (HOPProvisioningAccountIdentityTypes) type;
+ (HOPProvisioningAccountIdentityTypes) toIdentity: (NSString*) identityStr;
+ (HOPProvisioningAccountIdentityValidationStates) toValidationState: (NSString*) validationState;

- (BOOL) firstTimeLogin: (HOPStack*) stack provisioningAccountDelegate: (id<HOPProvisioningAccountDelegate>) provisioningAccountDelegate openpeerAccountDelegate: (id<HOPAccountDelegate>) openpeerAccountDelegate provisioningURI: (NSString*) provisioningURI deviceToken: (NSString*) deviceToken name: (NSString*) name knownIdentities: (NSArray*) knownIdentities;

- (BOOL) firstTimeOAuthLogin: (HOPStack*) stack provisioningAccountDelegate: (id<HOPProvisioningAccountDelegate>) provisioningAccountDelegate openpeerAccountDelegate: (id<HOPAccountDelegate>) openpeerAccountDelegate provisioningURI: (NSString*) provisioningURI deviceToken: (NSString*) deviceToken oauthIdentityType: (HOPProvisioningAccountIdentityTypes) oauthIdentityType;

- (BOOL) relogin: (HOPStack*) stack provisioningAccountDelegate: (id<HOPProvisioningAccountDelegate>) provisioningAccountDelegate openpeerAccountDelegate: (id<HOPAccountDelegate>) openpeerAccountDelegate provisioningURI: (NSString*) provisioningURI deviceToken: (NSString*) deviceToken userID: (NSString*) userID accountSalt: (NSString*) accountSalt passwordNonce: (NSString*) passwordNonce password: (NSString*) password privatePeerFile: (NSString*) privatePeerFile lastProfileUpdatedTimestamp: (NSDate*) lastProfileUpdatedTimestamp previousIdentities: (NSArray*) previousIdentities;

- (void) shutdown;

- (HOPIdentity*) getAuthorizationPINIdentity;

- (void) setAuthorizationPIN: (NSString*) authorizationPIN;

- (NSString*) getOAuthURL;

- (void) completeOAuthLoginProcess: (NSString*) xmlResultFromJavascript;

#pragma mark Getters
- (NSString*) getUserID;
- (NSString*) getAccountSalt;
- (NSString*) getPasswordNonce;
- (NSString*) getPassword;
- (NSString*) getPrivatePeerFile;
- (NSDate*) getLastProfileUpdatedTime;

- (HOPAccount*) getOpenPeerAccount;

- (HOPProvisioningAccountStates) getState;

- (HOPProvisioningAccountErrorCodes) getLastError;

- (NSArray*) getIdentities;
- (void) setIdentities: (NSArray*) identities;

- (HOPProvisioningAccountIdentityValidationStates) getIdentityValidationState: (HOPIdentity*) identity;

- (void) validateIdentitySendPIN: (HOPIdentity*) identity;

- (void) validateIdentityComplete: (HOPIdentity*) identity identityPIN: (NSString*) identityPIN;

#pragma mark Helper classes

- (HOPProvisioningAccountOAuthIdentityAssociation*) associateOAuthIdentity :(HOPProvisioningAccountIdentityTypes) type delegate: (HOPProvisioningAccountOAuthIdentityAssociationDelegate*) delegate;

- (HOPProvisioningAccountPush*) apnsPush: (id<HOPAPNSDelegate>) delegate userIDs: (NSArray*) userIDs messageType: (NSString*) messageType message: (NSString*) message;

- (HOPProvisioningAccountIdentityLookupQuery*) identityLookup: (id<HOPProvisioningAccountIdentityLookupQueryDelegate>) delegate identities: (NSArray*) identities;

- (HOPProvisioningAccountPeerFileLookupQuery*) peerFileLookup: (id<HOPProvisioningAccountPeerFileLookupQueryDelegate>) delegate userIDs: (NSArray*) userIDs associatedContactIDs: (NSArray*) associatedContactIDs;

@end
