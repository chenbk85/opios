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
#import <hookflash/IContact.h>
#import "HOPAccount_Internal.h"
#import "HOPContact_Internal.h"
#import "HOPProvisioningAccount.h"

@implementation HOPContact

- (id) initWithPeerFile:(HOPAccount*) account publicPeerFile:(NSString*) publicPeerFile
{
    self = [super init];
    if (self)
    {
        if (account && [publicPeerFile length] > 0)
        {
            IContact::createFromPeerFilePublic([account getAccountPtr], [publicPeerFile UTF8String]);
        }
    }
    return  self;
}


- (HOPAccount*) getAccount
{
    return[[HOPProvisioningAccount sharedInstance] getOpenPeerAccount];
}

- (NSString*) getContactID
{
    NSString* ret = nil;
    if(coreContactPtr)
    {
        ret = [NSString stringWithUTF8String: coreContactPtr->getContactID()];
    }
    else
    {
        [NSException raise:NSInvalidArgumentException format:@"Invalid OpenPeer contact pointer!"];
    }
    return ret;
}

- (BOOL) isSelf
{
    BOOL ret = NO;
    
    if (coreContactPtr)
    {
        ret = coreContactPtr->isSelf();
    }
    else
    {
        [NSException raise:NSInvalidArgumentException format:@"Invalid OpenPeer contact pointer!"];
    }
    return ret;
}

- (HOPContactTypes) getContactType
{
    HOPContactTypes ret = HOPContactTypeOpenPeer;
  
    if(coreContactPtr)
    {
        ret = (HOPContactTypes) coreContactPtr->getContactType();
    }
    else
    {
        [NSException raise:NSInvalidArgumentException format:@"Invalid OpenPeer contact pointer!"];
    }
    return ret;
}

- (BOOL) isEditable
{
    BOOL ret = NO;
    
    if (coreContactPtr)
    {
        ret = coreContactPtr->isEditable();
    }
    else
    {
        [NSException raise:NSInvalidArgumentException format:@"Invalid OpenPeer contact pointer!"];
    }
    return ret;
}

- (BOOL) isPublicXMLEditable
{
    BOOL ret = NO;
    
    if (coreContactPtr)
    {
        ret = coreContactPtr->isPublicXMLEditable();
    }
    else
    {
        [NSException raise:NSInvalidArgumentException format:@"Invalid OpenPeer contact pointer!"];
    }
    return ret;
}

- (NSString*) getPublicXML
{
    NSString* ret = nil;
  
    if(coreContactPtr)
    {
        ret = [NSString stringWithUTF8String: coreContactPtr->getPublicXML()];
    }
    else
    {
        [NSException raise:NSInvalidArgumentException format:@"Invalid OpenPeer contact pointer!"];
    }
    return ret;
}


- (NSString*) getPrivateXML
{
    NSString* ret = nil;
  
    if(coreContactPtr)
    {
        ret = [NSString stringWithUTF8String: coreContactPtr->getPrivateXML()];
    }
    else
    {
        [NSException raise:NSInvalidArgumentException format:@"Invalid OpenPeer contact pointer!"];
    }
    return ret;
}


- (BOOL) updateProfile:(NSString*) publicXML privateXML:(NSString*) privateXML
{
    BOOL ret = NO;
  
    if (coreContactPtr)
    {
        ret = coreContactPtr->updateProfile([publicXML UTF8String], [privateXML UTF8String]);
    }
    else
    {
        [NSException raise:NSInvalidArgumentException format:@"Invalid OpenPeer contact pointer!"];
    }
    return ret;
}


- (unsigned long) getProfileVersion
{
    unsigned long ret = 0;
     
    if (coreContactPtr)
    {
        ret = coreContactPtr->getProfileVersion();
    }
    else
    {
        [NSException raise:NSInvalidArgumentException format:@"Invalid OpenPeer contact pointer!"];
    }
    return ret;
}

#pragma mark - Internal methods
- (IContactPtr) getContactPtr
{
    return coreContactPtr;
}
@end
