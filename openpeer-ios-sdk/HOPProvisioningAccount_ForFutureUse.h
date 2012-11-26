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
#import <hookflash/provisioning/hookflashTypes.h>
#import "HOPProtocols.h"

enum OpenpeerProvisioning_AccountStates
{
  AccountState_Pending,
  AccountState_Ready,
  AccountState_ShuttingDown,
  AccountState_Shutdown
};

enum OpenpeerProvisioning_AccountErrorCodes
{
  AccountErrorCode_None,
  AccountErrorCode_ServerCommunicationError,
  AccountErrorCode_InternalFailure,
  
  AccountErrorCode_TBD,
};

@interface OpenpeerIdentityProfileAvatarInfo :NSObject

  @property (copy) NSString* avatarName;
  @property (copy) NSString* avatarURL;
  @property (assign) unsigned int pixelWidth;
  @property (assign) unsigned int pixelHeight;

@end

@interface OpenpeerIdentity : NSObject

  @property (copy) NSString* identityURI;
  @property (copy) NSString* identityProvider;
  
  @property (assign) unsigned short priority;
  @property (assign) unsigned short weight;

@end

@interface OpenpeerIdentityLookupInfo : OpenpeerIdentity

  @property (copy) NSString* peerContactURI;
  @property (copy) NSString* publicPeerFileSecret;
  @property (retain) NSDate* infoTTL;
  
  @property (retain) NSDate* profileLastUpdated;
  @property (copy) NSString* displayName;
  @property (copy) NSString* profileRenderedURL;     // the profile as renderable in a browser window
  @property (copy) NSString* profileProgrammaticURL; // the profile as readable by a computer
  
  @property (retain) NSArray* avatars; // List of OpenpeerIdentityProfileAvatarInfo*

@end

@class HOPStack;
@class HOPOpenpeerProvisioningAccountDelegate;
@class HOPAccountDelegate;
@class OpenpeerProvisioning_IdentityLoginSession;
@class OpenpeerProvisioning_IdentityLoginSessionDelegate;
@class OpenpeerProvisioning_AccountIdentityLookupQuery;
@class OpenpeerProvisioning_AccountIdentityLookupQueryDelegate;
@class OpenpeerProvisioning_AccountPeerFileLookupQuery;
@class OpenpeerProvisioning_AccountPeerFileLookupQueryDelegate;
@class HOPProvisioningAccount_ForFutureUse;

@protocol HOPOpenpeerProvisioningAccountDelegate <NSObject>

- (void) onProvisioningAccountStateChanged:(HOPProvisioningAccount_ForFutureUse*) account accountStates:(OpenpeerProvisioning_AccountStates) state;

- (void) onProvisioningAccountError:(HOPProvisioningAccount_ForFutureUse*) account errorCodes:(OpenpeerProvisioning_AccountErrorCodes) error;

- (void) onProvisioningAccountPrivatePeerFileChanged:(HOPProvisioningAccount_ForFutureUse*) account;

- (void) onProvisioningAccountIdentitiesChanged:(HOPProvisioningAccount_ForFutureUse*) account;

@end

@protocol OpenpeerProvisioning_IdentityLoginSessionDelegate <NSObject>

- (void) onIdentityLoginSessionBrowserWindowRequired:(OpenpeerProvisioning_IdentityLoginSession*) session;

- (void) onIdentityLoginSessionCompleted:(OpenpeerProvisioning_IdentityLoginSession*) session;

@end

@protocol OpenpeerProvisioning_AccountIdentityLookupQueryDelegate <NSObject>
@required
- (void) onAccountIdentityLookupQueryComplete:(OpenpeerProvisioning_AccountIdentityLookupQuery*) query;

@end

@protocol OpenpeerProvisioning_AccountPeerFileLookupQueryDelegate <NSObject>
@required
- (void) onAccountPeerFileLookupQueryComplete:(OpenpeerProvisioning_AccountPeerFileLookupQuery*) query;

@end

@interface HOPProvisioningAccount_ForFutureUse : NSObject

+ (NSString*) stateToString: (OpenpeerProvisioning_AccountStates) state;

+ (NSString*) errorCodeToString: (OpenpeerProvisioning_AccountErrorCodes) errorCode;

+ (BOOL) create: (HOPStack*) stack provisioningAccountDelegate: (id<HOPOpenpeerProvisioningAccountDelegate>) provisioningAccountDelegate openpeerAccountDelegate: (id<HOPAccountDelegate>) openpeerAccountDelegate peerContactServiceBootstrappedDomain: (NSString*) peerContactServiceBootstrappedDomain privatePeerFileSecret: (NSString*) privatePeerFileSecret privatePeerFileEl: (NSString*) privatePeerFileEl;

- (OpenpeerProvisioning_IdentityLoginSession*) identityLogin: (id<OpenpeerProvisioning_IdentityLoginSessionDelegate>) delegate identityBaseURI: (NSString*) identityBaseURI identityProvider: (NSString*) identityProvider;

- (void) shutdown;

- (void) getKnownIdentities: (NSArray*) outIdentities; //List of OpenpeerIdentity objects

- (void) setKnownIdentities: (NSArray*) identities; //List of OpenpeerIdentity objects

- (NSString*) getPrivatePeerFileSecret;

- (NSString*) exportPrivatePeerFile;

- (OpenpeerProvisioning_AccountIdentityLookupQuery*) identityLookup: (id<OpenpeerProvisioning_AccountIdentityLookupQueryDelegate>) delegate identities: (NSArray*) identities; // List of NSString objects

- (OpenpeerProvisioning_AccountPeerFileLookupQuery*) peerFileLookup: (id<OpenpeerProvisioning_AccountPeerFileLookupQueryDelegate>) delegate peerContacts: (NSArray*) peerContacts;

@end


@interface OpenpeerProvisioning_IdentityLoginSession : NSObject

- (NSString*) getIdentityBase;

- (NSString*) getIdentityProvider;

- (NSString*) getIdentityURI;

- (NSString*) getClientToken;

- (NSString*) getServerToken;

- (NSString*) getClientLoginSecret;

- (BOOL) isComplete;

- (BOOL) wasSuccessful;

- (unsigned int) getErrorCode;

- (NSString*) getHiddenWindowBrowserURL;

- (NSDate*) getLoginExpires;

- (NSString*) getIdentityReloginToken;

- (NSString*) getCustomLoginElement;

- (void) cancel;

- (void) complete;

@end

@interface OpenpeerProvisioning_AccountIdentityLookupQuery : NSObject

/**
 Check if identity lookup query is completed.
 @return YES if completed, NO if not
 */
- (BOOL) isComplete;

/**
 Check if identity lookup query was successful.
 @return YES if succeeded, NO if not
 */
- (BOOL) didSucceed;

/**
 Cancel the identity lookup query.
 */
- (void) cancel;

/**
 Retrieve lookup identities.
 @param outIdentites NSArray List of identities
 */
- (void) getIdentities: (NSArray*) outIdentities;

/**
 Perform lookup for provided identity.
 @param inIdentity HOPIdentity Identity for lookup
 @param outInfo HOPLookupProfileInfo Lookup result
 @return YES for lookup success, NO for failure
 */
- (BOOL) getLookupInfo: (NSString*) inIdentity outInfo: (OpenpeerIdentityLookupInfo*) outInfo;

@end

@interface OpenpeerProvisioning_AccountPeerFileLookupQuery : NSObject

/**
 Check if peer file lookup query is completed.
 @return YES if completed, NO if not
 */
- (BOOL) isComplete;

/**
 Check if peer file lookup query was successful.
 @return YES if succeeded, NO if not
 */
- (BOOL) didSucceed;

/**
 Cancel the peer file lookup query.
 */
- (void) cancel;

/**
 Retrieve contact URIs from peer file.
 @param outUserIDs NSArray List of retrieved user IDs
 */
- (void) getPeerContactURIs: (NSArray*) outPeerContactURIs; // List of NSString

/**
 Retrieves public peer file.
 @param userID NSString User ID of the profile to retrieve
 @return Public peer file as string
 */
- (NSString*) getPublicPeerFileAsString: (NSString*) userID;

@end

/*

 */
