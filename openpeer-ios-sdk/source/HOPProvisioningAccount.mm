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


#import <hookflash/core/IAccount.h>
//#import <hookflash/IAccount.h>
#import <hookflash/core/IHelper.h>
#include <zsLib/Helpers.h>

//#import "HOPProvisioningAccountOAuthIdentityAssociation_Internal.h"
//#import "OpenPeerProvisioningAccountOAuthIdentityAssociationDelegate.h"
//#import "HOPProvisioningAccountPeerFileLookupQuery_Internal.h"
//#import "HOPProvisioningAccountIdentityLookupQuery_Internal.h"
//#import "OpenPeerAccountIdentityLookupQueryDelegate.h"
//#import "OpenPeerAccountPeerFileLookupQueryDelegate.h"
//#import "OpenPeerAPNSDelegate.h"
//#import "HOPProvisioningAccountPush.h"
//#import "HOPProvisioningAccountPush_Internal.h"
#import "HOPProvisioningAccount_Internal.h"
#import "HOPProvisioningAccount.h"
#import "HOPStack_Internal.h"
#import "HOPIdentityInfo.h"
#import "HOPIdentity.h"
#import "HOPProtocols.h"
#import "HOPProvisioningAccountOAuthIdentityAssociation.h"
#import "OpenPeerUtility.h"
#import "OpenPeerStorageManager.h"
#import "HOPContact_Internal.h"
#import "HOPAccountSubscription.h"
#import "HOPAccountSubscription_Internal.h"

@implementation HOPProvisioningAccount


+ (id)sharedProvisioningAccount
{
    static dispatch_once_t pred = 0;
    __strong static id _sharedObject = nil;
    dispatch_once(&pred, ^{
        _sharedObject = [[self alloc] initSingleton]; // or some other init method
    });
    return _sharedObject;
}

- (id) initSingleton
{
    self = [super init];
    if (self)
    {
        self.dictionaryOfIdentityLookupQueries = [[[NSMutableDictionary alloc] init] autorelease];
        self.dictionaryOfPeerFilesLookupQueries = [[[NSMutableDictionary alloc] init] autorelease];
        self.listOfProvisioningAccountDelegates = [[[NSMutableArray alloc] init] autorelease];
    }
    return self;
}
#pragma mark - Conversions

+ (NSString*) accountStatesToString:(HOPProvisioningAccountStates) state
{
    return [NSString stringWithUTF8String: hookflash::provisioning::IAccount::toString((hookflash::provisioning::IAccount::AccountStates) state)];
}

+ (NSString*) accountErrorCodesToString:(HOPProvisioningAccountErrorCodes) errorCode
{
    return [NSString stringWithUTF8String: hookflash::provisioning::IAccount::toString((hookflash::provisioning::IAccount::AccountErrorCodes) errorCode)];
}

+ (NSString*) identityValidationStatesToString:(HOPProvisioningAccountIdentityValidationStates) state
{
    return [NSString stringWithUTF8String: hookflash::provisioning::IAccount::toString((hookflash::provisioning::IAccount::IdentityValidationStates) state)];
}

+ (NSString*) identityValidationResultCodeToString:(HOPProvisioningAccountIdentityValidationResultCode) resultCode
{
    return [NSString stringWithUTF8String: hookflash::provisioning::IAccount::toString((hookflash::provisioning::IAccount::IdentityValidationResultCode) resultCode)];
}

+ (NSString*) identityTypesToString:(HOPProvisioningAccountIdentityTypes) type
{
    return [NSString stringWithUTF8String: hookflash::provisioning::IAccount::toString((hookflash::provisioning::IAccount::IdentityTypes) type)];
}

+ (BOOL) isTraditionalIdentity: (HOPProvisioningAccountIdentityTypes) type
{
    return hookflash::provisioning::IAccount::isTraditionalIdentity((hookflash::provisioning::IAccount::IdentityTypes) type);
}

+ (BOOL) isSocialIdentity:  (HOPProvisioningAccountIdentityTypes) type
{
    return hookflash::provisioning::IAccount::isSocialIdentity((hookflash::provisioning::IAccount::IdentityTypes) type);
}

+ (NSString*) toCodeString: (HOPProvisioningAccountIdentityTypes) type
{
    return [NSString stringWithUTF8String: hookflash::provisioning::IAccount::toCodeString((hookflash::provisioning::IAccount::IdentityTypes) type)];
}

+ (HOPProvisioningAccountIdentityTypes) toIdentity: (NSString*) identityStr
{
    return (HOPProvisioningAccountIdentityTypes) hookflash::provisioning::IAccount::toIdentity([identityStr UTF8String]);
}

+ (HOPProvisioningAccountIdentityValidationStates) toValidationState: (NSString*) validationState
{
    return (HOPProvisioningAccountIdentityValidationStates) hookflash::provisioning::IAccount::toValidationState([validationState UTF8String]);
}

#pragma mark private constructors
/*- (id) initWithAccountPtr:(provisioning::IAccountPtr) inAccountPtr provisioningAccountDelegate:(boost::shared_ptr<OpenPeerProvisioningAccountDelegate>) inProvisioningAccountDelegate accountDelegate:(boost::shared_ptr<OpenPeerAccountDelegate>) inAccountDelegate
{
    self = [super init];
    
    if (self)
    {
        provisioningAccountPtr = inAccountPtr;
        openpeerProvisioningAccountDelegatePtr = inProvisioningAccountDelegate;
        openpeerAccountDelegatePtr = inAccountDelegate;
    }
    
    return self;
}

- (id)init
{
    [self release];
    [NSException raise:NSInvalidArgumentException format:@"Don't use init for object creation. Use class methods provisioningAccountForFirstTimeLogin, provisioningAccountForFirstOAuthLogin or provisioningAccountForRelogin"];
    return nil;
}*/

#pragma mark Login methods
/*+ (id) provisioningAccountForFirstTimeLogin: (HOPStack*) stack provisioningAccountDelegate: (id<HOPProvisioningAccountDelegate>) provisioningAccountDelegate openpeerAccountDelegate: (id<HOPAccountDelegate>) openpeerAccountDelegate provisioningURI: (NSString*) provisioningURI deviceToken: (NSString*) deviceToken name: (NSString*) name knownIdentities: (NSArray*) knownIdentities
{
    HOPProvisioningAccount* ret = nil;
    
    if (!stack || !provisioningAccountDelegate || !openpeerAccountDelegate)
        return ret;
    
    if ( ([provisioningURI length] == 0 ) || ([deviceToken length] == 0 ) || ([name length] == 0 ) || ([knownIdentities count] == 0) )
        return ret;
    
    boost::shared_ptr<OpenPeerProvisioningAccountDelegate> tempOpenpeerProvisioningAccountDelegatePtr = OpenPeerProvisioningAccountDelegate::create(provisioningAccountDelegate);
    if (!tempOpenpeerProvisioningAccountDelegatePtr)
        return ret;
    
    boost::shared_ptr<OpenPeerAccountDelegate> tempOpenpeerAccountDelegatePtr = OpenPeerAccountDelegate::create(openpeerAccountDelegate);
    if (!tempOpenpeerAccountDelegatePtr)
        return ret;
    
    provisioning::IAccount::IdentityInfoList identities;
    for (HOPIdentityInfo* identity in knownIdentities)
    {
        provisioning::IAccount::IdentityInfo info;
        info.mType = (provisioning::IAccount::IdentityTypes) identity.type;
        if (identity.uniqueId)
            info.mUniqueID = [identity.uniqueId UTF8String];
        if (identity.uniqueIDProof)
            info.mUniqueIDProof = [identity.uniqueIDProof UTF8String];
        info.mValidationState = (provisioning::IAccount::IdentityValidationStates) identity.validationState;
        if (identity.validationId)
            info.mValidationID = [identity.validationId UTF8String];
        info.mPriority = identity.priority;
        info.mWeight = identity.weight;
        
        identities.push_back(info);
    }
    
    provisioning::IAccountPtr tempAccountPtr = provisioning::IAccount::firstTimeLogin([stack getStackPtr], tempOpenpeerProvisioningAccountDelegatePtr, tempOpenpeerAccountDelegatePtr, [provisioningURI UTF8String], [deviceToken UTF8String], [name UTF8String], identities);
    
    if (tempAccountPtr)
    {
        ret = [[self alloc] initWithAccountPtr:tempAccountPtr provisioningAccountDelegate:tempOpenpeerProvisioningAccountDelegatePtr accountDelegate:tempOpenpeerAccountDelegatePtr];
    }
    
    return [ret autorelease];
}

+ (id) provisioningAccountForFirstOAuthLogin: (HOPStack*) stack provisioningAccountDelegate: (id<HOPProvisioningAccountDelegate>) provisioningAccountDelegate openpeerAccountDelegate: (id<HOPAccountDelegate>) openpeerAccountDelegate provisioningURI: (NSString*) provisioningURI deviceToken: (NSString*) deviceToken oauthIdentityType: (HOPProvisioningAccountIdentityTypes) oauthIdentityType
{
    HOPProvisioningAccount* ret = nil;
    
    if (!stack || !provisioningAccountDelegate || !openpeerAccountDelegate)
        return ret;
    
    if ( ([provisioningURI length] == 0 ) || ([deviceToken length] == 0 ) )
        return ret;
    
    boost::shared_ptr<OpenPeerProvisioningAccountDelegate> tempOpenpeerProvisioningAccountDelegatePtr = OpenPeerProvisioningAccountDelegate::create(provisioningAccountDelegate);
    if (!tempOpenpeerProvisioningAccountDelegatePtr)
        return ret;
    
    boost::shared_ptr<OpenPeerAccountDelegate> tempOpenpeerAccountDelegatePtr = OpenPeerAccountDelegate::create(openpeerAccountDelegate);
    if (!tempOpenpeerAccountDelegatePtr)
        return ret;
    
    provisioning::IAccountPtr tempAccountPtr = provisioning::IAccount::firstTimeOAuthLogin([stack getStackPtr], tempOpenpeerProvisioningAccountDelegatePtr, tempOpenpeerAccountDelegatePtr, [provisioningURI UTF8String], [deviceToken UTF8String], (hookflash::provisioning::IAccount::IdentityTypes) oauthIdentityType);
    
    if (tempAccountPtr)
    {
        ret = [[self alloc] initWithAccountPtr:tempAccountPtr provisioningAccountDelegate:tempOpenpeerProvisioningAccountDelegatePtr accountDelegate:tempOpenpeerAccountDelegatePtr];
    }
    
    return [ret autorelease];
}

+ (id) provisioningAccountForRelogin: (HOPStack*) stack provisioningAccountDelegate: (id<HOPProvisioningAccountDelegate>) provisioningAccountDelegate openpeerAccountDelegate: (id<HOPAccountDelegate>) openpeerAccountDelegate provisioningURI: (NSString*) provisioningURI deviceToken: (NSString*) deviceToken userID: (NSString*) userID accountSalt: (NSString*) accountSalt passwordNonce: (NSString*) passwordNonce password: (NSString*) password privatePeerFile: (NSString*) privatePeerFile lastProfileUpdatedTimestamp: (NSDate*) lastProfileUpdatedTimestamp previousIdentities: (NSArray*) previousIdentities
{
    HOPProvisioningAccount* ret = nil;
    
    if (!stack || !provisioningAccountDelegate || !openpeerAccountDelegate)
        return ret;
    
    if ( ([provisioningURI length] == 0 ) || ([deviceToken length] == 0 ) || ([userID length] == 0 ) || ([accountSalt length] == 0 ) || ([passwordNonce length] == 0 ) || ([password length] == 0 ) || ([privatePeerFile length] == 0 ) || ([previousIdentities count] == 0))
        return ret;
    
    boost::shared_ptr<OpenPeerProvisioningAccountDelegate> tempOpenpeerProvisioningAccountDelegatePtr = OpenPeerProvisioningAccountDelegate::create(provisioningAccountDelegate);
    if (!tempOpenpeerProvisioningAccountDelegatePtr)
        return ret;
    
    boost::shared_ptr<OpenPeerAccountDelegate> tempOpenpeerAccountDelegatePtr = OpenPeerAccountDelegate::create(openpeerAccountDelegate);
    if (!tempOpenpeerAccountDelegatePtr)
        return ret;
    
    provisioning::IAccount::IdentityInfoList identities;
    for (HOPIdentityInfo* identity in previousIdentities)
    {
        provisioning::IAccount::IdentityInfo info;
        info.mType = (provisioning::IAccount::IdentityTypes) identity.type;
        if (identity.uniqueId)
            info.mUniqueID = [identity.uniqueId UTF8String];
        if (identity.uniqueIDProof)
            info.mUniqueIDProof = [identity.uniqueIDProof UTF8String];
        info.mValidationState = (provisioning::IAccount::IdentityValidationStates) identity.validationState;
        if (identity.validationId)
            info.mValidationID = [identity.validationId UTF8String];
        info.mPriority = identity.priority;
        info.mWeight = identity.weight;
        
        identities.push_back(info);
    }
    
    zsLib::Time lastProfileUpdateTimestampTemp = boost::posix_time::from_time_t([lastProfileUpdatedTimestamp timeIntervalSince1970]) ;
    
    provisioning::IAccountPtr tempAccountPtr = provisioning::IAccount::relogin([stack getStackPtr], tempOpenpeerProvisioningAccountDelegatePtr, tempOpenpeerAccountDelegatePtr, [provisioningURI UTF8String], [deviceToken UTF8String], [userID UTF8String], [accountSalt UTF8String], [passwordNonce UTF8String], [password UTF8String], IXML::createFromString([privatePeerFile UTF8String]), lastProfileUpdateTimestampTemp, identities);
    
    if (tempAccountPtr)
    {
        ret = [[self alloc] initWithAccountPtr:tempAccountPtr provisioningAccountDelegate:tempOpenpeerProvisioningAccountDelegatePtr accountDelegate:tempOpenpeerAccountDelegatePtr];
    }
    
    return [ret autorelease];
}
*/
- (BOOL) firstTimeLogin: (HOPStack*) stack provisioningAccountDelegate: (id<HOPProvisioningAccountDelegate>) provisioningAccountDelegate openpeerAccountDelegate: (id<HOPAccountDelegate>) openpeerAccountDelegate provisioningURI: (NSString*) provisioningURI deviceToken: (NSString*) deviceToken name: (NSString*) name knownIdentities: (NSArray*) knownIdentities
{
    BOOL passedWithoutErrors = NO;
    
    @synchronized(self)
    {
        if (!stack || !provisioningAccountDelegate || !openpeerAccountDelegate)
            return passedWithoutErrors;
        
        if ( ([provisioningURI length] == 0 ) || ([deviceToken length] == 0 ) || ([name length] == 0 ) || ([knownIdentities count] == 0) )
            return passedWithoutErrors;
        
        if (provisioningAccountPtr)
            provisioningAccountPtr->shutdown();
        
        BOOL delegatesCreated = [self createLocalDelegates:provisioningAccountDelegate];
        
        if (delegatesCreated)
        {
            provisioning::IAccount::IdentityInfoList identities;
            for (HOPIdentityInfo* identity in knownIdentities)
            {
                provisioning::IAccount::IdentityInfo info;
                info.mType = (provisioning::IAccount::IdentityTypes) identity.type;
                if (identity.uniqueId)
                    info.mUniqueID = [identity.uniqueId UTF8String];
                if (identity.uniqueIDProof)
                    info.mUniqueIDProof = [identity.uniqueIDProof UTF8String];
                info.mValidationState = (provisioning::IAccount::IdentityValidationStates) identity.validationState;
                if (identity.validationId)
                    info.mValidationID = [identity.validationId UTF8String];
                info.mPriority = identity.priority;
                info.mWeight = identity.weight;
                
                identities.push_back(info);
            }
            
            provisioningAccountPtr = provisioning::IAccount::firstTimeLogin([stack getStackPtr], openpeerProvisioningAccountDelegatePtr, openpeerProvisioningAccountDelegatePtr, [provisioningURI UTF8String], [deviceToken UTF8String], [name UTF8String], identities);
            
            if (provisioningAccountPtr)
                passedWithoutErrors = YES;
        }
    }
    
    return passedWithoutErrors;
}

- (BOOL) firstTimeOAuthLoginWithProvisioningAccountDelegate: (id<HOPProvisioningAccountDelegate>) provisioningAccountDelegate provisioningURI: (NSString*) provisioningURI deviceToken: (NSString*) deviceToken oauthIdentityType: (HOPProvisioningAccountIdentityTypes) oauthIdentityType
{
    BOOL passedWithoutErrors = NO;
    
    @synchronized(self)
    {
        if (!provisioningAccountDelegate)
            return passedWithoutErrors;
        
        if ( ([provisioningURI length] == 0 ) || deviceToken == nil )
            return passedWithoutErrors;
        
        if (provisioningAccountPtr)
            provisioningAccountPtr->shutdown();
        
        BOOL delegatesCreated = [self createLocalDelegates:provisioningAccountDelegate];
        
        if (delegatesCreated)
        {
            
            provisioningAccountPtr = provisioning::IAccount::firstTimeOAuthLogin([[HOPStack sharedStack] getStackPtr], openpeerProvisioningAccountDelegatePtr, openpeerProvisioningAccountDelegatePtr, [provisioningURI UTF8String], [deviceToken UTF8String], (hookflash::provisioning::IAccount::IdentityTypes) oauthIdentityType);
            
            if (provisioningAccountPtr)
                passedWithoutErrors = YES;
        }
    }
    
    return passedWithoutErrors;
}

- (BOOL) reloginWithProvisioningAccountDelegate: (id<HOPProvisioningAccountDelegate>) provisioningAccountDelegate provisioningURI: (NSString*) provisioningURI deviceToken: (NSString*) deviceToken userID: (NSString*) userID accountSalt: (NSString*) accountSalt passwordNonce: (NSString*) passwordNonce password: (NSString*) password privatePeerFile: (NSString*) privatePeerFile lastProfileUpdatedTimestamp: (NSTimeInterval) lastProfileUpdatedTimestamp previousIdentities: (NSArray*) previousIdentities
{
    BOOL passedWithoutErrors = NO;
    
    @synchronized(self)
    {
        if (!provisioningAccountDelegate)
            return passedWithoutErrors;
      
        if ( ([provisioningURI length] == 0 ) || ([userID length] == 0 ) || ([accountSalt length] == 0 ) || ([passwordNonce length] == 0 ) || ([password length] == 0 ) || ([privatePeerFile length] == 0 ) || ([previousIdentities count] == 0))
            return passedWithoutErrors;
        
        if (provisioningAccountPtr)
            provisioningAccountPtr->shutdown();
        
        BOOL delegatesCreated = [self createLocalDelegates:provisioningAccountDelegate];
        
        if (delegatesCreated)
        {
            provisioning::IAccount::IdentityInfoList identities;
            for (HOPIdentityInfo* identity in previousIdentities)
            {
                provisioning::IAccount::IdentityInfo info;
                info.mType = (provisioning::IAccount::IdentityTypes) identity.type;
                if (identity.uniqueId)
                    info.mUniqueID = [identity.uniqueId UTF8String];
                if (identity.uniqueIDProof)
                    info.mUniqueIDProof = [identity.uniqueIDProof UTF8String];
                info.mValidationState = (provisioning::IAccount::IdentityValidationStates) identity.validationState;
                if (identity.validationId)
                    info.mValidationID = [identity.validationId UTF8String];
                info.mPriority = identity.priority;
                info.mWeight = identity.weight;
                
                identities.push_back(info);
            }
            
            //zsLib::Time lastProfileUpdateTimestampTemp = boost::posix_time::from_time_t([lastProfileUpdatedTimestamp timeIntervalSince1970]) ;
            zsLib::Time lastProfileUpdateTimestampTemp = boost::posix_time::from_time_t(lastProfileUpdatedTimestamp) ;
            
            provisioningAccountPtr = provisioning::IAccount::relogin([[HOPStack sharedStack] getStackPtr], openpeerProvisioningAccountDelegatePtr, openpeerProvisioningAccountDelegatePtr, [provisioningURI UTF8String], [deviceToken UTF8String], [userID UTF8String], [accountSalt UTF8String], [passwordNonce UTF8String], [password UTF8String], IXML::createFromString([privatePeerFile UTF8String]), lastProfileUpdateTimestampTemp, identities);
            
            if (provisioningAccountPtr)
                passedWithoutErrors = YES;
        }
    }
    
    return passedWithoutErrors;
}

- (HOPIdentity*) getAuthorizationPINIdentity
{
    HOPIdentity* ret = nil;
    if(provisioningAccountPtr)
    {
        std::pair<hookflash::provisioning::IAccount::IdentityTypes, const char*> coreIdentity = provisioningAccountPtr->getAuthorizationPINIdentity();

        ret.identityType = (HOPProvisioningAccountIdentityTypes) coreIdentity.first;
        ret.identityId = [NSString stringWithUTF8String: coreIdentity.second];
    }
    else
    {
        [NSException raise:NSInvalidArgumentException format:@"Invalid provisioning account pointer!"];
    }
    
    return ret;
}

- (void) setAuthorizationPIN: (NSString*) authorizationPIN
{
    if(provisioningAccountPtr)
    {
        if (authorizationPIN)
            provisioningAccountPtr->setAuthorizationPIN([authorizationPIN UTF8String]);
    }
    else
    {
        [NSException raise:NSInvalidArgumentException format:@"Invalid provisioning account pointer!"];
    }
}

- (NSString*) getOAuthURL
{
    NSString* ret = nil;
  
    if(provisioningAccountPtr)
    {
        ret = [NSString stringWithUTF8String: provisioningAccountPtr->getOAuthLoginURL()];
    }
    else
    {
        [NSException raise:NSInvalidArgumentException format:@"Invalid provisioning account pointer!"];
    }
    return ret;
}

- (void) completeOAuthLoginProcess: (NSString*) xmlResultFromJavascript
{
    if(provisioningAccountPtr)
    {
        if (xmlResultFromJavascript)
            provisioningAccountPtr->completeOAuthLoginProcess(IXML::createFromString([xmlResultFromJavascript UTF8String]));
    }
    else
    {
        [NSException raise:NSInvalidArgumentException format:@"Invalid provisioning account pointer!"];
    }
}

#pragma mark Getters
- (NSString*) getUserID
{
    NSString* ret = nil;
    
    if(provisioningAccountPtr)
    {
        ret = [NSString stringWithUTF8String: provisioningAccountPtr->getUserID()];
    }
    else
    {
        [NSException raise:NSInvalidArgumentException format:@"Invalid provisioning account pointer!"];
    }
    return ret;
}

- (NSString*) getContactID
{
    NSString* ret = nil;
    
    if(provisioningAccountPtr)
    {
        ret = [NSString stringWithUTF8String: provisioningAccountPtr->getOpenPeerAccount()->getSelfContact()->getContactID()];
    }
    else
    {
        [NSException raise:NSInvalidArgumentException format:@"Invalid provisioning account pointer!"];
    }
    return ret;

}

- (NSString*) getAccountSalt
{
    NSString* ret = nil;
    
    if(provisioningAccountPtr)
    {
        ret = [NSString stringWithUTF8String: provisioningAccountPtr->getAccountSalt()];
    }
    else
    {
        [NSException raise:NSInvalidArgumentException format:@"Invalid provisioning account pointer!"];
    }
    return ret;
}

- (NSString*) getPasswordNonce
{
    NSString* ret = nil;
    
    if(provisioningAccountPtr)
    {
        ret = [NSString stringWithUTF8String: provisioningAccountPtr->getPasswordNonce()];
    }
    else
    {
        [NSException raise:NSInvalidArgumentException format:@"Invalid provisioning account pointer!"];
    }
    return ret;
}

- (NSString*) getPassword
{
    NSString* ret = nil;
    
    if(provisioningAccountPtr)
    {
        ret = [NSString stringWithUTF8String: provisioningAccountPtr->getPassword()];
    }
    else
    {
        [NSException raise:NSInvalidArgumentException format:@"Invalid provisioning account pointer!"];
    }
    return ret;
}

- (NSString*) getPrivatePeerFile
{
    NSString* ret = nil;
    
    if(provisioningAccountPtr)
    {
        ret = [NSString stringWithUTF8String: IXML::convertToString(provisioningAccountPtr->getPrivatePeerFile())];
    }
    else
    {
        [NSException raise:NSInvalidArgumentException format:@"Invalid provisioning account pointer!"];
    }
    return ret;
}

- (NSTimeInterval) getLastProfileUpdatedTime
{
    NSTimeInterval date = nil;
    
    if(provisioningAccountPtr)
    {
        date = zsLib::toEpoch(provisioningAccountPtr->getLastProfileUpdatedTime());//[OpenPeerUtility convertPosixTimeToDate:provisioningAccountPtr->getLastProfileUpdatedTime()];
    }
    else
    {
        [NSException raise:NSInvalidArgumentException format:@"Invalid provisioning account pointer!"];
    }
    return date;
}


/**
 Retrieves current provisoining account state. It will return only provisioning account state, and not openpeer account state. This is done by purpose because provisioning account owns openpeer account, therefore, it always has lesser state than openpeer account.
 @returns HOPProvisioningAccountStates Current provisoining account state
 */
- (HOPProvisioningAccountStates) getState
{
    HOPProvisioningAccountStates ret = HOPProvisioningAccountStateNone;
    if(provisioningAccountPtr)
    {
        ret = (HOPProvisioningAccountStates) provisioningAccountPtr->getState();
    }
    else
    {
        [NSException raise:NSInvalidArgumentException format:@"Invalid provisioning account pointer!"];
    }
    
    return ret;
}

/**
 Retrieves last openpeer account error
 @returns OpenPeer_AccountStates current state of the openpeer account
 */
- (HOPProvisioningAccountErrorCodes) getLastError
{
    HOPProvisioningAccountErrorCodes ret = HOPProvisioningAccountErrorCodeNone;
    hookflash::IAccount::AccountErrors coreAccError = hookflash::IAccount::AccountError_None;
    if(provisioningAccountPtr)
    {
        coreAccError = provisioningAccountPtr->getOpenPeerAccount()->getLastError();
        switch (coreAccError) {
            case hookflash::IAccount::AccountError_None:
                ret = (HOPProvisioningAccountErrorCodes) provisioningAccountPtr->getLastError();
                break;
            case hookflash::IAccount::AccountError_InternalError:
                ret = HOPProvisioningAccountErrorCodeInternalFailure;
                break;
            case hookflash::IAccount::AccountError_StackFailed:
                ret = HOPProvisioningAccountErrorCodeStackFailed;
                break;
            case hookflash::IAccount::AccountError_BootstrappedNetworkFailed:
                ret = HOPProvisioningAccountErrorCodeBootstrappedNetworkFailed;
                break;
            case hookflash::IAccount::AccountError_CallTransportFailed:
                ret = HOPProvisioningAccountErrorCodeCallTransportFailed;
                break;
                
            default:
                ret = (HOPProvisioningAccountErrorCodes) provisioningAccountPtr->getLastError();
                break;
        }
    }
    else
    {
        [NSException raise:NSInvalidArgumentException format:@"Invalid provisioning account pointer!"];
    }
    
    return ret;
}

- (NSArray*) getIdentities
{
    NSMutableArray* array = nil;
    if(provisioningAccountPtr)
    {
        std::list<hookflash::provisioning::IAccount::IdentityInfo> coreIdentities;
        provisioningAccountPtr->getIdentities(coreIdentities);
        
        if (coreIdentities.size() > 0)
            array = [[NSMutableArray alloc] init];
  
        for (std::list<hookflash::provisioning::IAccount::IdentityInfo>::iterator it = coreIdentities.begin(); it != coreIdentities.end(); ++it)
        {
            HOPIdentityInfo* tmpInfo = [[HOPIdentityInfo alloc] init];
            tmpInfo.type = (HOPProvisioningAccountIdentityTypes) it->mType;
            tmpInfo.uniqueId = [NSString stringWithUTF8String: it->mUniqueID];
            tmpInfo.uniqueIDProof = [NSString stringWithUTF8String: it->mUniqueIDProof];
            tmpInfo.validationState = (HOPProvisioningAccountIdentityValidationStates) it->mValidationState;
            tmpInfo.validationId = [NSString stringWithUTF8String: it->mValidationID];
            tmpInfo.priority = it->mPriority;
            tmpInfo.weight = it->mWeight;
            
            [array addObject:tmpInfo];
            [tmpInfo release];
        }
    }
    else
    {
        [NSException raise:NSInvalidArgumentException format:@"Invalid provisioning account pointer!"];
    }
    return [array autorelease];
}

- (void) setIdentities: (NSArray*) identities
{
    if(!provisioningAccountPtr)
    {
        if ([identities count] > 0)
        {
            std::list<hookflash::provisioning::IAccount::IdentityInfo> coreIdentitiesToSet;
            for (HOPIdentityInfo* info in identities)
            {
                hookflash::provisioning::IAccount::IdentityInfo tmpInfo;
                
                tmpInfo.mType = (hookflash::provisioning::IAccount::IdentityTypes) info.type;
                tmpInfo.mUniqueID = [info.uniqueId UTF8String];
                tmpInfo.mUniqueIDProof = [info.uniqueIDProof UTF8String];
                tmpInfo.mValidationState = (hookflash::provisioning::IAccount::IdentityValidationStates) info.validationState;
                tmpInfo.mValidationID = [info.validationId UTF8String];
                tmpInfo.mPriority = info.priority;
                tmpInfo.mWeight = info.weight;
                
                coreIdentitiesToSet.push_back(tmpInfo);
            }
            
            provisioningAccountPtr->setIdentities(coreIdentitiesToSet);
        }
    }
    else
    {
        [NSException raise:NSInvalidArgumentException format:@"Invalid provisioning account pointer!"];
    }
}

- (HOPProvisioningAccountIdentityValidationStates) getIdentityValidationState: (HOPIdentity*) identity
{
    HOPProvisioningAccountIdentityValidationStates ret = HOPProvisioningAccountIdentityValidationStateNone;
  
    if(provisioningAccountPtr)
    {
        hookflash::provisioning::IAccount::IdentityID coreID;
        coreID.first = (hookflash::provisioning::IAccount::IdentityTypes) identity.identityType;
        coreID.second = [identity.identityId UTF8String];

        ret = (HOPProvisioningAccountIdentityValidationStates) provisioningAccountPtr->getIdentityValidationState(coreID);
    }
    else
    {
        [NSException raise:NSInvalidArgumentException format:@"Invalid provisioning account pointer!"];
    }
    
    return ret;
}

- (void) validateIdentitySendPIN: (HOPIdentity*) identity
{
    if(provisioningAccountPtr)
    {
        if (identity)
        {
            hookflash::provisioning::IAccount::IdentityID coreID;
            coreID.first = (hookflash::provisioning::IAccount::IdentityTypes) identity.identityType;
            if (identity.identityId)
                coreID.second = [identity.identityId UTF8String];
    
            provisioningAccountPtr->validateIdentitySendPIN(coreID);
        }
    }
    else
    {
        [NSException raise:NSInvalidArgumentException format:@"Invalid provisioning account pointer!"];
    }
}

- (void) validateIdentityComplete: (HOPIdentity*) identity identityPIN: (NSString*) identityPIN
{
    if(provisioningAccountPtr)
    {
        if (identity)
        {
            hookflash::provisioning::IAccount::IdentityID coreID;
            coreID.first = (hookflash::provisioning::IAccount::IdentityTypes) identity.identityType;
            if (identity.identityId)
            {
                coreID.second = [identity.identityId UTF8String];
            }
            
            provisioningAccountPtr->validateIdentityComplete(coreID, [identityPIN UTF8String]);
        }
    }
    else
    {
        [NSException raise:NSInvalidArgumentException format:@"Invalid provisioning account pointer!"];
    }
}

#pragma mark Helper classes


- (HOPProvisioningAccountOAuthIdentityAssociation*) associateOAuthIdentity :(HOPProvisioningAccountIdentityTypes) type delegate:(id<HOPProvisioningAccountOAuthIdentityAssociationDelegate>) delegate
{
    HOPProvisioningAccountOAuthIdentityAssociation* ret = nil;
    if (provisioningAccountPtr)
    {
        boost::shared_ptr<OpenPeerProvisioningAccountOAuthIdentityAssociationDelegate> openPeerProvisioningAccountOAuthIdentityAssociationDelegatePtr = OpenPeerProvisioningAccountOAuthIdentityAssociationDelegate::create(delegate);
        
        if (openPeerProvisioningAccountOAuthIdentityAssociationDelegatePtr)
        {
            IAccountOAuthIdentityAssociationPtr accountOAuthIdentityAssociationPtr = provisioningAccountPtr->associateOAuthIdentity((hookflash::provisioning::IAccount::IdentityTypes) type, openPeerProvisioningAccountOAuthIdentityAssociationDelegatePtr);
            if (accountOAuthIdentityAssociationPtr)
            {
                ret = [[HOPProvisioningAccountOAuthIdentityAssociation alloc] init];
                [ret setAccountOAuthIdentityAssociationPtr:accountOAuthIdentityAssociationPtr];
            }
        }
    }
    else
    {
        [NSException raise:NSInvalidArgumentException format:@"Invalid provisioning account pointer!"];
    }
    
    return [ret autorelease];
}

- (HOPProvisioningAccountPush*) apnsPush: (id<HOPAPNSDelegate>) delegate userIDs: (NSArray*) userIDs messageType: (NSString*) messageType message: (NSString*) message
{
    HOPProvisioningAccountPush* ret = nil;
    if (provisioningAccountPtr)
    {
        boost::shared_ptr<OpenPeerAPNSDelegate> openPeerAPNSDelegatePtr = OpenPeerAPNSDelegate::create(delegate);
        
        if (openPeerAPNSDelegatePtr)
        {
            if ([userIDs count] > 0)
            {
                provisioning::IAccount::UserIDList userIDlist;
                for (NSString* userId in userIDs)
                {
                    zsLib::String userID = [userId UTF8String];
                    userIDlist.push_back(userID);
                    
                    IAccountPushPtr accountPushPtr = provisioningAccountPtr->apnsPush(openPeerAPNSDelegatePtr, userIDlist, [messageType UTF8String], [message UTF8String]);
                    if (accountPushPtr)
                    {
                        ret = [[HOPProvisioningAccountPush alloc] init];
                        [ret setAccountPushPtr:accountPushPtr];
                        break;
                    }
                }
            }
        }
    }
    else
    {
        [NSException raise:NSInvalidArgumentException format:@"Invalid provisioning account pointer!"];
    }
    
    return [ret autorelease];
}

- (HOPProvisioningAccountIdentityLookupQuery*) identityLookup: (id<HOPProvisioningAccountIdentityLookupQueryDelegate>) delegate identities: (NSArray*) identities
{
    HOPProvisioningAccountIdentityLookupQuery* ret = nil;
    if (provisioningAccountPtr)
    {
        boost::shared_ptr<OpenPeerAccountIdentityLookupQueryDelegate> openPeerAccountIdentityLookupQueryDelegatePtr = OpenPeerAccountIdentityLookupQueryDelegate::create(delegate);
        
        if (openPeerAccountIdentityLookupQueryDelegatePtr)
        {
            if ([identities count] > 0)
            {
                provisioning::IAccount::IdentityIDList identityList;
                for (HOPIdentity* identity in identities)
                {
                    provisioning::IAccount::IdentityID identityID;
                    identityID.first = (provisioning::IAccount::IdentityTypes)identity.identityType;
                    identityID.second = [identity.identityId UTF8String];
                    identityList.push_back(identityID);
                }
                IAccountIdentityLookupQueryPtr accountIdentityLookupQueryPtr = provisioningAccountPtr->lookup(openPeerAccountIdentityLookupQueryDelegatePtr, identityList);
                
                if (accountIdentityLookupQueryPtr)
                {
                    ret = [[HOPProvisioningAccountIdentityLookupQuery alloc] init];
                    [ret setAccountIdentityLookupQueryPtr:accountIdentityLookupQueryPtr];
                    ret.uniqueId = [NSNumber numberWithUnsignedLong:accountIdentityLookupQueryPtr->getID()];
                    [self.dictionaryOfIdentityLookupQueries setObject:ret forKey:ret.uniqueId];
                }
            }
        }
    }
    else
    {
        [NSException raise:NSInvalidArgumentException format:@"Invalid provisioning account pointer!"];
    }
    
    return [ret autorelease];
}

- (HOPProvisioningAccountPeerFileLookupQuery*) peerFileLookup: (id<HOPProvisioningAccountPeerFileLookupQueryDelegate>) delegate contacts:(NSArray*) contacts
{
    HOPProvisioningAccountPeerFileLookupQuery* ret = nil;
    
    if (provisioningAccountPtr)
    {
        boost::shared_ptr<OpenPeerAccountPeerFileLookupQueryDelegate> openPeerAccountPeerFileLookupQueryDelegatePtr = OpenPeerAccountPeerFileLookupQueryDelegate::create(delegate);
        
        if (openPeerAccountPeerFileLookupQueryDelegatePtr)
        {
            if ([contacts count] > 0)
            {
                provisioning::IAccount::UserIDList userIDList;
                provisioning::IAccount::ContactIDList contactIDList;
                for (HOPContact* contact in contacts)
                {
                    zsLib::String userID = [contact.userId UTF8String];
                    userIDList.push_back(userID);
                    zsLib::String contactID = [contact.contactId UTF8String];
                    contactIDList.push_back(contactID);
                }
                
                IAccountPeerFileLookupQueryPtr accountPeerFileLookupQueryPtr = provisioningAccountPtr->lookup(openPeerAccountPeerFileLookupQueryDelegatePtr, userIDList, contactIDList);
                
                if (accountPeerFileLookupQueryPtr)
                {
                    ret = [[HOPProvisioningAccountPeerFileLookupQuery alloc] init];
                    [ret setAccountPeerFileLookupQueryPtr:accountPeerFileLookupQueryPtr];
                    ret.uniqueId = [NSNumber numberWithUnsignedLong:accountPeerFileLookupQueryPtr->getID()];
                    [self.dictionaryOfPeerFilesLookupQueries setObject:ret forKey:ret.uniqueId];
                }
            }
            
        }
    }
    else
    {
        [NSException raise:NSInvalidArgumentException format:@"Invalid provisioning account pointer!"];
    }
    
    return [ret autorelease];
}


- (BOOL) createLocalDelegates:(id<HOPProvisioningAccountDelegate>) provisioningAccountDelegate
{
    BOOL ret = NO;
    
    openpeerProvisioningAccountDelegatePtr = OpenPeerProvisioningAccountDelegate::create(provisioningAccountDelegate);
    
    if (openpeerProvisioningAccountDelegatePtr)
        ret = YES;
    return ret;
}

- (void) deleteLocalDelegates
{
    openpeerProvisioningAccountDelegatePtr.reset();
}

- (provisioning::IAccountPtr)  getAccountPtr
{
    return provisioningAccountPtr;
}

- (hookflash::IAccountPtr)  getOpenpeerAccountPtr
{
    return provisioningAccountPtr->getOpenPeerAccount();
}

#pragma mark - HOPAccount methods

/**
 Converts State enum to string
 @param state OpenPeer_AccountStates enum
 @returns NSString representation of enum
 */
//HOP_TODO: Make this to work for merged account
/*+ (NSString*) stateToString:(HOPAccountStates) state
{
    return [NSString stringWithUTF8String: IAccount::toString((hookflash::IAccount::AccountStates) state)];
}*/


/**
 Converts Error enum to string
 @param errorCode OpenPeer_AccountErrors enum
 @returns NSString representation of enum
 */
//HOP_TODO: Make this to work for merged account
/*+ (NSString*) errorToString:(HOPAccountErrors) errorCode
{
    return [NSString stringWithUTF8String: IAccount::toString((hookflash::IAccount::AccountErrors) errorCode)];
}*/

/**
 Shutdown of the openpeer account.
 */
- (void) shutdown
{
    if (provisioningAccountPtr && provisioningAccountPtr->getOpenPeerAccount())
    {
        provisioningAccountPtr->shutdown();
        provisioningAccountPtr.reset();
    }
    else
    {
        [NSException raise:NSInternalInconsistencyException format:@"Invalid OpenPeer account pointer!"];
    }
}


- (HOPAccountSubscription*) subscribe: (id<HOPProvisioningAccountDelegate>) delegate
{
    HOPAccountSubscription* accountSubscription = nil;
    
    if (provisioningAccountPtr && provisioningAccountPtr->getOpenPeerAccount())
    {
        boost::shared_ptr<OpenPeerProvisioningAccountDelegate> openPeerAccountDelegatePtr = OpenPeerProvisioningAccountDelegate::create(delegate);
        
        if (openPeerAccountDelegatePtr)
        {
            listOfOpenPeerAccountDelegates.push_back(openPeerAccountDelegatePtr);
            IAccountSubscriptionPtr accountSubscriptionPtr = provisioningAccountPtr->getOpenPeerAccount()->subscribe(openPeerAccountDelegatePtr);
            
            accountSubscription = [[HOPAccountSubscription alloc] init];
            [accountSubscription setAccountSubscription:accountSubscriptionPtr];
            [self.listOfProvisioningAccountDelegates addObject:accountSubscription];
        }
    }
    else
    {
        [NSException raise:NSInvalidArgumentException format:@"Invalid OpenPeer account pointer!"];
    }
    return [accountSubscription autorelease];
}

/**
 Retrieves self contact
 @returns HOPContact contact object for self
 */
- (HOPContact*) getSelfContact
{
    HOPContact* hopContact = nil;
    if (provisioningAccountPtr && provisioningAccountPtr->getOpenPeerAccount())
    {
        IContactPtr contactPtr = provisioningAccountPtr->getOpenPeerAccount()->getSelfContact();
        if (contactPtr)
        {
            NSString* contactId = [NSString stringWithUTF8String:contactPtr->getContactID()];
            hopContact = [[OpenPeerStorageManager sharedStorageManager] getContactForId:contactId];
            if (!hopContact)
            {
                hopContact = [[HOPContact alloc] initWithCoreContact:contactPtr];
                [[OpenPeerStorageManager sharedStorageManager] setContact:hopContact forId:contactId];
                [hopContact release];
            }
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
    
    if(provisioningAccountPtr && provisioningAccountPtr->getOpenPeerAccount())
    {
        locationId = [NSString stringWithUTF8String: provisioningAccountPtr->getOpenPeerAccount()->getLocationID()];
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
    if(provisioningAccountPtr->getOpenPeerAccount())
    {
        zsLib::XML::ElementPtr element = provisioningAccountPtr->getOpenPeerAccount()->savePrivatePeer();
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
    if(provisioningAccountPtr && provisioningAccountPtr->getOpenPeerAccount())
    {
        zsLib::XML::ElementPtr element = provisioningAccountPtr->getOpenPeerAccount()->savePublicPeer();
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
    if (provisioningAccountPtr && provisioningAccountPtr->getOpenPeerAccount())
    {
        if (contact)
            provisioningAccountPtr->getOpenPeerAccount()->notifyAboutContact([contact getContactPtr]);
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
    if (provisioningAccountPtr && provisioningAccountPtr->getOpenPeerAccount())
    {
        if (contact)
            provisioningAccountPtr->getOpenPeerAccount()->hintAboutContactLocation([contact getContactPtr], [locationID UTF8String]);
    }
    else
    {
        [NSException raise:NSInvalidArgumentException format:@"Invalid OpenPeer account pointer!"];
    }
}

/**
 Retrieves conversation thread object based on ts ID.
 @return threadID NSString conversation thread ID
 */
- (HOPConversationThread*) getConversationThreadByID:(NSString*) threadID
{
    HOPConversationThread* hopConversationThread = nil;
    if ([threadID length] > 0)
    {
        hopConversationThread = [[OpenPeerStorageManager sharedStorageManager] getConversationThreadForId:threadID];
    }
    
    return hopConversationThread;
}

/**
 Retrieves all conversation threads
 @return outConversationThreads std::list<HOPConversationThread> list of conversation threads
 */
- (NSArray*) getConversationThreads
{
    return [[OpenPeerStorageManager sharedStorageManager] getConversationThreads];
}

- (HOPProvisioningAccountIdentityLookupQuery*) getProvisioningAccountIdentityLookupQueryForUniqueId:(NSNumber*) uniqueId
{
    HOPProvisioningAccountIdentityLookupQuery* ret = nil;
    if (uniqueId)
        ret = [self.dictionaryOfIdentityLookupQueries objectForKey:uniqueId];//[[self.dictionaryOfIdentityLookupQueries allValues] objectAtIndex:0];
    
    return ret;
}

- (HOPProvisioningAccountPeerFileLookupQuery*) getProvisioningAccountPeerFileLookupQueryForUniqueId:(NSNumber*) uniqueId
{
    HOPProvisioningAccountPeerFileLookupQuery* ret = nil;
    if (uniqueId)
        ret = [self.dictionaryOfPeerFilesLookupQueries objectForKey:uniqueId];//[[self.dictionaryOfPeerFilesLookupQueries allValues] objectAtIndex:0];
    
    return ret;
}

- (void) removeDelegate:(HOPAccountSubscription*) subscribedDelegate
{
    [self.listOfProvisioningAccountDelegates removeObject:subscribedDelegate];
}
@end
























