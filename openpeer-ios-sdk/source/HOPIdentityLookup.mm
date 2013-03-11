
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


#import "HOPIdentityLookup_Internal.h"
#import <hookflash/core/IIdentityLookup.h>
#import "OpenPeerStorageManager.h"
#import "HOPAccount_Internal.h"

@implementation HOPIdentityLookupResult

@end

@implementation HOPIdentityLookup

- (id) initWithDelegate:(id<HOPIdentityLookupDelegate>) inDelegate identityURIList:(NSString*) inIdentityURIList
{
    self = [super init];
    if (self)
    {
        IdentityURIList identityURIList;
        [self setLocalDelegates:inDelegate];
        if ([inIdentityURIList length] > 0)
            [self convertString:inIdentityURIList toIdentityURIList:&identityURIList];
        IIdentityLookup::create([[HOPAccount sharedAccount] getAccountPtr], openPeerIdentityLookupDelegatePtr, identityURIList);
    }
    return self;
}

- (BOOL) isComplete
{
    BOOL ret = NO;
    
    if(identityLookupPtr)
    {
        ret = identityLookupPtr->isComplete();
    }
    else
    {
        [NSException raise:NSInvalidArgumentException format:@"Invalid identity lookup object!"];
    }
    
    return ret;
}

- (HOPIdentityLookupResult*) getLookupResult
{
    HOPIdentityLookupResult* ret = nil;
    
    if(identityLookupPtr)
    {
        ret = [[HOPIdentityLookupResult alloc] init];
        WORD errorCode;
        String errorReason;
        ret.wasSuccessful  = identityLookupPtr->wasSuccessful(&errorCode, &errorReason);
        ret.errorCode = errorCode;
        ret.errorReason = [NSString stringWithUTF8String:errorReason];
    }
    else
    {
        [NSException raise:NSInvalidArgumentException format:@"Invalid identity lookup object!"];
    }
    
    return ret;
}

- (void) cancel
{
    if(identityLookupPtr)
    {
        identityLookupPtr->cancel();
    }
    else
    {
        [NSException raise:NSInvalidArgumentException format:@"Invalid identity lookup object!"];
    }
}

- (NSArray*) getIdentities
{
    return [[OpenPeerStorageManager sharedStorageManager] getIdentities];
}

- (NSString *)description
{
    NSString* ret = nil;
    
    if (identityLookupPtr)
        ret = [NSString stringWithUTF8String: IIdentityLookup::toDebugString(identityLookupPtr,NO)];
    else
        ret = NSLocalizedString(@"Identity lookup object is not created.", @"Identity lookup  object is not created.");
    
    return ret;
}

#pragma mark - Internal
- (void) setLocalDelegates:(id<HOPIdentityLookupDelegate>) inIdentityLookupDelegate
{
    openPeerIdentityLookupDelegatePtr = OpenPeerIdentityLookupDelegate::create(inIdentityLookupDelegate);
}

- (void) convertString:(NSString*) indentityURIListStr toIdentityURIList:(IdentityURIList*) outIdentityURIList
{
    NSArray* uris = [indentityURIListStr componentsSeparatedByString:@","];
    
    for (NSString* uri in uris)
    {
        IdentityURI identityURI = [uri UTF8String];
        outIdentityURIList->push_back(identityURI);
    }
}

- (IIdentityLookupPtr) getIdentityLookupPtr
{
    return identityLookupPtr;
}
@end