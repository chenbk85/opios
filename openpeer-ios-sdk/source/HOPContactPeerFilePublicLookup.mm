
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


#import "HOPContactPeerFilePublicLookup_Internal.h"
#import <hookflash/core/IContactPeerFilePublicLookup.h>
#import "OpenPeerStorageManager.h"
#import "HOPContact_Internal.h"

@implementation HOPContactPeerFilePublicLookupResult

@end

@implementation HOPContactPeerFilePublicLookup

- (id) initWithDelegate:(id<HOPContactPeerFilePublicLookupDelegate>) inDelegate contactsList:(NSArray*) inContactList
{
    self = [super init];
    if (self)
    {
        ContactList contactsList;
        [self setLocalDelegates:inDelegate];
        [self convertArrayOfContacts:inContactList toContactList:&contactsList];
        IContactPeerFilePublicLookup::create(openPeerContactPeerFilePublicLookupDelegatePtr, contactsList);
    }
    return self;
}

- (BOOL) isComplete;
{
    BOOL ret = NO;
    
    if(contactPeerFilePublicLookupPtr)
    {
        ret = contactPeerFilePublicLookupPtr->isComplete();
    }
    else
    {
        [NSException raise:NSInvalidArgumentException format:@"Invalid contact peer file lookup object!"];
    }
    
    return ret;
}

- (HOPContactPeerFilePublicLookupResult*) getLookupResult
{
    HOPContactPeerFilePublicLookupResult* ret = nil;
    
    if(contactPeerFilePublicLookupPtr)
    {
        ret = [[HOPContactPeerFilePublicLookupResult alloc] init];
        WORD errorCode;
        String errorReason;
        ret.wasSuccessful  = contactPeerFilePublicLookupPtr->wasSuccessful(&errorCode, &errorReason);
        ret.errorCode = errorCode;
        ret.errorReason = [NSString stringWithUTF8String:errorReason];
    }
    else
    {
        [NSException raise:NSInvalidArgumentException format:@"Invalid contact peer file lookup object!"];
    }
    
    return ret;
}

- (void) cancel
{
    if(contactPeerFilePublicLookupPtr)
    {
        contactPeerFilePublicLookupPtr->cancel();
    }
    else
    {
        [NSException raise:NSInvalidArgumentException format:@"Invalid contact peer file lookup object!"];
    }
}

- (NSArray*) getContacts
{
    return nil;
}

- (NSString *)description
{
    NSString* ret = nil;
    
    if (contactPeerFilePublicLookupPtr)
        ret = [NSString stringWithUTF8String: IContactPeerFilePublicLookup::toDebugString(contactPeerFilePublicLookupPtr,NO)];
    else
        ret = NSLocalizedString(@"Contact peer file lookup object is not created.", @"Contact peer file lookup  object is not created.");
    
    return ret;
}

#pragma mark - Internal

- (void)setLocalDelegates:(id<HOPContactPeerFilePublicLookupDelegate>)inContactPeerFilePublicLookupDelegate
{
    openPeerContactPeerFilePublicLookupDelegatePtr = OpenPeerContactPeerFilePublicLookupDelegate::create(inContactPeerFilePublicLookupDelegate);
}

- (void) convertArrayOfContacts:(NSArray*) arrayOfContacts toContactList:(ContactList*) outContactList
{
    for (HOPContact* contact in arrayOfContacts)
    {
        if ([contact getContactPtr])
        {
            outContactList->push_back([contact getContactPtr]);
        }
    }
}
- (IContactPeerFilePublicLookupPtr)getContactPeerFilePublicLookupPtr
{
    return contactPeerFilePublicLookupPtr;
}
@end