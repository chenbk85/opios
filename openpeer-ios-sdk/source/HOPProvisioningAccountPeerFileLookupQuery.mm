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


#import "HOPProvisioningAccountPeerFileLookupQuery.h"
#import "HOPProvisioningAccountPeerFileLookupQuery_Internal.h"

@implementation HOPProvisioningAccountPeerFileLookupQuery

- (void) setAccountPeerFileLookupQueryPtr:(IAccountPeerFileLookupQueryPtr) inAccountPeerFileLookupQueryPtr
{
  accountPeerFileLookupQueryPtr = inAccountPeerFileLookupQueryPtr;
  
}
- (IAccountPeerFileLookupQueryPtr) getAccountPeerFileLookupQueryPtr
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

- (NSArray*) getUserIDs
{
    NSMutableArray* ret = nil;
  
    if (accountPeerFileLookupQueryPtr)
    {
        provisioning::IAccount::UserIDList userIDList;
        accountPeerFileLookupQueryPtr->getUserIDs(userIDList);
        
        if (userIDList.size() > 0)
        {
            ret = [[NSMutableArray alloc] init];
    
            std::list<provisioning::IAccountPeerFileLookupQuery::UserID>::iterator it;
        
            for ( it=userIDList.begin() ; it != userIDList.end(); it++ )
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

- (NSString*) getPublicPeerFileString: (NSString*) userID
{
  
  NSString* publicPeerFileString = nil;
  
  if(accountPeerFileLookupQueryPtr)
  {
    publicPeerFileString = [NSString stringWithUTF8String: accountPeerFileLookupQueryPtr->getPublicPeerFileString([userID UTF8String])];
  }
  else
  {
    [NSException raise:NSInvalidArgumentException format:@"Invalid OpenPeer peer file lookup pointer!"];
  }
  return publicPeerFileString;
}

@end
