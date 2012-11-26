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


#import "HOPProvisioningAccountIdentityLookupQuery.h"
#import "HOPProvisioningAccountIdentityLookupQuery_Internal.h"
#import "HOPIdentity.h"
#import "HOPLookupProfileInfo.h"
#import "OpenPeerUtility.h"

@implementation HOPProvisioningAccountIdentityLookupQuery

- (void) setAccountIdentityLookupQueryPtr:(IAccountIdentityLookupQueryPtr) inAccountIdentityLookupQueryPtr
{
  accountIdentityLookupQueryPtr = inAccountIdentityLookupQueryPtr;
  
}
- (IAccountIdentityLookupQueryPtr) getAccountIdentityLookupQueryPtr
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

- (void) getIdentities: (NSArray*) outIdentities {
  
  if (accountIdentityLookupQueryPtr)
  {
    if ([outIdentities count] > 0)
    {
      provisioning::IAccount::IdentityIDList identityList;
      for (HOPIdentity* identity in outIdentities)
      {
        provisioning::IAccount::IdentityID identityID;
        identityID.first = (provisioning::IAccount::IdentityTypes)identity.identityType;
        identityID.second = [identity.identityId UTF8String];
        identityList.push_back(identityID);
      }
      accountIdentityLookupQueryPtr->getIdentities(identityList);
    }
  }
  else
  {
    [NSException raise:NSInvalidArgumentException format:@"Invalid provisioning identity lookup pointer!"];
  }
}

- (BOOL) getLookupProfile: (HOPIdentity*) inIdentity outInfo: (HOPLookupProfileInfo*) outInfo {
  
  BOOL ret = NO;
  
  if (accountIdentityLookupQueryPtr)
  {
    provisioning::IAccount::IdentityID identityID;
    identityID.first = (provisioning::IAccount::IdentityTypes)inIdentity.identityType;
    identityID.second = [inIdentity.identityId UTF8String];

    provisioning::IAccount::LookupProfileInfo profileInfo;

    ret = accountIdentityLookupQueryPtr->getLookupProfile(identityID, profileInfo);
    
    outInfo.type = (HOPProvisioningAccountIdentityTypes) profileInfo.mIdentityType;
    outInfo.identityUniqueId = [NSString stringWithUTF8String: profileInfo.mIdentityUniqueID];
    outInfo.userId = [NSString stringWithUTF8String: profileInfo.mUserID];
    outInfo.contactId = [NSString stringWithUTF8String: profileInfo.mContactID];
    outInfo.lastProfileUpdateTimestamp = [OpenPeerUtility convertPosixTimeToDate: profileInfo.mLastProfileUpdateTimestamp];
    outInfo.priority = profileInfo.mPriority;
    outInfo.weight = profileInfo.mWeight;
    outInfo.avatarURL = [NSString stringWithUTF8String: profileInfo.mAvatarURL];
  }
  else
  {
    [NSException raise:NSInvalidArgumentException format:@"Invalid provisioning identity lookup pointer!"];
  }
  
  return ret;
}

@end
