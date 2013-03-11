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


#import "HOPProvisioningAccountOAuthIdentityAssociation_Internal.h"
#import "HOPProvisioningAccountOAuthIdentityAssociation.h"
#import <hookflash/core/IHelper.h>

@implementation HOPProvisioningAccountOAuthIdentityAssociation

#pragma mark - Internal methods
- (void) setAccountOAuthIdentityAssociationPtr:(IIdentityPtr) inAccountOAuthIdentityAssociationPtr
{
    accountOAuthIdentityAssociationPtr = inAccountOAuthIdentityAssociationPtr;
}
- (IIdentityPtr) getAccountOAuthIdentityAssociationPtr
{
    return accountOAuthIdentityAssociationPtr;
}

- (BOOL) isComplete {
  
  BOOL ret = NO;
  
  if (accountOAuthIdentityAssociationPtr)
  {
      //ret = accountOAuthIdentityAssociationPtr->isComplete();
  }
  else
  {
    [NSException raise:NSInvalidArgumentException format:@"Invalid OpenPeer OAuth identity association pointer!"];
  }
  return ret;
}

- (BOOL) didSucceed {
  
  BOOL ret = NO;
  
  if (accountOAuthIdentityAssociationPtr)
  {
      //ret = accountOAuthIdentityAssociationPtr->didSucceed();
  }
  else
  {
    [NSException raise:NSInvalidArgumentException format:@"Invalid OpenPeer OAuth identity association pointer!"];
  }
  return ret;
}

- (void) cancel {
  
  if(accountOAuthIdentityAssociationPtr)
  {
    accountOAuthIdentityAssociationPtr->cancel();
  }
  else
  {
    [NSException raise:NSInvalidArgumentException format:@"Invalid OpenPeer OAuth identity association pointer!"];
  }
}

- (NSString*) getOAuthLoginURL {
  
  NSString* loginURL = nil;
  
  if(accountOAuthIdentityAssociationPtr)
  {
      //loginURL = [NSString stringWithUTF8String: accountOAuthIdentityAssociationPtr->getOAuthLoginURL()];
  }
  else
  {
    [NSException raise:NSInvalidArgumentException format:@"Invalid OpenPeer OAuth identity association pointer!"];
  }
  return loginURL;
}

- (HOPProvisioningAccountIdentityTypes) getProviderType {
  
  HOPProvisioningAccountIdentityTypes providerType = HOPProvisioningAccountIdentityTypeNone;
  if(accountOAuthIdentityAssociationPtr)
  {
      //providerType = (HOPProvisioningAccountIdentityTypes)accountOAuthIdentityAssociationPtr->getProviderType();
  }
  else
  {
    [NSException raise:NSInvalidArgumentException format:@"Invalid OpenPeer OAuth identity association pointer!"];
  }
  
  return providerType;
}

- (NSString*) getProviderUniqueID {
  
  NSString* providerUniqueId = nil;
  
  if(accountOAuthIdentityAssociationPtr)
  {
      //providerUniqueId = [NSString stringWithUTF8String: accountOAuthIdentityAssociationPtr->getProviderUniqueID()];
  }
  else
  {
    [NSException raise:NSInvalidArgumentException format:@"Invalid OpenPeer OAuth identity association pointer!"];
  }
  return providerUniqueId;
}

- (NSString*) getProviderOAuthAccessToken {
  
  NSString* accessToken = nil;
  
  if(accountOAuthIdentityAssociationPtr)
  {
      //accessToken = [NSString stringWithUTF8String: accountOAuthIdentityAssociationPtr->getProviderOAuthAccessToken()];
  }
  else
  {
    [NSException raise:NSInvalidArgumentException format:@"Invalid OpenPeer OAuth identity association pointer!"];
  }
  return accessToken;
}

- (NSString*) getProviderEncryptedOAuthAccessSecret {
  
  NSString* encryptedAccessSecret = nil;
  
  if(accountOAuthIdentityAssociationPtr)
  {
      //encryptedAccessSecret = [NSString stringWithUTF8String: accountOAuthIdentityAssociationPtr->getProviderEncryptedOAuthAccessSecret()];
  }
  else
  {
    [NSException raise:NSInvalidArgumentException format:@"Invalid OpenPeer OAuth identity association pointer!"];
  }
  return encryptedAccessSecret;
}

- (void) completeOAuthLoginProcess: (NSString*) xmlResultFromJavascript {
  
  if(accountOAuthIdentityAssociationPtr)
  {
      //accountOAuthIdentityAssociationPtr->completeOAuthLoginProcess(IHelper::createFromString([xmlResultFromJavascript UTF8String]));
  }
  else
  {
    [NSException raise:NSInvalidArgumentException format:@"Invalid OpenPeer OAuth identity association pointer!"];
  }
}

@end
