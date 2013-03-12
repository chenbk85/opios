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


#import "HOPContact.h"
#import "HOPAccount_Internal.h"
#import <hookflash/core/IContact.h>
#import <hookflash/core/IHelper.h>
#import "HOPContact_Internal.h"
#import "OpenPeerStorageManager.h"

@implementation HOPContact

- (id)init
{
    //[self release];
    [NSException raise:NSInvalidArgumentException format:@"Don't use init for object creation. Use class method contactWithPeerFile."];
    return nil;
}

- (id) initWithCoreContact:(IContactPtr) inContactPtr
{
    self = [super init];
    if (self)
    {
        coreContactPtr = inContactPtr;
    }
    return self;
}

- (id) initWithPeerFile:(NSString*) publicPeerFile previousStableUniqueID:(NSString*) previousStableUniqueID
{
    self = [super init];
    
    if (self)
    {
        if ([publicPeerFile length] > 0 && [previousStableUniqueID length] > 0)
        {
            ElementPtr publicPeerXml = IHelper::createFromString([publicPeerFile UTF8String]);
            
            IContactPtr tempCoreContactPtr = IContact::createFromPeerFilePublic([[HOPAccount sharedAccount] getAccountPtr], publicPeerXml, [previousStableUniqueID UTF8String]);
                
                if (tempCoreContactPtr)
                {
                    //self.peerFile = publicPeerFile;
                    coreContactPtr = tempCoreContactPtr;
                }
        }
        else
        {
            //[self release];
            self = nil;
        }
    }

    return self;
}

- (id) initFromPeerURI:(NSString*) peerURI findSecret:(NSString*) findSecret previousStableUniqueID:(NSString*) previousStableUniqueID
{
    self = [super init];
    
    if (self)
    {
        if ([peerURI length] > 0 && [findSecret length] > 0)
        {
            
            IContactPtr tempCoreContactPtr = IContact::createFromPeerURI([[HOPAccount sharedAccount] getAccountPtr], [peerURI UTF8String], [findSecret UTF8String], [previousStableUniqueID length] > 0 ? [previousStableUniqueID UTF8String] : NULL);
        }
        else
        {
            //[self release];
            self = nil;
        }
    }
    
    return self;
}

+ (HOPContact*) getForSelf
{
    HOPContact* ret = nil;
    
    IContactPtr selfContact = IContact::getForSelf([[HOPAccount sharedAccount] getAccountPtr]);
    
    ret = [[OpenPeerStorageManager sharedStorageManager] getContactForId:[NSString stringWithCString:selfContact->getStableUniqueID() encoding:NSUTF8StringEncoding]];
    
    return ret;
}

- (BOOL) isSelf
{
    BOOL ret = NO;
    
    if (coreContactPtr)
    {
        ret = coreContactPtr->isSelf();
    }

    return ret;
}

- (NSString*) getPeerURI
{
    NSString* ret = nil;
    
    if (coreContactPtr)
    {
        ret = [NSString stringWithCString:coreContactPtr->getPeerURI() encoding:NSUTF8StringEncoding];
    }
    else
    {
        [NSException raise:NSInvalidArgumentException format:@"Invalid core contact object!"];
    }
    return ret;
}
    

- (NSString*) getFindSecret
{
    NSString* ret = nil;
    
    if (coreContactPtr)
    {
        ret = [NSString stringWithCString:coreContactPtr->getFindSecret() encoding:NSUTF8StringEncoding];
    }
    else
    {
        [NSException raise:NSInvalidArgumentException format:@"Invalid core contact object!"];
    }
    return ret;
}
        
- (NSString*) getStableUniqueID
{
    NSString* ret = nil;
    
    if (coreContactPtr)
    {
        ret = [NSString stringWithCString:coreContactPtr->getStableUniqueID() encoding:NSUTF8StringEncoding];
    }
    else
    {
        [NSException raise:NSInvalidArgumentException format:@"Invalid core contact object!"];
    }
    return ret;
}

- (BOOL) hasPeerFilePublic
{
    BOOL ret = NO;
    
    if (coreContactPtr)
    {
        ret = coreContactPtr->hasPeerFilePublic();
    }
    else
    {
        [NSException raise:NSInvalidArgumentException format:@"Invalid core contact object!"];
    }
    return ret;
}

- (NSString*) savePeerFilePublic
{
    NSString* ret = nil;
    
    if (coreContactPtr)
    {
        ret = [NSString stringWithCString:IHelper::convertToString( coreContactPtr->savePeerFilePublic()) encoding:NSUTF8StringEncoding];
    }
    else
    {
        [NSException raise:NSInvalidArgumentException format:@"Invalid core contact object!"];
    }
    return ret;
}

- (HOPAccount*) getAssociatedAccount
{
    return [HOPAccount sharedAccount];
}

- (void) hintAboutLocation:(NSString*) contactsLocationID
{
    if (coreContactPtr)
    {
        if ([contactsLocationID length] > 0)
            coreContactPtr->hintAboutLocation([contactsLocationID UTF8String]);
        else
           [NSException raise:NSInvalidArgumentException format:@"Invalid contacts location ID!"]; 
    }
    else
    {
        [NSException raise:NSInvalidArgumentException format:@"Invalid core contact object!"];
    }
}

#pragma mark - Internal methods
- (IContactPtr) getContactPtr
{
    return coreContactPtr;
}
@end
