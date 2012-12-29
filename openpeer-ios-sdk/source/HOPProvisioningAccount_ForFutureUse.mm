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


#import "HOPProvisioningAccount_ForFutureUse.h"
#import <hookflash/provisioning2/IAccount.h>
#import <hookflash/IXML.h>

#import "HOPStack_Internal.h"
#import "OpenPeerUtility.h"
#import "OpenPeerStorageManager.h"

using namespace hookflash;

@implementation HOPProvisioningAccount_ForFutureUse

+ (id)sharedInstance
{
    static dispatch_once_t pred = 0;
    __strong static id _sharedObject = nil;
    dispatch_once(&pred, ^{
        _sharedObject = [[self alloc] initSingleton]; // or some other init method
    });
    return _sharedObject;
}

#pragma mark - Conversions

+ (NSString*) stateToString:(OpenpeerProvisioning_AccountStates) state
{
    return [NSString stringWithUTF8String: hookflash::provisioning2::IAccount::toString((hookflash::provisioning2::IAccount::AccountStates) state)];
}

+ (NSString*) errorCodeToString:(OpenpeerProvisioning_AccountErrorCodes) errorCode
{
    return [NSString stringWithUTF8String: hookflash::provisioning2::IAccount::toString((hookflash::provisioning2::IAccount::AccountErrorCodes) errorCode)];
}

- (BOOL) create: (HOPStack*) stack provisioningAccountDelegate: (id<HOPOpenpeerProvisioningAccountDelegate>) provisioningAccountDelegate openpeerAccountDelegate: (id<HOPAccountDelegate>) openpeerAccountDelegate peerContactServiceBootstrappedDomain: (NSString*) peerContactServiceBootstrappedDomain privatePeerFileSecret: (NSString*) privatePeerFileSecret privatePeerFileEl: (NSString*) privatePeerFileEl
{
    BOOL passedWithoutErrors = NO;
    
    @synchronized(self)
    {
        if (!stack || !provisioningAccountDelegate || !openpeerAccountDelegate)
            return passedWithoutErrors;
        
        if ( ([peerContactServiceBootstrappedDomain length] == 0 ) || ([privatePeerFileSecret length] == 0 ) || ([privatePeerFileEl length] == 0 ) )
            return passedWithoutErrors;
        
        if (provisioningAccountPtr)
            provisioningAccountPtr->shutdown();
        
        BOOL delegatesCreated = [self createLocalDelegates:provisioningAccountDelegate];
        
        if (delegatesCreated)
        {
            provisioningAccountPtr = provisioning2::IAccount::create([stack getStackPtr], openpeerProvisioningAccountDelegatePtr, openpeerProvisioningAccountDelegatePtr, [peerContactServiceBootstrappedDomain UTF8String]);
            
            if (provisioningAccountPtr)
                passedWithoutErrors = YES;
        }
    }
    
    return passedWithoutErrors;
}

- (OpenpeerProvisioning_IdentityLoginSession*) identityLogin: (id<OpenpeerProvisioning_IdentityLoginSessionDelegate>) delegate identityBaseURI: (NSString*) identityBaseURI identityProvider: (NSString*) identityProvider
{
    OpenpeerProvisioning_IdentityLoginSession* identitySession = nil;
    
    if (provisioningAccountPtr)
    {
        boost::shared_ptr<OpenPeerIdentityLoginSessionDelegate_ForFutureUse> openPeerIdentityLoginSessionDelegatePtr = OpenPeerIdentityLoginSessionDelegate_ForFutureUse::create(delegate);
        
        hookflash::provisioning2::IIdentityLoginSessionPtr coreIdentitySessionPtr = provisioningAccountPtr->identityLogin(openPeerIdentityLoginSessionDelegatePtr, [identityBaseURI UTF8String], [identityProvider UTF8String]);
        
        if (coreIdentitySessionPtr) {
            identitySession = [[OpenpeerProvisioning_IdentityLoginSession alloc] initWithIdentityLoginSession:coreIdentitySessionPtr];
        }
    }
    else
    {
        [NSException raise:NSInternalInconsistencyException format:@"Invalid provisioning account pointer!"];
    }
    return [identitySession autorelease];
}

- (void) shutdown
{
    if (provisioningAccountPtr)
    {
        provisioningAccountPtr->shutdown();
        provisioningAccountPtr.reset();
    }
    else
    {
        [NSException raise:NSInternalInconsistencyException format:@"Invalid provisioning account pointer!"];
    }
}

- (NSArray*) getKnownIdentities
{
    NSMutableArray* outIdentities = nil;
    
    if(provisioningAccountPtr)
    {
        std::list<hookflash::provisioning2::IAccount::Identity> coreIdentities;
        provisioningAccountPtr->getKnownIdentities(coreIdentities);
        
        if (coreIdentities.size() > 0)
            outIdentities = [[NSMutableArray alloc] init];
        
        for (std::list<hookflash::provisioning2::IAccount::Identity>::iterator it = coreIdentities.begin(); it != coreIdentities.end(); ++it)
        {
            OpenpeerIdentity* tmpInfo = [[OpenpeerIdentity alloc] init];
            tmpInfo.identityURI = [NSString stringWithUTF8String: it->mIdentityURI];
            tmpInfo.identityProvider = [NSString stringWithUTF8String: it->mIdentityProvider];
            tmpInfo.priority = it->mPriority;
            tmpInfo.weight = it->mWeight;
            
            [outIdentities addObject:tmpInfo];
            [tmpInfo release];
        }
    }
    else
    {
        [NSException raise:NSInvalidArgumentException format:@"Invalid provisioning account pointer!"];
    }
    
    return [outIdentities autorelease];
}

- (void) setKnownIdentities: (NSArray*) identities
{
    if(!provisioningAccountPtr)
    {
        if ([identities count] > 0)
        {
            std::list<hookflash::provisioning2::IAccount::Identity> coreIdentitiesToSet;
            for (OpenpeerIdentity* info in identities)
            {
                hookflash::provisioning2::IAccount::Identity tmpInfo;
                
                tmpInfo.mIdentityURI = [info.identityURI UTF8String];
                tmpInfo.mIdentityProvider = [info.identityProvider UTF8String];
                tmpInfo.mPriority = info.priority;
                tmpInfo.mWeight = info.weight;
                
                coreIdentitiesToSet.push_back(tmpInfo);
            }
            
            provisioningAccountPtr->setKnownIdentities(coreIdentitiesToSet);
        }
    }
    else
    {
        [NSException raise:NSInvalidArgumentException format:@"Invalid provisioning account pointer!"];
    }
}

- (NSString*) getPrivatePeerFileSecret
{
    NSString* privatePeerFileSecret = nil;
    
    if(provisioningAccountPtr)
    {
        privatePeerFileSecret = [NSString stringWithUTF8String: provisioningAccountPtr->getPrivatePeerFileSecret()];
    }
    else
    {
        [NSException raise:NSInvalidArgumentException format:@"Invalid provisioning account pointer!"];
    }
    return privatePeerFileSecret;
}

- (NSString*) exportPrivatePeerFile
{
    NSString* privatePeerFile= nil;
    
    if(provisioningAccountPtr)
    {
        zsLib::XML::ElementPtr element = provisioningAccountPtr->exportPrivatePeerFile();
        if (element)
        {
            privatePeerFile = [NSString stringWithUTF8String: IXML::convertToString(element)];
        }
    }
    else
    {
        [NSException raise:NSInvalidArgumentException format:@"Invalid provisioning account pointer!"];
    }
    return privatePeerFile;
}

- (OpenpeerProvisioning_AccountIdentityLookupQuery*) identityLookup: (id<OpenpeerProvisioning_AccountIdentityLookupQueryDelegate>) delegate identities: (NSArray*) identities
{
    OpenpeerProvisioning_AccountIdentityLookupQuery* ret = nil;
    if (provisioningAccountPtr)
    {
        boost::shared_ptr<OpenPeerAccountIdentityLookupQueryDelegate_ForFutureUse> openPeerAccountIdentityLookupQueryDelegatePtr = OpenPeerAccountIdentityLookupQueryDelegate_ForFutureUse::create(delegate);
        
        if (openPeerAccountIdentityLookupQueryDelegatePtr)
        {
            if ([identities count] > 0)
            {
                provisioning2::IAccount::IdentityURIList identityList;
                for (NSString* identity in identities)
                {
                    identityList.push_back([identity UTF8String]);
                }
                provisioning2::IAccountIdentityLookupQueryPtr accountIdentityLookupQueryPtr = provisioningAccountPtr->lookup(openPeerAccountIdentityLookupQueryDelegatePtr, identityList);
                
                if (accountIdentityLookupQueryPtr)
                {
                    ret = [[OpenpeerProvisioning_AccountIdentityLookupQuery alloc] init];
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

- (OpenpeerProvisioning_AccountPeerFileLookupQuery*) peerFileLookup: (id<OpenpeerProvisioning_AccountPeerFileLookupQueryDelegate>) delegate peerContacts: (NSArray*) peerContacts
{
    //TBD once SDK is stabilized
    return nil;
}

#pragma mark - Internal methods implementation

- (id) initSingleton
{
    self = [super init];
    if (self)
    {
        self.dictionaryOfIdentityLookupQueries = [[[NSMutableDictionary alloc] init] autorelease];
        self.dictionaryOfPeerFilesLookupQueries = [[[NSMutableDictionary alloc] init] autorelease];
    }
    return self;
}

- (BOOL) createLocalDelegates:(id<HOPOpenpeerProvisioningAccountDelegate>) provisioningAccountDelegate
{
    BOOL ret = NO;
    
    openpeerProvisioningAccountDelegatePtr = OpenPeerProvisioningAccountDelegate_ForFutureUse::create(provisioningAccountDelegate);
    
    if (openpeerProvisioningAccountDelegatePtr)
        ret = YES;
    return ret;
}

- (void) deleteLocalDelegates
{
    openpeerProvisioningAccountDelegatePtr.reset();
}

- (OpenpeerProvisioning_AccountIdentityLookupQuery*) getProvisioningAccountIdentityLookupQueryForUniqueId:(NSNumber*) uniqueId
{
    OpenpeerProvisioning_AccountIdentityLookupQuery* ret = nil;
    if (uniqueId)
        ret = [self.dictionaryOfIdentityLookupQueries objectForKey:uniqueId];//[[self.dictionaryOfIdentityLookupQueries allValues] objectAtIndex:0];
    
    return ret;
}

- (OpenpeerProvisioning_AccountPeerFileLookupQuery*) getProvisioningAccountPeerFileLookupQueryForUniqueId:(NSNumber*) uniqueId
{
    OpenpeerProvisioning_AccountPeerFileLookupQuery* ret = nil;
    if (uniqueId)
        ret = [self.dictionaryOfPeerFilesLookupQueries objectForKey:uniqueId];//[[self.dictionaryOfPeerFilesLookupQueries allValues] objectAtIndex:0];
    
    return ret;
}
/*
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
 */

@end

#pragma mark - OpenpeerProvisioning_IdentityLoginSession.mm

@implementation OpenpeerProvisioning_IdentityLoginSession

#pragma mark - Internal method definition

- (id) initWithIdentityLoginSession:(hookflash::provisioning2::IIdentityLoginSessionPtr) inIdentityLoginSessionPtr
{
    self = [super init];
    if (self)
    {
        identityLoginSessionPtr = inIdentityLoginSessionPtr;
    }
    return self;
}

- (hookflash::provisioning2::IIdentityLoginSessionPtr) getIdentityLoginSessionPtr
{
    return identityLoginSessionPtr;
}

#pragma mark - Public method definition

- (NSString*) getIdentityBase
{
    NSString* ret = nil;
    if(identityLoginSessionPtr)
    {
        ret = [NSString stringWithUTF8String: identityLoginSessionPtr->getIdentityBase()];
    }
    else
    {
        [NSException raise:NSInvalidArgumentException format:@"Invalid Identity login session pointer!"];
    }
    return ret;
}

- (NSString*) getIdentityProvider
{
    NSString* ret = nil;
    if(identityLoginSessionPtr)
    {
        ret = [NSString stringWithUTF8String: identityLoginSessionPtr->getIdentityProvider()];
    }
    else
    {
        [NSException raise:NSInvalidArgumentException format:@"Invalid Identity login session pointer!"];
    }
    return ret;
}

- (NSString*) getIdentityURI
{
    NSString* ret = nil;
    if(identityLoginSessionPtr)
    {
        ret = [NSString stringWithUTF8String: identityLoginSessionPtr->getIdentityURI()];
    }
    else
    {
        [NSException raise:NSInvalidArgumentException format:@"Invalid Identity login session pointer!"];
    }
    return ret;
}

- (NSString*) getClientToken
{
    NSString* ret = nil;
    if(identityLoginSessionPtr)
    {
        ret = [NSString stringWithUTF8String: identityLoginSessionPtr->getClientToken()];
    }
    else
    {
        [NSException raise:NSInvalidArgumentException format:@"Invalid Identity login session pointer!"];
    }
    return ret;
}

- (NSString*) getServerToken
{
    NSString* ret = nil;
    if(identityLoginSessionPtr)
    {
        ret = [NSString stringWithUTF8String: identityLoginSessionPtr->getServerToken()];
    }
    else
    {
        [NSException raise:NSInvalidArgumentException format:@"Invalid Identity login session pointer!"];
    }
    return ret;
}

- (NSString*) getClientLoginSecret
{
    NSString* ret = nil;
    if(identityLoginSessionPtr)
    {
        ret = [NSString stringWithUTF8String: identityLoginSessionPtr->getClientLoginSecret()];
    }
    else
    {
        [NSException raise:NSInvalidArgumentException format:@"Invalid Identity login session pointer!"];
    }
    return ret;
}

- (BOOL) isComplete
{
    BOOL ret = NO;
    if(identityLoginSessionPtr)
    {
        ret = identityLoginSessionPtr->isComplete();
    }
    else
    {
        [NSException raise:NSInvalidArgumentException format:@"Invalid Identity login session pointer!"];
    }
    
    return ret;
}

- (BOOL) wasSuccessful
{
    BOOL ret = NO;
    if(identityLoginSessionPtr)
    {
        ret = identityLoginSessionPtr->wasSuccessful();
    }
    else
    {
        [NSException raise:NSInvalidArgumentException format:@"Invalid Identity login session pointer!"];
    }
    
    return ret;
}

- (unsigned int) getErrorCode
{
    unsigned int ret = 0;
    
    if (identityLoginSessionPtr)
    {
        ret = identityLoginSessionPtr->getErrorCode();
    }
    else
    {
        [NSException raise:NSInvalidArgumentException format:@"Invalid Identity login session pointer!"];
    }
    return ret;
}

- (NSString*) getHiddenWindowBrowserURL
{
    NSString* ret = nil;
    if(identityLoginSessionPtr)
    {
        ret = [NSString stringWithUTF8String: identityLoginSessionPtr->getHiddenWindowBrowserURL()];
    }
    else
    {
        [NSException raise:NSInvalidArgumentException format:@"Invalid Identity login session pointer!"];
    }
    return ret;
}

- (NSDate*) getLoginExpires
{
    NSDate* date = nil;
    
    if(identityLoginSessionPtr)
    {
        date = [OpenPeerUtility convertPosixTimeToDate:identityLoginSessionPtr->getLoginExpires()];
    }
    else
    {
        [NSException raise:NSInvalidArgumentException format:@"Invalid Identity login session pointer!"];
    }
    return date;
}

- (NSString*) getIdentityReloginToken
{
    NSString* ret = nil;
    if(identityLoginSessionPtr)
    {
        ret = [NSString stringWithUTF8String: identityLoginSessionPtr->getIdentityReloginToken()];
    }
    else
    {
        [NSException raise:NSInvalidArgumentException format:@"Invalid Identity login session pointer!"];
    }
    return ret;
}

- (NSString*) getCustomLoginElement
{
    NSString* ret = nil;
    if(identityLoginSessionPtr)
    {
        zsLib::XML::ElementPtr element = identityLoginSessionPtr->getCustomLoginElement();
        if (element)
        {
            ret = [NSString stringWithUTF8String: IXML::convertToString(element)];
        }
    }
    else
    {
        [NSException raise:NSInvalidArgumentException format:@"Invalid Identity login session pointer!"];
    }
    return ret;
}

- (void) cancel
{
    if(identityLoginSessionPtr)
    {
        identityLoginSessionPtr->cancel();
    }
    else
    {
        [NSException raise:NSInvalidArgumentException format:@"Invalid Identity login session pointer!"];
    }
}

- (void) complete
{
    if(identityLoginSessionPtr)
    {
        identityLoginSessionPtr->complete();
    }
    else
    {
        [NSException raise:NSInvalidArgumentException format:@"Invalid Identity login session pointer!"];
    }
}

@end

#pragma mark - OpenpeerProvisioning_AccountIdentityLookupQuery.mm
@implementation OpenpeerProvisioning_AccountIdentityLookupQuery

- (void)dealloc
{
    [_identities release];
    [_contacts release];
    [_uniqueId release];
    [super dealloc];
}

- (void) setAccountIdentityLookupQueryPtr:(hookflash::provisioning2::IAccountIdentityLookupQueryPtr) inAccountIdentityLookupQueryPtr
{
    accountIdentityLookupQueryPtr = inAccountIdentityLookupQueryPtr;
    
}

- (hookflash::provisioning2::IAccountIdentityLookupQueryPtr) getAccountIdentityLookupQueryPtr
{
    return accountIdentityLookupQueryPtr;
}

- (BOOL) isComplete {
    
    BOOL ret = NO;
    
    if (accountIdentityLookupQueryPtr)
    {
        ret = accountIdentityLookupQueryPtr->isComplete();
    }
    else
    {
        [NSException raise:NSInvalidArgumentException format:@"Invalid OpenPeer identity lookup pointer!"];
    }
    return ret;
}

- (BOOL) didSucceed {
    
    BOOL ret = NO;
    
    if (accountIdentityLookupQueryPtr)
    {
        ret = accountIdentityLookupQueryPtr->didSucceed();
    }
    else
    {
        [NSException raise:NSInvalidArgumentException format:@"Invalid OpenPeer identity lookup pointer!"];
    }
    return ret;
}

- (void) cancel {
    
    if(accountIdentityLookupQueryPtr)
    {
        accountIdentityLookupQueryPtr->cancel();
    }
    else
    {
        [NSException raise:NSInvalidArgumentException format:@"Invalid OpenPeer identity lookup pointer!"];
    }
}

- (NSArray*) getIdentities
{
    if (accountIdentityLookupQueryPtr)
    {
        if (!self.identities)
        {
            self.identities = [[[NSMutableArray alloc] init] autorelease];
        
            provisioning2::IAccount::IdentityURIList identityList;
            accountIdentityLookupQueryPtr->getIdentities(identityList);
            if (identityList.size() > 0)
            {
                std::list<hookflash::provisioning2::IAccountIdentityLookupQuery::IdentityURI>::iterator it;
                for(it = identityList.begin(); it != identityList.end(); it++)
                {
                    [self.identities addObject:[NSString stringWithUTF8String:(*it)]];
                }
            }
        }
    }
    else
    {
        [NSException raise:NSInvalidArgumentException format:@"Invalid provisioning identity lookup pointer!"];
    }
    return self.identities;
}

- (NSArray*) getContacts
{
    return self.contacts;
}

- (OpenpeerIdentityLookupInfo*) getLookupInfo: (NSString*) inIdentity;
{
    OpenpeerIdentityLookupInfo* outInfo = nil;
    
    if (accountIdentityLookupQueryPtr)
    {        
        provisioning2::IAccount::IdentityLookupInfo profileInfo;
        
        bool passed = accountIdentityLookupQueryPtr->getLookupInfo([inIdentity UTF8String], profileInfo);
        if (passed)
        {
            outInfo.peerContactURI = [NSString stringWithUTF8String:profileInfo.mPeerContactURI];
            outInfo.publicPeerFileSecret = [NSString stringWithUTF8String:profileInfo.mPublicPeerFileSecret];
            outInfo.infoTTL = [OpenPeerUtility convertPosixTimeToDate:profileInfo.mInfoTTL];
            outInfo.profileLastUpdated = [OpenPeerUtility convertPosixTimeToDate:profileInfo.mProfileLastUpdated];
            outInfo.displayName = [NSString stringWithUTF8String:profileInfo.mDisplayName];
            outInfo.profileRenderedURL = [NSString stringWithUTF8String:profileInfo.mProfileRenderedURL];
            outInfo.profileProgrammaticURL = [NSString stringWithUTF8String:profileInfo.mProfileProgrammaticURL];
            
            if (profileInfo.mAvatars.size() > 0)
            {
                std::list<hookflash::provisioning2::IAccount::IdentityProfileAvatarInfo>::iterator it;
                for(it = profileInfo.mAvatars.begin(); it != profileInfo.mAvatars.end(); it++)
                {
                    OpenpeerIdentityProfileAvatarInfo* tmpAvatarInfo = [[OpenpeerIdentityProfileAvatarInfo alloc] init];
                    
                    tmpAvatarInfo.avatarName = [NSString stringWithUTF8String:it->mAvatarName];
                    tmpAvatarInfo.avatarURL = [NSString stringWithUTF8String:it->mAvatarURL];

                    tmpAvatarInfo.pixelWidth = it->mPixelWidth;
                    tmpAvatarInfo.pixelHeight = it->mPixelHeight;
                    
                    [outInfo.avatars addObject:tmpAvatarInfo];
                    [tmpAvatarInfo autorelease];
                }
            }
        }
    }
    else
    {
        [NSException raise:NSInvalidArgumentException format:@"Invalid provisioning identity lookup pointer!"];
    }
    
    return [outInfo autorelease];
}

@end

#pragma mark - OpenpeerProvisioning_AccountPeerFileLookupQuery.mm
@implementation OpenpeerProvisioning_AccountPeerFileLookupQuery

- (void) setAccountPeerFileLookupQueryPtr:(hookflash::provisioning2::IAccountPeerFileLookupQueryPtr) inAccountPeerFileLookupQueryPtr
{
    accountPeerFileLookupQueryPtr = inAccountPeerFileLookupQueryPtr;
    
}
- (hookflash::provisioning2::IAccountPeerFileLookupQueryPtr) getAccountPeerFileLookupQueryPtr
{
    return accountPeerFileLookupQueryPtr;
}

- (BOOL) isComplete {
    
    BOOL ret = NO;
    
    if (accountPeerFileLookupQueryPtr)
    {
        ret = accountPeerFileLookupQueryPtr->isComplete();
    }
    else
    {
        [NSException raise:NSInvalidArgumentException format:@"Invalid OpenPeer peer file lookup pointer!"];
    }
    return ret;
}

- (BOOL) didSucceed {
    
    BOOL ret = NO;
    
    if (accountPeerFileLookupQueryPtr)
    {
        ret = accountPeerFileLookupQueryPtr->didSucceed();
    }
    else
    {
        [NSException raise:NSInvalidArgumentException format:@"Invalid OpenPeer peer file lookup pointer!"];
    }
    return ret;
}

- (void) cancel {
    
    if(accountPeerFileLookupQueryPtr)
    {
        accountPeerFileLookupQueryPtr->cancel();
    }
    else
    {
        [NSException raise:NSInvalidArgumentException format:@"Invalid OpenPeer peer file lookup pointer!"];
    }
}

- (NSArray*) getPeerContactURIs
{
    NSMutableArray* ret = nil;
    
    if (accountPeerFileLookupQueryPtr)
    {
        provisioning2::IAccount::PeerContactURIList peerContactURIs;
        accountPeerFileLookupQueryPtr->getPeerContactURIs(peerContactURIs);
        
        if (peerContactURIs.size() > 0)
        {
            ret = [[NSMutableArray alloc] init];
            
            std::list<provisioning2::IAccountPeerFileLookupQuery::PeerContactURI>::iterator it;
            
            for ( it=peerContactURIs.begin() ; it != peerContactURIs.end(); it++ )
            {
                NSString* userId = [NSString stringWithUTF8String:*it];
                [ret addObject:userId];
            }
        }
    }
    else
    {
        [NSException raise:NSInvalidArgumentException format:@"Invalid OpenPeer peer file lookup pointer!"];
    }
    return [ret autorelease];
}

- (NSString*) getPublicPeerFileAsString: (NSString*) userID
{
    
    NSString* publicPeerFileString = nil;
    
    if(accountPeerFileLookupQueryPtr)
    {
        publicPeerFileString = [NSString stringWithUTF8String: accountPeerFileLookupQueryPtr->getPublicPeerFileAsString([userID UTF8String])];
    }
    else
    {
        [NSException raise:NSInvalidArgumentException format:@"Invalid OpenPeer peer file lookup pointer!"];
    }
    return publicPeerFileString;
}

@end

#pragma mark - OpenPeerProvisioningAccountDelegate_ForFutureUse.mm

OpenPeerProvisioningAccountDelegate_ForFutureUse::OpenPeerProvisioningAccountDelegate_ForFutureUse(id<HOPOpenpeerProvisioningAccountDelegate> inProvisioningAccountDelegate)
{
    provisioningAccountDelegate = inProvisioningAccountDelegate;
}

boost::shared_ptr<OpenPeerProvisioningAccountDelegate_ForFutureUse> OpenPeerProvisioningAccountDelegate_ForFutureUse::create(id<HOPOpenpeerProvisioningAccountDelegate> inProvisioningAccountDelegate)
{
    return boost::shared_ptr<OpenPeerProvisioningAccountDelegate_ForFutureUse> (new OpenPeerProvisioningAccountDelegate_ForFutureUse(inProvisioningAccountDelegate));
}

HOPProvisioningAccount_ForFutureUse* OpenPeerProvisioningAccountDelegate_ForFutureUse::getOpenPeerProvisioningAccount(provisioning2::IAccountPtr account)
{
    HOPProvisioningAccount_ForFutureUse * hopProvisioningAccount = nil;
    
//    NSString* userId = [NSString stringWithUTF8String:account->getUserID()];
//    if (userId)
//    {
//        hopProvisioningAccount = [[OpenPeerStorageManager sharedStorageManager] getProvisioningAccountForUserId:userId];
//    }
    return hopProvisioningAccount;
}

void OpenPeerProvisioningAccountDelegate_ForFutureUse::onProvisioningAccountStateChanged(hookflash::provisioning2::IAccountPtr account,provisioning2::IAccount::AccountStates state)
{
    [provisioningAccountDelegate onProvisioningAccountStateChanged:[HOPProvisioningAccount_ForFutureUse sharedInstance] accountStates:(OpenpeerProvisioning_AccountStates) state];
    
//    if (state == provisioning::IAccount::AccountState_Shutdown) {
//        [[HOPProvisioningAccount sharedProvisioningAccount] deleteLocalDelegates];
//    }
}

void OpenPeerProvisioningAccountDelegate_ForFutureUse::onProvisioningAccountError(provisioning2::IAccountPtr account,provisioning2::IAccount::AccountErrorCodes error)
{
    [provisioningAccountDelegate onProvisioningAccountError:[HOPProvisioningAccount_ForFutureUse sharedInstance] errorCodes:(OpenpeerProvisioning_AccountErrorCodes) error];
}

void OpenPeerProvisioningAccountDelegate_ForFutureUse::onProvisioningAccountPrivatePeerFileChanged(provisioning2::IAccountPtr account)
{
    [provisioningAccountDelegate onProvisioningAccountPrivatePeerFileChanged:[HOPProvisioningAccount_ForFutureUse sharedInstance]];
}

void OpenPeerProvisioningAccountDelegate_ForFutureUse::onProvisioningAccountIdentitiesChanged(provisioning2::IAccountPtr account)
{
    
}

void OpenPeerProvisioningAccountDelegate_ForFutureUse::onAccountStateChanged(hookflash::IAccountPtr account, hookflash::IAccount::AccountStates state)
{
    //check if openpeer account is existing
    if (account) {
        //in case openpeer account is shutting down, error code will be filled so we can throw error event. later on, provisioning account will throw state change
        if ((account->getState() == hookflash::IAccount::AccountState_ShuttingDown) || (account->getState() == hookflash::IAccount::AccountState_Shutdown)) {
            [provisioningAccountDelegate onProvisioningAccountError:[HOPProvisioningAccount_ForFutureUse sharedInstance] errorCodes:(OpenpeerProvisioning_AccountErrorCodes)account->getLastError()];
        }
    }
}

#pragma mark - OpenPeerAccountIdentityLookupQueryDelegate_ForFutureUse.mm
#import "HOPContact_Internal.h"

OpenPeerAccountIdentityLookupQueryDelegate_ForFutureUse::OpenPeerAccountIdentityLookupQueryDelegate_ForFutureUse(id<OpenpeerProvisioning_AccountIdentityLookupQueryDelegate> inAccountIdentityLookupQueryDelegate)
{
    accountIdentityLookupQueryDelegate = inAccountIdentityLookupQueryDelegate;
}

boost::shared_ptr<OpenPeerAccountIdentityLookupQueryDelegate_ForFutureUse> OpenPeerAccountIdentityLookupQueryDelegate_ForFutureUse::create(id<OpenpeerProvisioning_AccountIdentityLookupQueryDelegate> inAccountIdentityLookupQueryDelegate)
{
    return boost::shared_ptr<OpenPeerAccountIdentityLookupQueryDelegate_ForFutureUse> (new OpenPeerAccountIdentityLookupQueryDelegate_ForFutureUse(inAccountIdentityLookupQueryDelegate));
}

void OpenPeerAccountIdentityLookupQueryDelegate_ForFutureUse::onAccountIdentityLookupQueryComplete(provisioning2::IAccountIdentityLookupQueryPtr query)
{
    OpenpeerProvisioning_AccountIdentityLookupQuery* hopQuery = [[HOPProvisioningAccount_ForFutureUse sharedInstance] getProvisioningAccountIdentityLookupQueryForUniqueId:[NSNumber numberWithUnsignedLong:query->getID()]];
    
    if([hopQuery isComplete] && [hopQuery didSucceed])
    {
        if (!hopQuery.contacts)
            hopQuery.contacts = [[[NSMutableArray alloc] init] autorelease];
        else
            [hopQuery.contacts removeAllObjects];
        
        //NSMutableSet* setOfContacts = [[NSMutableSet alloc] init];
        for(NSString* identity in [hopQuery getIdentities])
        {
            OpenpeerIdentityLookupInfo* lookupProfileInfo = [hopQuery getLookupInfo:identity];
            
            if (lookupProfileInfo)
            {
                //HOP_TODO: HOPContact add dictionary for identities object hopidentiy key providerid
                HOPContact* contact = [[OpenPeerStorageManager sharedStorageManager] getContactForId:lookupProfileInfo.peerContactURI];
                if (!contact)
                {
                    contact = [[[HOPContact alloc] initWithPeerFile:nil userId:lookupProfileInfo.peerContactURI contactId:lookupProfileInfo.peerContactURI] autorelease];
                    [[OpenPeerStorageManager sharedStorageManager] setContact:contact withContactId:lookupProfileInfo.peerContactURI andUserId:lookupProfileInfo.peerContactURI];
                }
                
                //[contact.identitiesDictionary setObject:identity forKey:[NSNumber numberWithInt:identity.identityType]];
                //contact.lastProfileUpdateTimestamp = lookupProfileInfo.lastProfileUpdateTimestamp;
                
                [hopQuery.contacts addObject:contact];
            }
        }
    }
    
    [accountIdentityLookupQueryDelegate onAccountIdentityLookupQueryComplete:hopQuery];
}

#pragma mark - xxx

OpenPeerAccountPeerFileLookupQueryDelegate_ForFutureUse::OpenPeerAccountPeerFileLookupQueryDelegate_ForFutureUse(id<OpenpeerProvisioning_AccountPeerFileLookupQueryDelegate> inAccountPeerFileLookupQueryDelegate)
{
    accountPeerFileLookupQueryDelegate = inAccountPeerFileLookupQueryDelegate;
}

boost::shared_ptr<OpenPeerAccountPeerFileLookupQueryDelegate_ForFutureUse> OpenPeerAccountPeerFileLookupQueryDelegate_ForFutureUse::create(id<OpenpeerProvisioning_AccountPeerFileLookupQueryDelegate> inAccountPeerFileLookupQueryDelegate)
{
    return boost::shared_ptr<OpenPeerAccountPeerFileLookupQueryDelegate_ForFutureUse> (new OpenPeerAccountPeerFileLookupQueryDelegate_ForFutureUse(inAccountPeerFileLookupQueryDelegate));
}

void OpenPeerAccountPeerFileLookupQueryDelegate_ForFutureUse::onAccountPeerFileLookupQueryComplete(provisioning2::IAccountPeerFileLookupQueryPtr query)
{
    OpenpeerProvisioning_AccountPeerFileLookupQuery* hopQuery = [[HOPProvisioningAccount_ForFutureUse sharedInstance] getProvisioningAccountPeerFileLookupQueryForUniqueId:[NSNumber numberWithUnsignedLong:query->getID()]];
    
    if([hopQuery isComplete] && [hopQuery didSucceed])
    {
        for (NSString* userId in [hopQuery getPeerContactURIs])
        {
            HOPContact* contact = [[OpenPeerStorageManager sharedStorageManager] getContactForUserId:userId];
            if (contact)
            {
                NSString* peerFile = [hopQuery getPublicPeerFileAsString:userId];
                [contact createCoreContactWithPeerFile:peerFile];
            }
        }
    }
    
    [accountPeerFileLookupQueryDelegate onAccountPeerFileLookupQueryComplete:hopQuery];
}

#pragma mark - OpenPeerIdentityLoginSessionDelegate_ForFutureUse.mm

OpenPeerIdentityLoginSessionDelegate_ForFutureUse::OpenPeerIdentityLoginSessionDelegate_ForFutureUse(id<OpenpeerProvisioning_IdentityLoginSessionDelegate> inIdentityLoginSessionDelegate)
{
    identityLoginSessionDelegate = inIdentityLoginSessionDelegate;
}

boost::shared_ptr<OpenPeerIdentityLoginSessionDelegate_ForFutureUse> OpenPeerIdentityLoginSessionDelegate_ForFutureUse::create(id<OpenpeerProvisioning_IdentityLoginSessionDelegate> inIdentityLoginSessionDelegate)
{
    return boost::shared_ptr<OpenPeerIdentityLoginSessionDelegate_ForFutureUse> (new OpenPeerIdentityLoginSessionDelegate_ForFutureUse(inIdentityLoginSessionDelegate));

}

void OpenPeerIdentityLoginSessionDelegate_ForFutureUse::onIdentityLoginSessionBrowserWindowRequired(provisioning2::IIdentityLoginSessionPtr session)
{
    //[identityLoginSessionDelegate onIdentityLoginSessionBrowserWindowRequired:[OpenpeerProvisioning_IdentityLoginSession sharedInstance]];
}

void OpenPeerIdentityLoginSessionDelegate_ForFutureUse::onIdentityLoginSessionCompleted(provisioning2::IIdentityLoginSessionPtr session)
{
    
}
