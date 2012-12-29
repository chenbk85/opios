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


#import "OpenPeerAccountIdentityLookupQueryDelegate.h"
#import "HOPProvisioningAccountIdentityLookupQuery_Internal.h"
#import "HOPProvisioningAccount_Internal.h"
#import "OpenPeerStorageManager.h"
#import "HOPLookupProfileInfo.h"
#import "HOPContact_Internal.h"
#import "HOPIdentity.h"

OpenPeerAccountIdentityLookupQueryDelegate::OpenPeerAccountIdentityLookupQueryDelegate(id<HOPProvisioningAccountIdentityLookupQueryDelegate> inAccountIdentityLookupQueryDelegate)
{
    accountIdentityLookupQueryDelegate = inAccountIdentityLookupQueryDelegate;
}

boost::shared_ptr<OpenPeerAccountIdentityLookupQueryDelegate> OpenPeerAccountIdentityLookupQueryDelegate::create(id<HOPProvisioningAccountIdentityLookupQueryDelegate> inAccountIdentityLookupQueryDelegate)
{
    return boost::shared_ptr<OpenPeerAccountIdentityLookupQueryDelegate> (new OpenPeerAccountIdentityLookupQueryDelegate(inAccountIdentityLookupQueryDelegate));
}

void OpenPeerAccountIdentityLookupQueryDelegate::onAccountIdentityLookupQueryComplete(IAccountIdentityLookupQueryPtr query)
{
    HOPProvisioningAccountIdentityLookupQuery* hopQuery = [[HOPProvisioningAccount sharedProvisioningAccount] getProvisioningAccountIdentityLookupQueryForUniqueId:[NSNumber numberWithUnsignedLong:query->getID()]];
    
    if([hopQuery isComplete] && [hopQuery didSucceed])
    {
        if (!hopQuery.contacts)
            hopQuery.contacts = [[[NSMutableArray alloc] init] autorelease];
        else
            [hopQuery.contacts removeAllObjects];
        
        //NSMutableSet* setOfContacts = [[NSMutableSet alloc] init];
        for(HOPIdentity* identity in [hopQuery getIdentities])
        {
            HOPLookupProfileInfo* lookupProfileInfo = [hopQuery getLookupProfile:identity];
           
            if (lookupProfileInfo)
            {
                //HOP_TODO: HOPContact add dictionary for identities object hopidentiy key providerid
                HOPContact* contact = [[OpenPeerStorageManager sharedStorageManager] getContactForId:lookupProfileInfo.contactId];
                if (!contact)
                {
                    contact = [[[HOPContact alloc] initWithPeerFile:nil userId:lookupProfileInfo.userId contactId:lookupProfileInfo.contactId] autorelease];
                    [[OpenPeerStorageManager sharedStorageManager] setContact:contact withContactId:lookupProfileInfo.contactId andUserId:lookupProfileInfo.userId];
                }
               
                [contact.identitiesDictionary setObject:identity forKey:[NSNumber numberWithInt:identity.identityType]];
                //contact.lastProfileUpdateTimestamp = lookupProfileInfo.lastProfileUpdateTimestamp;
                
                [hopQuery.contacts addObject:contact];
            }
        }
    }

    [accountIdentityLookupQueryDelegate onAccountIdentityLookupQueryComplete:hopQuery];
}