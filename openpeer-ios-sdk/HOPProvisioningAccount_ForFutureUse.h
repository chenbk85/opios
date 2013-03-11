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
//#import <hookflash/provisioning/hookflashTypes.h>
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
  
  @property (retain) NSMutableArray* avatars; // List of OpenpeerIdentityProfileAvatarInfo*

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

/**
 Returns singleton object of this class.
 */
+ (id)sharedInstance;

/**
 Converts account state enum to string.
 @param state HOPProvisioningAccountStates Account state enum
 @returns String representation of account state
 */
+ (NSString*) stateToString: (OpenpeerProvisioning_AccountStates) state;

/**
 Converts account error code enum to string.
 @param errorCode HOPProvisioningAccountErrorCodes Account error code enum
 @returns String representation of account error code
 */
+ (NSString*) errorCodeToString: (OpenpeerProvisioning_AccountErrorCodes) errorCode;

/**
 Construct a provisioning account object and optionally login to the peer contact service if the private peer file information is already known in advance.
 @param stack HOPStack Stack object pointer
 @param provisioningAccountDelegate HOPProvisioningAccountDelegate Pointer to the protocol implementation class for provisioning account. All events from provisioning account will be handled within this class.
 @param openpeerAccountDelegate HOPAccountDelegate Pointer to the protocol implementation class for openpeer account. All events from openpeer account will be handled within this class.
 @param peerContactServiceBootstrappedDomain NSString Domain of the identity provider.
 @param privatePeerFileSecret NSString Private peer file secret.
 @param privatePeerFileEl NSString Private peer file.
 @returns YES if success, NO for failure
 */
- (BOOL) create: (HOPStack*) stack provisioningAccountDelegate: (id<HOPOpenpeerProvisioningAccountDelegate>) provisioningAccountDelegate openpeerAccountDelegate: (id<HOPAccountDelegate>) openpeerAccountDelegate peerContactServiceBootstrappedDomain: (NSString*) peerContactServiceBootstrappedDomain privatePeerFileSecret: (NSString*) privatePeerFileSecret privatePeerFileEl: (NSString*) privatePeerFileEl;

/**
 Login to an existing identity or add a new identity to the identity list associated to the peer contact.
 @param delegate OpenpeerProvisioning_IdentityLoginSessionDelegate Pointer to the protocol implementation class for identity login session
 @param identityBaseURI NSString Base or full identity URI.
 @param identityProvider NSString Identity provider.
 @returns Identity login session pointer
 */
- (OpenpeerProvisioning_IdentityLoginSession*) identityLogin: (id<OpenpeerProvisioning_IdentityLoginSessionDelegate>) delegate identityBaseURI: (NSString*) identityBaseURI identityProvider: (NSString*) identityProvider;

/**
 Shutdown of the provisioning account.
 */
- (void) shutdown;

/**
 Retrieves identities of the current user.
 @retun Array of identities.
 */
- (NSArray*) getKnownIdentities; //List of OpenpeerIdentity objects

/**
 Sets identities of the current user.
 @param identities NSArray Array of identities.
 */
- (void) setKnownIdentities: (NSArray*) identities; //List of OpenpeerIdentity objects

/**
 Retrieves private peer file secret.
 @return String representation of private peer file secret.
 */
- (NSString*) getPrivatePeerFileSecret;

/**
 Retrieves private peer file.
 @return String representation of private peer file.
 */
- (NSString*) exportPrivatePeerFile;

/**
 Creation of identity lookup subclass and initiating identity lookup process.
 @param delegate OpenpeerProvisioning_AccountIdentityLookupQueryDelegate Delegate for receiving identity lookup response.
 @param identities NSArray List of identities for which identity lookup procedure will be called.
 @return Identity lookup subclass pointer.
 */
- (OpenpeerProvisioning_AccountIdentityLookupQuery*) identityLookup: (id<OpenpeerProvisioning_AccountIdentityLookupQueryDelegate>) delegate identities: (NSArray*) identities; // List of NSString objects

/**
 Creation of peer file lookup subclass and initiating peer file lookup process.
 @param delegate OpenpeerProvisioning_AccountPeerFileLookupQueryDelegate Delegate for receiving peer file lookup response.
 @param peerContacts NSArray List of peer contacts for which peer file lookup procedure will be called.
 @return Peer file lookup subclass pointer.
 */
- (OpenpeerProvisioning_AccountPeerFileLookupQuery*) peerFileLookup: (id<OpenpeerProvisioning_AccountPeerFileLookupQueryDelegate>) delegate peerContacts: (NSArray*) peerContacts;

@end


@interface OpenpeerProvisioning_IdentityLoginSession : NSObject

/**
 Retrieves identity base.
 @return String representation of identity base.
 */
- (NSString*) getIdentityBase;

/**
 Retrieves identity provider.
 @return String representation of identity provider
 */
- (NSString*) getIdentityProvider;

/**
 Retrieves identity URI.
 @return String representation of identity URI.
 */
- (NSString*) getIdentityURI;

/**
 Retrieves client token.
 @return String representation of server token.
 */
- (NSString*) getClientToken;

/**
 Retrieves server token.
 @return String representation of server token.
 */
- (NSString*) getServerToken;

/**
 Retrieves client login secret.
 @return String representation of client login secret.
 */
- (NSString*) getClientLoginSecret;

/**
 Checks if login session is complete.
 @return YES if session is completed, NO if not.
 */
- (BOOL) isComplete;

/**
 Checks if login session is complete.
 @return YES if session was successful, NO if not.
 */
- (BOOL) wasSuccessful;

/**
 Retrieves session error code.
 @return Session error code.
 */
- (unsigned int) getErrorCode;

/**
 Retrieves hidden window browser URL.
 @return String representation of hidden window browser URL.
 */
- (NSString*) getHiddenWindowBrowserURL;

/**
 Retrieves login expires timestamp.
 @return Timestamp of login expiry.
 */
- (NSDate*) getLoginExpires;

/**
 Retrieves identity relogin token.
 @return String representation of identity relogin token.
 */
- (NSString*) getIdentityReloginToken;

/**
 Retrieves custom login element.
 @return String representation of custom login element.
 */
- (NSString*) getCustomLoginElement;

/**
 Cancel login session.
 */
- (void) cancel;

/**
 Complete login session.
 */
- (void) complete;

@end

#pragma mark - OpenpeerProvisioning_IdentityLoginSession_internal.h

#import <hookflash/core/types.h>

@interface OpenpeerProvisioning_IdentityLoginSession ()
{
    hookflash::provisioning2::IIdentityLoginSessionPtr identityLoginSessionPtr;
    //hookflash::IAccountPtr openpeerAccountPtr;
    
    //boost::shared_ptr<OpenPeerProvisioningAccountDelegate_ForFutureUse> openpeerProvisioningAccountDelegatePtr;
    //boost::shared_ptr<OpenPeerAccountDelegate> openpeerAccountDelegatePtr;
    //std::list<boost::shared_ptr<OpenPeerProvisioningAccountDelegate> > listOfOpenPeerAccountDelegates;
}
//
//- (BOOL) createLocalDelegates:(id<HOPOpenpeerProvisioningAccountDelegate>) provisioningAccountDelegate;
//- (void) deleteLocalDelegates;
- (id) initWithIdentityLoginSession:(hookflash::provisioning2::IIdentityLoginSessionPtr) inIdentityLoginSessionPtr;
- (hookflash::provisioning2::IIdentityLoginSessionPtr) getIdentityLoginSessionPtr;

@end

#pragma mark - OpenpeerProvisioning_AccountPeerFileLookupQuery declaration
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
 @return List of identities
 */
- (NSArray*) getIdentities;

/**
 Retrieve lookup contacts.
 @return  NSArray of HOPContact objects
 */
- (NSArray*) getContacts;

/**
 Perform lookup for provided identity.
 @param inIdentity HOPIdentity Identity for lookup
 @param outInfo HOPLookupProfileInfo 
 @return Lookup result.
 */
- (OpenpeerIdentityLookupInfo*) getLookupInfo: (NSString*) inIdentity;

@end

#pragma mark - OpenpeerProvisioning_AccountIdentityLookupQuery_internal.h
@interface OpenpeerProvisioning_AccountIdentityLookupQuery ()
{
    hookflash::provisioning2::IAccountIdentityLookupQueryPtr accountIdentityLookupQueryPtr;
}
@property (nonatomic,copy) NSNumber* uniqueId;
@property (nonatomic,retain) NSMutableArray* identities;
@property (nonatomic,retain) NSMutableArray* contacts;

- (void) setAccountIdentityLookupQueryPtr:(hookflash::provisioning2::IAccountIdentityLookupQueryPtr) inAccountIdentityLookupQueryPtr;
- (hookflash::provisioning2::IAccountIdentityLookupQueryPtr) getAccountIdentityLookupQueryPtr;

@end

#pragma mark - OpenpeerProvisioning_AccountPeerFileLookupQuery declaration
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
 @return List of retrieved user IDs
 */
- (NSArray*) getPeerContactURIs; // return ist of NSString

/**
 Retrieves public peer file.
 @param userID NSString User ID of the profile to retrieve
 @return Public peer file as string
 */
- (NSString*) getPublicPeerFileAsString: (NSString*) userID;

@end

#pragma mark - OpenpeerProvisioning_AccountPeerFileLookupQuery_internal.h
@interface OpenpeerProvisioning_AccountPeerFileLookupQuery ()
{
    hookflash::provisioning2::IAccountPeerFileLookupQueryPtr accountPeerFileLookupQueryPtr;
}

@property (copy) NSNumber* uniqueId;

- (void) setAccountPeerFileLookupQueryPtr:(hookflash::provisioning2::IAccountPeerFileLookupQueryPtr) inAccountPeerFileLookupQueryPtr;
- (hookflash::provisioning2::IAccountPeerFileLookupQueryPtr) getAccountPeerFileLookupQueryPtr;
@end

#pragma mark - HOPProvisioningAccount_ForFutureUse_internal.h

#import <hookflash/provisioning2/hookflashTypes.h>
#import "OpenPeerProvisioningAccountDelegate.h"

class OpenPeerProvisioningAccountDelegate_ForFutureUse;

//Internal class - should be moved to separate file
@interface HOPProvisioningAccount_ForFutureUse ()
{
    hookflash::provisioning2::IAccountPtr provisioningAccountPtr;
    //hookflash::IAccountPtr openpeerAccountPtr;
    
    boost::shared_ptr<OpenPeerProvisioningAccountDelegate_ForFutureUse> openpeerProvisioningAccountDelegatePtr;
    //boost::shared_ptr<OpenPeerAccountDelegate> openpeerAccountDelegatePtr;
    //std::list<boost::shared_ptr<OpenPeerProvisioningAccountDelegate> > listOfOpenPeerAccountDelegates;
}

- (id) initSingleton;

@property (retain) NSMutableDictionary* dictionaryOfIdentityLookupQueries;
@property (retain) NSMutableDictionary* dictionaryOfPeerFilesLookupQueries;

- (BOOL) createLocalDelegates:(id<HOPOpenpeerProvisioningAccountDelegate>) provisioningAccountDelegate;
- (void) deleteLocalDelegates;


- (OpenpeerProvisioning_AccountIdentityLookupQuery*) getProvisioningAccountIdentityLookupQueryForUniqueId:(NSNumber*) uniqueId;
- (OpenpeerProvisioning_AccountPeerFileLookupQuery*) getProvisioningAccountPeerFileLookupQueryForUniqueId:(NSNumber*) uniqueId;

@end

#pragma mark - OpenPeerProvisioningAccountDelegate_ForFutureUse.h

#import <hookflash/provisioning2/IAccount.h>

class OpenPeerProvisioningAccountDelegate_ForFutureUse : public provisioning2::IAccountDelegate, public hookflash::IAccountDelegate
{
protected:
    id<HOPOpenpeerProvisioningAccountDelegate> provisioningAccountDelegate;
    //id<HOPAccountDelegate> openpeerAccountDelegate;
    
    OpenPeerProvisioningAccountDelegate_ForFutureUse(id<HOPOpenpeerProvisioningAccountDelegate> inProvisioningAccountDelegate);
    
    HOPProvisioningAccount_ForFutureUse* getOpenPeerProvisioningAccount(provisioning2::IAccountPtr account);
public:
    static boost::shared_ptr<OpenPeerProvisioningAccountDelegate_ForFutureUse> create(id<HOPOpenpeerProvisioningAccountDelegate> inProvisioningAccountDelegate);
    
//#pragma mark - provisioning2::IAccount delegate methods
    
    virtual void onProvisioningAccountStateChanged(provisioning2::IAccountPtr account,provisioning2::IAccount::AccountStates state);
    
    virtual void onProvisioningAccountError(provisioning2::IAccountPtr account,provisioning2::IAccount::AccountErrorCodes error);
    
    virtual void onProvisioningAccountPrivatePeerFileChanged(provisioning2::IAccountPtr account);
    
    virtual void onProvisioningAccountIdentitiesChanged(provisioning2::IAccountPtr account);
    
//#pragma mark - hookflash::IAccount delegate methods
    
    virtual void onAccountStateChanged(hookflash::IAccountPtr account, hookflash::IAccount::AccountStates state);

};

#pragma mark - OpenPeerAccountIdentityLookupQueryDelegate_ForFutureUse.h
class OpenPeerAccountIdentityLookupQueryDelegate_ForFutureUse : public provisioning2::IAccountIdentityLookupQueryDelegate
{
protected:
    id<OpenpeerProvisioning_AccountIdentityLookupQueryDelegate> accountIdentityLookupQueryDelegate;
    
    OpenPeerAccountIdentityLookupQueryDelegate_ForFutureUse(id<OpenpeerProvisioning_AccountIdentityLookupQueryDelegate> inAccountIdentityLookupQueryDelegate);
    
//    OpenpeerProvisioning_AccountIdentityLookupQuery* getOpenPeerAccountIdentityLookupQuery(provisioning2::IAccountIdentityLookupQueryPtr accountIdentityLookupQuery);
public:
    static boost::shared_ptr<OpenPeerAccountIdentityLookupQueryDelegate_ForFutureUse> create(id<OpenpeerProvisioning_AccountIdentityLookupQueryDelegate> inAccountIdentityLookupQueryDelegate);
    
    virtual void onAccountIdentityLookupQueryComplete(provisioning2::IAccountIdentityLookupQueryPtr query);
    
};

#pragma mark - OpenPeerAccountPeerFileLookupQueryDelegate_ForFutureUse.h
class OpenPeerAccountPeerFileLookupQueryDelegate_ForFutureUse : public provisioning2::IAccountPeerFileLookupQueryDelegate
{
protected:
    id<OpenpeerProvisioning_AccountPeerFileLookupQueryDelegate> accountPeerFileLookupQueryDelegate;
    
    OpenPeerAccountPeerFileLookupQueryDelegate_ForFutureUse(id<OpenpeerProvisioning_AccountPeerFileLookupQueryDelegate> inAccountPeerFileLookupQueryDelegate);
    
    OpenpeerProvisioning_AccountPeerFileLookupQuery* getOpenPeerAccountPeerFileLookupQuery(provisioning2::IAccountPeerFileLookupQueryPtr accountPeerFileLookupQuery);
public:
    static boost::shared_ptr<OpenPeerAccountPeerFileLookupQueryDelegate_ForFutureUse> create(id<OpenpeerProvisioning_AccountPeerFileLookupQueryDelegate> inAccountPeerFileLookupQueryDelegate);
    
    virtual void onAccountPeerFileLookupQueryComplete(provisioning2::IAccountPeerFileLookupQueryPtr query);
    
};

#pragma mark - OpenPeerIdentityLoginSessionDelegate_ForFutureUse.h
class OpenPeerIdentityLoginSessionDelegate_ForFutureUse : public provisioning2::IIdentityLoginSessionDelegate
{
protected:
    id<OpenpeerProvisioning_IdentityLoginSessionDelegate> identityLoginSessionDelegate;
    
    OpenPeerIdentityLoginSessionDelegate_ForFutureUse(id<OpenpeerProvisioning_IdentityLoginSessionDelegate> inIdentityLoginSessionDelegate);
    
    //    OpenpeerProvisioning_AccountIdentityLookupQuery* getOpenPeerAccountIdentityLookupQuery(provisioning2::IAccountIdentityLookupQueryPtr accountIdentityLookupQuery);
public:
    static boost::shared_ptr<OpenPeerIdentityLoginSessionDelegate_ForFutureUse> create(id<OpenpeerProvisioning_IdentityLoginSessionDelegate> inIdentityLoginSessionDelegate);
    
    virtual void onIdentityLoginSessionBrowserWindowRequired(provisioning2::IIdentityLoginSessionPtr session);
    
    virtual void onIdentityLoginSessionCompleted(provisioning2::IIdentityLoginSessionPtr session);
    
};
/*

 */
