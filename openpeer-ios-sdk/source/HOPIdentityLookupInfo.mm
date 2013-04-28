/*
 
 Copyright (c) 2013, SMB Phone Inc.
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

#include "HOPIdentityLookupInfo_Internal.h"
#include "OpenPeerUtility.h"
#include "OpenPeerStorageManager.h"
#include "HOPContact_Internal.h"
#import <hookflash/core/IContact.h>

@implementation HOPIdentityLookupInfo

- (id)init
{
    self = [super init];
    if (self)
    {
        self.avatars = [[NSMutableArray alloc] init];
    }
    return self;
}

- (id) initWithIdentityLookupInfo:(IdentityLookupInfo) inIdentityLookupInfo
{
    self = [self init];
    if (self)
    {
        if (inIdentityLookupInfo.hasData())
        {
            NSString* contactId = [NSString stringWithCString:inIdentityLookupInfo.mContact->getStableUniqueID() encoding:NSUTF8StringEncoding];
            if (contactId)
                self.contact = [[OpenPeerStorageManager sharedStorageManager] getContactForId:contactId];
    
            self.identityURI = [NSString stringWithCString:inIdentityLookupInfo.mIdentityURI encoding:NSUTF8StringEncoding];
            self.userID = [NSString stringWithCString:inIdentityLookupInfo.mUserID encoding:NSUTF8StringEncoding];
            
            self.priority = inIdentityLookupInfo.mPriority;
            self.weight = inIdentityLookupInfo.mWeight;
            
            self.lastUpdated = [OpenPeerUtility convertPosixTimeToDate:inIdentityLookupInfo.mLastUpdated];
            self.expires = [OpenPeerUtility convertPosixTimeToDate:inIdentityLookupInfo.mExpires];
            
            self.name = [NSString stringWithCString:inIdentityLookupInfo.mName encoding:NSUTF8StringEncoding];
            self.profileURL = [NSString stringWithCString:inIdentityLookupInfo.mProfileURL encoding:NSUTF8StringEncoding];
            self.vProfileURL = [NSString stringWithCString:inIdentityLookupInfo.mVProfileURL encoding:NSUTF8StringEncoding];
            
        }
    }
    return self;
}


@end