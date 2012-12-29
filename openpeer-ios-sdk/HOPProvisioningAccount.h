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

@class HOPStack;
@class HOPProvisioningAccountDelegate;
@class HOPProvisioningAccountOAuthIdentityAssociation;
@class HOPProvisioningAccountOAuthIdentityAssociationDelegate;
@class HOPProvisioningAccountPush;
@class HOPAPNSDelegate;
@class HOPProvisioningAccountIdentityLookupQuery;
@class HOPProvisioningAccountIdentityLookupQueryDelegate;
@class HOPProvisioningAccountPeerFileLookupQuery;
@class HOPAccountPeerFileLookupQueryDelegate;
@class HOPIdentity;
@class HOPAccountSubscription;

@interface HOPProvisioningAccount : NSObject

/**
 Returns singleton object of this class.
 */
+ (id)sharedProvisioningAccount;


#pragma mark Conversions to string

/**
 Converts account state enum to string.
 @param state HOPProvisioningAccountStates Account state enum
 @returns String representation of account state
 */
+ (NSString*) accountStatesToString:(HOPProvisioningAccountStates) state;

/**
 Converts account error code enum to string.
 @param errorCode HOPProvisioningAccountErrorCodes Account error code enum
 @returns String representation of account error code
 */
+ (NSString*) accountErrorCodesToString:(HOPProvisioningAccountErrorCodes) errorCode;

/**
 Converts identity validation state enum to string.
 @param state HOPProvisioningAccountIdentityValidationStates Identity validation state enum
 @returns String representation of identity validation state
 */
+ (NSString*) identityValidationStatesToString:(HOPProvisioningAccountIdentityValidationStates) state;

/**
 Converts identity validation result code enum to string.
 @param state HOPProvisioningAccountIdentityValidationResultCode Identity validation result code enum
 @returns String representation of identity validation result code
 */
+ (NSString*) identityValidationResultCodeToString:(HOPProvisioningAccountIdentityValidationResultCode) resultCode;

/**
 Converts identity type enum to string.
 @param state HOPProvisioningAccountIdentityTypes Identity type enum
 @returns String representation of identity type
 */
+ (NSString*) identityTypesToString:(HOPProvisioningAccountIdentityTypes) type;

#pragma mark Helper methods
/**
 Checks if identity type is traditional identity.
 @param type HOPProvisioningAccountIdentityTypes Identity type enum
 @returns YES if traditional identity, NO if not
 */
+ (BOOL) isTraditionalIdentity: (HOPProvisioningAccountIdentityTypes) type;

/**
 Checks if identity type is social identity.
 @param type HOPProvisioningAccountIdentityTypes Identity type enum
 @returns YES if social identity, NO if not
 */
+ (BOOL) isSocialIdentity:  (HOPProvisioningAccountIdentityTypes) type;

/**
 Converts identity type enum to code string.
 @param type HOPProvisioningAccountIdentityTypes Identity type enum
 @returns Code string representation of identity type
 */
+ (NSString*) toCodeString:  (HOPProvisioningAccountIdentityTypes) type;

/**
 Converts string to identity type enum.
 @param identityStr NSString Identity type string
 @returns Identity type enum
 */
+ (HOPProvisioningAccountIdentityTypes) toIdentity: (NSString*) identityStr;

/**
 Converts string to validation state enum.
 @param validationState NSString Validation state string
 @returns Validation state enum
 */
+ (HOPProvisioningAccountIdentityValidationStates) toValidationState: (NSString*) validationState;

#pragma mark Provisioning Account creation methods

/**
 Creation of account. This procedure should be called in case there is no private peer file stored on device, and the user is logging in using email or phone number identity.
 @param stack HOPStack Stack object pointer
 @param provisioningAccountDelegate HOPProvisioningAccountDelegate Pointer to the protocol implementation class for provisioning account. All events from provisioning account will be handled within this class.
 @param openpeerAccountDelegate HOPAccountDelegate Pointer to the protocol implementation class for openpeer account. All events from openpeer account will be handled within this class.
 @param provisioningURI NSString URI of the provisioning server
 @param deviceToken NSString Device token
 @param name NSString User name
 @param knownIdentities NSArray Known identities of the current user. In case there is no known identities, array should be empty.
 @returns HOPProvisioningAccount object if provisioning account is created sucessfully
 */
//+ (id) provisioningAccountForFirstTimeLogin: (HOPStack*) stack provisioningAccountDelegate: (id<HOPProvisioningAccountDelegate>) provisioningAccountDelegate openpeerAccountDelegate: (id<HOPAccountDelegate>) openpeerAccountDelegate provisioningURI: (NSString*) provisioningURI deviceToken: (NSString*) deviceToken name: (NSString*) name knownIdentities: (NSArray*) knownIdentities;
- (BOOL) firstTimeLogin: (HOPStack*) stack provisioningAccountDelegate: (id<HOPProvisioningAccountDelegate>) provisioningAccountDelegate openpeerAccountDelegate: (id<HOPAccountDelegate>) openpeerAccountDelegate provisioningURI: (NSString*) provisioningURI deviceToken: (NSString*) deviceToken name: (NSString*) name knownIdentities: (NSArray*) knownIdentities;

/**
 Creation of account. This procedure should be called in case there is no private peer file stored on device, and the user is logging in using social network identity (Facebook, LinkedIn...).
 @param stack HOPStack Stack object pointer
 @param provisioningAccountDelegate HOPProvisioningAccountDelegate Pointer to the protocol implementation class for provisioning account. All events from provisioning account will be handled within this class.
 @param openpeerAccountDelegate HOPAccountDelegate Pointer to the protocol implementation class for openpeer account. All events from openpeer account will be handled within this class.
 @param provisioningURI NSString URI of the provisioning server
 @param deviceToken NSString Device token
 @param oauthIdentityType HOPProvisioningAccountIdentityTypes Type of identity for OAuth login
 @returns HOPProvisioningAccount object if provisioning account is created sucessfully
 */
//+ (id) provisioningAccountForFirstOAuthLogin: (HOPStack*) stack provisioningAccountDelegate: (id<HOPProvisioningAccountDelegate>) provisioningAccountDelegate openpeerAccountDelegate: (id<HOPAccountDelegate>) openpeerAccountDelegate provisioningURI: (NSString*) provisioningURI deviceToken: (NSString*) deviceToken oauthIdentityType: (HOPProvisioningAccountIdentityTypes) oauthIdentityType;
- (BOOL) firstTimeOAuthLoginWithProvisioningAccountDelegate: (id<HOPProvisioningAccountDelegate>) provisioningAccountDelegate provisioningURI: (NSString*) provisioningURI deviceToken: (NSString*) deviceToken oauthIdentityType: (HOPProvisioningAccountIdentityTypes) oauthIdentityType;

/**
 Creation of account. This procedure should be called in case there is private peer file stored on device, in case for both social or traditional identity type. User ID, account salt, password nonce, password and private peer file must be read from device DB and set as parameter for this method.
 @param stack HOPStack Stack object pointer
 @param provisioningAccountDelegate HOPProvisioningAccountDelegate Pointer to the protocol implementation class for provisioning account. All events from provisioning account will be handled within this class.
 @param openpeerAccountDelegate HOPAccountDelegate Pointer to the protocol implementation class for openpeer account. All events from openpeer account will be handled within this class.
 @param provisioningURI NSString URI of the provisioning server
 @param deviceToken NSString Device token
 @param userID NSString User ID (read from DB)
 @param accountSalt NSString Account salt (read from DB)
 @param passwordNonce NSString Password nonce (read from DB)
 @param password NSString Private peer file password (read from DB)
 @param privatePeerFile NSString Private peer file (read from DB)
 @param lastProfileUpdatedTimestamp NSDate Timestamp of the last profile update
 @param previousIdentities NSArray Previous identities of the current user. There should be at least one previous identity for relogin method.
 @returns HOPProvisioningAccount object if provisioning account is created sucessfully
 */
//+ (id) provisioningAccountForRelogin: (HOPStack*) stack provisioningAccountDelegate: (id<HOPProvisioningAccountDelegate>) provisioningAccountDelegate openpeerAccountDelegate: (id<HOPAccountDelegate>) openpeerAccountDelegate provisioningURI: (NSString*) provisioningURI deviceToken: (NSString*) deviceToken userID: (NSString*) userID accountSalt: (NSString*) accountSalt passwordNonce: (NSString*) passwordNonce password: (NSString*) password privatePeerFile: (NSString*) privatePeerFile lastProfileUpdatedTimestamp: (NSDate*) lastProfileUpdatedTimestamp previousIdentities: (NSArray*) previousIdentities;
- (BOOL) reloginWithProvisioningAccountDelegate: (id<HOPProvisioningAccountDelegate>) provisioningAccountDelegate provisioningURI: (NSString*) provisioningURI deviceToken: (NSString*) deviceToken userID: (NSString*) userID accountSalt: (NSString*) accountSalt passwordNonce: (NSString*) passwordNonce password: (NSString*) password privatePeerFile: (NSString*) privatePeerFile lastProfileUpdatedTimestamp: (NSTimeInterval) lastProfileUpdatedTimestamp previousIdentities: (NSArray*) previousIdentities;

/**
 Shutdown of the provisioning account.
 */
- (void) shutdown;

/**
 Retrieves PIN authorization identity.
 @returns authorization PIN identity
 */
- (HOPIdentity*) getAuthorizationPINIdentity;

/**
 Sets PIN authorization identity.
 @param authorizationPIN NSString Authorization PIN
 */
- (void) setAuthorizationPIN: (NSString*) authorizationPIN;

/**
 Retrieves URL for OAuth login.
 @returns String representation of OAuth URL.
 */
- (NSString*) getOAuthURL;

/**
 This method must be called to finalize first time login and first time OAuth login scenarios. After receiving login procedure result inside web view via redirect URL, special XML (defined in Open Peer Specification) must be formed and forwarded to the core as parameter of this method. This XML contains STUN and TURN server addresses and credentials.
 @param xmlResultFromJavascript NSString XML of the login information
 */
- (void) completeOAuthLoginProcess: (NSString*) xmlResultFromJavascript;

#pragma mark Getters

/**
 Retrieves user ID.
 @returns String representation of user ID.
 */
- (NSString*) getUserID;

/**
 Retrieves contact id of logged user ID.
 @returns String representation of contact ID.
 */
- (NSString*) getContactID;

/**
 Retrieves account salt.
 @returns String representation of account salt.
 */
- (NSString*) getAccountSalt;

/**
 Retrieves password nonce.
 @returns String representation of password nonce.
 */
- (NSString*) getPasswordNonce;

/**
 Retrieves private peer file password.
 @returns String representation of private peer file password.
 */
- (NSString*) getPassword;

/**
 Retrieves private peer file.
 @returns String representation of private peer file.
 */
- (NSString*) getPrivatePeerFile;

/**
 Retrieves last profile update timestamp.
 @returns last profile update timestamp.
 */
- (NSTimeInterval) getLastProfileUpdatedTime;

/**
 Retrieves open peer account.
 @returns Pointer to the open peer account.
 */
//- (HOPProvisioningAccount*) getProvisioningAccount;

/**
 Retrieves provisioning account state.
 @returns Account state enum.
 */
- (HOPProvisioningAccountStates) getState;

/**
 Retrieves account error code.
 @returns Account error code enum.
 */
- (HOPProvisioningAccountErrorCodes) getLastError;

#pragma mark Identity handling

/**
 Retrieves identities of the current user.
 @returns Array of identities.
 */
- (NSArray*) getIdentities;

/**
 Sets identities for the current user.
 @param Array of identities.
 */
- (void) setIdentities: (NSArray*) identities;

/**
 Retrieves identity validation state of the provided identity.
 @param identity HOPIdentity Identity to retrieve validation state for.
 @returns Validation state enum of the provided identity.
 */
- (HOPProvisioningAccountIdentityValidationStates) getIdentityValidationState: (HOPIdentity*) identity;

/**
 Send request for PIN for provided identity.
 @param identity HOPIdentity Identity which is requiring PIN.
 */
- (void) validateIdentitySendPIN: (HOPIdentity*) identity;

/**
 Validating PIN for the provided identity.
 @param identity HOPIdentity Identity which is validationg PIN.
 @param identityPIN NSString PIN code of the provided identity
 */
- (void) validateIdentityComplete: (HOPIdentity*) identity identityPIN: (NSString*) identityPIN;

#pragma mark Provisioning subclasses integration

/**
 Creation of identity associaton subclass and initiating association process.
 @param type HOPProvisioningAccountIdentityTypes Identity type that will be associated to the current identity.
 @param delegate HOPProvisioningAccountOAuthIdentityAssociationDelegate Delegate for receiving association response
 @return Identity association subclass pointer.
 */
- (HOPProvisioningAccountOAuthIdentityAssociation*) associateOAuthIdentity :(HOPProvisioningAccountIdentityTypes) type delegate: (id<HOPProvisioningAccountOAuthIdentityAssociationDelegate>) delegate;

/**
 Creation of APNS push subclass and initiating APNS push message sending.
 @param delegate HOPAPNSDelegate Delegate for receiving APNS events.
 @param userIDs NSArray List of users that should receive APNS message.
 @param messageType NSString DType of APNS message.
 @param message NSString MEssage that should be sent using APNS.
 @return APNS push subclass pointer.
 */
- (HOPProvisioningAccountPush*) apnsPush: (id<HOPAPNSDelegate>) delegate userIDs: (NSArray*) userIDs messageType: (NSString*) messageType message: (NSString*) message;

/**
 Creation of identity lookup subclass and initiating identity lookup process.
 @param delegate HOPProvisioningAccountIdentityLookupQueryDelegate Delegate for receiving identity lookup response.
 @param identities NSArray List of identities for which identity lookup procedure will be called.
 @return Identity lookup subclass pointer.
 */
- (HOPProvisioningAccountIdentityLookupQuery*) identityLookup: (id<HOPProvisioningAccountIdentityLookupQueryDelegate>) delegate identities: (NSArray*) identities;

/**
 Creation of peer file lookup subclass and initiating peer file lookup process.
 @param delegate HOPProvisioningAccountPeerFileLookupQueryDelegate Delegate for receiving peer file lookup response.
 @param userIDs NSArray List of users for which peer file lookup procedure will be called.
 @param associatedContactIDs NSArray List of associated contact IDs.
 @return Peer file lookup subclass pointer.
 */
- (HOPProvisioningAccountPeerFileLookupQuery*) peerFileLookup: (id<HOPProvisioningAccountPeerFileLookupQueryDelegate>) delegate contacts:(NSArray*) contacts;

#pragma mark - HOPAccount methods
/**
 Converts State enum to string
 @param state OpenPeer_AccountStates enum
 @returns NSString representation of enum
 */
//+ (NSString*) stateToString:(HOPAccountStates) state;

/**
 Converts Error enum to string
 @param errorCode HOPProvisioningAccountErrorCodes enum
 @returns NSString representation of enum
 */
//+ (NSString*) errorToString:(HOPProvisioningAccountErrorCodes) errorCode;

/**
 Retrieves current openpeer account state
 @returns OpenPeer_AccountStates current state of the openpeer account
 */
///- (HOPAccountStates) getState;

/**
 Retrieves last openpeer account error
 @returns OpenPeer_AccountStates current state of the openpeer account
 */
//- (HOPAccountErrors) getLastError;


- (HOPAccountSubscription*) subscribe: (id<HOPProvisioningAccountDelegate>) delegate;

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
