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


#import <hookflash/provisioning/IAccount.h>
#import <hookflash/IXML.h>

#import "HOPProvisioningAccountOAuthIdentityAssociation_Internal.h"
#import "OpenPeerProvisioningAccountOAuthIdentityAssociationDelegate.h"
#import "HOPProvisioningAccountPeerFileLookupQuery_Internal.h"
#import "HOPProvisioningAccountIdentityLookupQuery_Internal.h"
#import "OpenPeerAccountIdentityLookupQueryDelegate.h"
#import "OpenPeerAccountPeerFileLookupQueryDelegate.h"
#import "OpenPeerAPNSDelegate.h"
#import "HOPProvisioningAccountPush.h"
#import "HOPProvisioningAccountPush_Internal.h"
#import "HOPProvisioningAccount_Internal.h"
#import "HOPProvisioningAccount.h"
#import "HOPStack_Internal.h"
#import "HOPAccount_Internal.h"
#import "HOPIdentityInfo.h"
#import "HOPIdentity.h"
#import "HOPProtocols.h"
#import "HOPProvisioningAccountOAuthIdentityAssociation.h"
#import "HOPAccount.h"
#import "OpenPeerUtility.h"

@implementation HOPProvisioningAccount


+ (id)sharedInstance
{
    static dispatch_once_t pred = 0;
    __strong static id _sharedObject = nil;
    dispatch_once(&pred, ^{
        _sharedObject = [[self alloc] init]; // or some other init method
    });
    return _sharedObject;
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


#pragma mark Login methods
- (BOOL) firstTimeLogin: (HOPStack*) stack provisioningAccountDelegate: (id<HOPProvisioningAccountDelegate>) provisioningAccountDelegate openpeerAccountDelegate: (id<HOPAccountDelegate>) openpeerAccountDelegate provisioningURI: (NSString*) provisioningURI deviceToken: (NSString*) deviceToken name: (NSString*) name knownIdentities: (NSArray*) knownIdentities
{
    BOOL passedWithoutErrors = NO;
    
    if (!stack || !provisioningAccountDelegate || !openpeerAccountDelegate)
        return passedWithoutErrors;
    
    if ( ([provisioningURI length] == 0 ) || ([deviceToken length] == 0 ) || ([name length] == 0 ) || ([knownIdentities count] == 0) )
        return passedWithoutErrors;
    
    BOOL delegatesCreated = [self createLocalDelegates:provisioningAccountDelegate openpeerAccountDelegate:openpeerAccountDelegate];
    
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
        
        accountPtr = provisioning::IAccount::firstTimeLogin([stack getStackPtr], openpeerProvisioningAccountDelegatePtr, openpeerAccountDelegatePtr, [provisioningURI UTF8String], [deviceToken UTF8String], [name UTF8String], identities);
        
        if (accountPtr)
            passedWithoutErrors = YES;
    }
    
    return passedWithoutErrors;
}

- (BOOL) firstTimeOAuthLogin: (HOPStack*) stack provisioningAccountDelegate: (id<HOPProvisioningAccountDelegate>) provisioningAccountDelegate openpeerAccountDelegate: (id<HOPAccountDelegate>) openpeerAccountDelegate provisioningURI: (NSString*) provisioningURI deviceToken: (NSString*) deviceToken oauthIdentityType: (HOPProvisioningAccountIdentityTypes) oauthIdentityType
{
    BOOL passedWithoutErrors = NO;
    
    if (!stack || !provisioningAccountDelegate || !openpeerAccountDelegate)
        return passedWithoutErrors;
    
    if ( ([provisioningURI length] == 0 ) || ([deviceToken length] == 0 ) )
        return passedWithoutErrors;
    
    BOOL delegatesCreated = [self createLocalDelegates:provisioningAccountDelegate openpeerAccountDelegate:openpeerAccountDelegate];
    
    if (delegatesCreated)
    {
        
        accountPtr = provisioning::IAccount::firstTimeOAuthLogin([stack getStackPtr], openpeerProvisioningAccountDelegatePtr, openpeerAccountDelegatePtr, [provisioningURI UTF8String], [deviceToken UTF8String], (hookflash::provisioning::IAccount::IdentityTypes) oauthIdentityType);
        
        if (accountPtr)
            passedWithoutErrors = YES;
    }
    
    return passedWithoutErrors;
}

- (BOOL) relogin: (HOPStack*) stack provisioningAccountDelegate: (id<HOPProvisioningAccountDelegate>) provisioningAccountDelegate openpeerAccountDelegate: (id<HOPAccountDelegate>) openpeerAccountDelegate provisioningURI: (NSString*) provisioningURI deviceToken: (NSString*) deviceToken userID: (NSString*) userID accountSalt: (NSString*) accountSalt passwordNonce: (NSString*) passwordNonce password: (NSString*) password privatePeerFile: (NSString*) privatePeerFile lastProfileUpdatedTimestamp: (NSDate*) lastProfileUpdatedTimestamp previousIdentities: (NSArray*) previousIdentities
{
    BOOL passedWithoutErrors = NO;
    
    if (!stack || !provisioningAccountDelegate || !openpeerAccountDelegate)
        return passedWithoutErrors;
  
    if ( ([provisioningURI length] == 0 ) || ([deviceToken length] == 0 ) || ([userID length] == 0 ) || ([accountSalt length] == 0 ) || ([passwordNonce length] == 0 ) || ([password length] == 0 ) || ([privatePeerFile length] == 0 ) || ([previousIdentities count] == 0))
        return passedWithoutErrors;
    
    BOOL delegatesCreated = [self createLocalDelegates:provisioningAccountDelegate openpeerAccountDelegate:openpeerAccountDelegate];
    
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
        
        zsLib::Time lastProfileUpdateTimestampTemp = boost::posix_time::from_time_t([lastProfileUpdatedTimestamp timeIntervalSince1970]) ;
        
        accountPtr = provisioning::IAccount::relogin([stack getStackPtr], openpeerProvisioningAccountDelegatePtr, openpeerAccountDelegatePtr, [provisioningURI UTF8String], [deviceToken UTF8String], [userID UTF8String], [accountSalt UTF8String], [passwordNonce UTF8String], [password UTF8String], IXML::createFromString([privatePeerFile UTF8String]), lastProfileUpdateTimestampTemp, identities);
        
        if (accountPtr)
            passedWithoutErrors = YES;
    }
    
    return passedWithoutErrors;
}

- (HOPIdentity*) getAuthorizationPINIdentity
{
    HOPIdentity* ret = nil;
    if(accountPtr)
    {
        std::pair<hookflash::provisioning::IAccount::IdentityTypes, const char*> coreIdentity = accountPtr->getAuthorizationPINIdentity();

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
    if(accountPtr)
    {
        if (authorizationPIN)
            accountPtr->setAuthorizationPIN([authorizationPIN UTF8String]);
    }
    else
    {
        [NSException raise:NSInvalidArgumentException format:@"Invalid provisioning account pointer!"];
    }
}

- (NSString*) getOAuthURL
{
    NSString* ret = nil;
  
    if(accountPtr)
    {
        ret = [NSString stringWithUTF8String: accountPtr->getOAuthLoginURL()];
    }
    else
    {
        [NSException raise:NSInvalidArgumentException format:@"Invalid provisioning account pointer!"];
    }
    return ret;
}

- (void) completeOAuthLoginProcess: (NSString*) xmlResultFromJavascript
{
    if(accountPtr)
    {
        if (xmlResultFromJavascript)
            accountPtr->completeOAuthLoginProcess(IXML::createFromString([xmlResultFromJavascript UTF8String]));
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
    
    if(accountPtr)
    {
        ret = [NSString stringWithUTF8String: accountPtr->getUserID()];
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
    
    if(accountPtr)
    {
        ret = [NSString stringWithUTF8String: accountPtr->getAccountSalt()];
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
    
    if(accountPtr)
    {
        ret = [NSString stringWithUTF8String: accountPtr->getPasswordNonce()];
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
    
    if(accountPtr)
    {
        ret = [NSString stringWithUTF8String: accountPtr->getPassword()];
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
    
    if(accountPtr)
    {
        ret = [NSString stringWithUTF8String: IXML::convertToString(accountPtr->getPrivatePeerFile())];
    }
    else
    {
        [NSException raise:NSInvalidArgumentException format:@"Invalid provisioning account pointer!"];
    }
    return ret;
}

- (NSDate*) getLastProfileUpdatedTime
{
    NSDate* date = nil;
    
    if(!accountPtr)
    {
        date = [OpenPeerUtility convertPosixTimeToDate:accountPtr->getLastProfileUpdatedTime()];
    }
    else
    {
        [NSException raise:NSInvalidArgumentException format:@"Invalid provisioning account pointer!"];
    }
    return date;
}


- (HOPAccount*) getOpenPeerAccount
{
    if (!hopAccount)
    {
        if(accountPtr)
        {
            hookflash::IAccountPtr openPeerAccountPtr = accountPtr->getOpenPeerAccount();
            if (openPeerAccountPtr)
            {
                hopAccount = [[HOPAccount alloc] init];
                [hopAccount setAccountPtr:openPeerAccountPtr];
            }
        }
        else
        {
            [NSException raise:NSInvalidArgumentException format:@"Invalid provisioning account pointer!"];
        }
    }
    
    return hopAccount;
}

- (HOPProvisioningAccountStates) getState
{
    HOPProvisioningAccountStates ret = HOPProvisioningAccountStateNone;
    if(accountPtr)
    {
        ret = (HOPProvisioningAccountStates) accountPtr->getState();
    }
    else
    {
        [NSException raise:NSInvalidArgumentException format:@"Invalid provisioning account pointer!"];
    }
    
    return ret;
}

- (HOPProvisioningAccountErrorCodes) getLastError
{
    HOPProvisioningAccountErrorCodes ret = HOPProvisioningAccountErrorCodeNone;
    if(accountPtr)
    {
        ret = (HOPProvisioningAccountErrorCodes) accountPtr->getLastError();
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
    if(accountPtr)
    {
        std::list<hookflash::provisioning::IAccount::IdentityInfo> coreIdentities;
        accountPtr->getIdentities(coreIdentities);
        
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
    if(!accountPtr)
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
            
            accountPtr->setIdentities(coreIdentitiesToSet);
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
  
    if(accountPtr)
    {
        hookflash::provisioning::IAccount::IdentityID coreID;
        coreID.first = (hookflash::provisioning::IAccount::IdentityTypes) identity.identityType;
        coreID.second = [identity.identityId UTF8String];

        ret = (HOPProvisioningAccountIdentityValidationStates) accountPtr->getIdentityValidationState(coreID);
    }
    else
    {
        [NSException raise:NSInvalidArgumentException format:@"Invalid provisioning account pointer!"];
    }
    
    return ret;
}

- (void) validateIdentitySendPIN: (HOPIdentity*) identity
{
    if(accountPtr)
    {
        if (identity)
        {
            hookflash::provisioning::IAccount::IdentityID coreID;
            coreID.first = (hookflash::provisioning::IAccount::IdentityTypes) identity.identityType;
            if (identity.identityId)
                coreID.second = [identity.identityId UTF8String];
    
            accountPtr->validateIdentitySendPIN(coreID);
        }
    }
    else
    {
        [NSException raise:NSInvalidArgumentException format:@"Invalid provisioning account pointer!"];
    }
}

- (void) validateIdentityComplete: (HOPIdentity*) identity identityPIN: (NSString*) identityPIN
{
    if(accountPtr)
    {
        if (identity)
        {
            hookflash::provisioning::IAccount::IdentityID coreID;
            coreID.first = (hookflash::provisioning::IAccount::IdentityTypes) identity.identityType;
            if (identity.identityId)
            {
                coreID.second = [identity.identityId UTF8String];
            }
            
            accountPtr->validateIdentityComplete(coreID, [identityPIN UTF8String]);
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
    if (accountPtr)
    {
        boost::shared_ptr<OpenPeerProvisioningAccountOAuthIdentityAssociationDelegate> openPeerProvisioningAccountOAuthIdentityAssociationDelegatePtr = OpenPeerProvisioningAccountOAuthIdentityAssociationDelegate::create(delegate);
        
        if (openPeerProvisioningAccountOAuthIdentityAssociationDelegatePtr)
        {
            IAccountOAuthIdentityAssociationPtr accountOAuthIdentityAssociationPtr = accountPtr->associateOAuthIdentity((hookflash::provisioning::IAccount::IdentityTypes) type, openPeerProvisioningAccountOAuthIdentityAssociationDelegatePtr);
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
    
    return ret;
}

- (HOPProvisioningAccountPush*) apnsPush: (id<HOPAPNSDelegate>) delegate userIDs: (NSArray*) userIDs messageType: (NSString*) messageType message: (NSString*) message
{
    HOPProvisioningAccountPush* ret = nil;
    if (accountPtr)
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
                    
                    IAccountPushPtr accountPushPtr = accountPtr->apnsPush(openPeerAPNSDelegatePtr, userIDlist, [messageType UTF8String], [message UTF8String]);
                    if (accountPushPtr)
                    {
                        ret = [[HOPProvisioningAccountPush alloc] init];
                        [ret setAccountPushPtr:accountPushPtr];
                    }
                }
            }
        }
    }
    else
    {
        [NSException raise:NSInvalidArgumentException format:@"Invalid provisioning account pointer!"];
    }
    
    return ret;
}

- (HOPProvisioningAccountIdentityLookupQuery*) identityLookup: (id<HOPProvisioningAccountIdentityLookupQueryDelegate>) delegate identities: (NSArray*) identities
{
    HOPProvisioningAccountIdentityLookupQuery* ret = nil;
    if (accountPtr)
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
                IAccountIdentityLookupQueryPtr accountIdentityLookupQueryPtr = accountPtr->lookup(openPeerAccountIdentityLookupQueryDelegatePtr, identityList);
                
                if (accountIdentityLookupQueryPtr)
                {
                    ret = [[HOPProvisioningAccountIdentityLookupQuery alloc] init];
                    [ret setAccountIdentityLookupQueryPtr:accountIdentityLookupQueryPtr];
                }
            }
        }
    }
    else
    {
        [NSException raise:NSInvalidArgumentException format:@"Invalid provisioning account pointer!"];
    }
    
    return ret;
}

- (HOPProvisioningAccountPeerFileLookupQuery*) peerFileLookup: (id<HOPProvisioningAccountPeerFileLookupQueryDelegate>) delegate userIDs: (NSArray*) userIDs associatedContactIDs: (NSArray*) associatedContactIDs
{
    HOPProvisioningAccountPeerFileLookupQuery* ret = nil;
    
    if (accountPtr)
    {
        boost::shared_ptr<OpenPeerAccountPeerFileLookupQueryDelegate> openPeerAccountPeerFileLookupQueryDelegatePtr = OpenPeerAccountPeerFileLookupQueryDelegate::create(delegate);
        
        if (openPeerAccountPeerFileLookupQueryDelegatePtr)
        {
            if ([userIDs count] > 0)
            {
                provisioning::IAccount::UserIDList userIDList;
                for (NSString* userId in userIDs)
                {
                    zsLib::String userID = [userId UTF8String];
                    userIDList.push_back(userID);
                }
                
                provisioning::IAccount::ContactIDList contactIDList;
                for (NSString* contactId in associatedContactIDs)
                {
                    zsLib::String contactID = [contactId UTF8String];
                    contactIDList.push_back(contactID);
                }
                
                IAccountPeerFileLookupQueryPtr accountPeerFileLookupQueryPtr = accountPtr->lookup(openPeerAccountPeerFileLookupQueryDelegatePtr, userIDList, contactIDList);
                
                if (accountPeerFileLookupQueryPtr)
                {
                    ret = [[HOPProvisioningAccountPeerFileLookupQuery alloc] init];
                    [ret setAccountPeerFileLookupQueryPtr:accountPeerFileLookupQueryPtr];
                }
            }
            
        }
    }
    else
    {
        [NSException raise:NSInvalidArgumentException format:@"Invalid provisioning account pointer!"];
    }
    
    return ret;
}


- (BOOL) createLocalDelegates:(id<HOPProvisioningAccountDelegate>) provisioningAccountDelegate openpeerAccountDelegate:(id<HOPAccountDelegate>) openpeerAccountDelegate
{
    BOOL ret = NO;
    
    openpeerProvisioningAccountDelegatePtr = OpenPeerProvisioningAccountDelegate::create(provisioningAccountDelegate);
    openpeerAccountDelegatePtr = OpenPeerAccountDelegate::create(openpeerAccountDelegate);
    
    if (openpeerProvisioningAccountDelegatePtr && openpeerAccountDelegatePtr)
        ret = YES;
    return ret;
}
- (void) deleteLocalDelegates
{
    
}

- (provisioning::IAccountPtr)  getAccountPtr
{
    return accountPtr;
}
@end
























