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

#import "OpenPeerUser.h"
#import <Foundation/NSKeyedArchiver.h>
#import <OpenpeerSDK/HOPProvisioningAccount.h>
#import <Foundation/Foundation.h>

@interface OpenPeerUser()

@property (nonatomic, copy) NSString * const keyOpenPeerUser;

@property (nonatomic, copy) NSString * const archiveUserId;
@property (nonatomic, copy) NSString * const archiveContactId;
@property (nonatomic, copy) NSString * const archiveAccountSalt;
@property (nonatomic, copy) NSString * const archivePasswordNonce;
@property (nonatomic, copy) NSString * const archivePrivatePeerFile;
@property (nonatomic, copy) NSString * const archivePeerFilePassword;
@property (nonatomic, copy) NSString * const archiveLastProfileUpdateTimestamp;

- (id) initSingleton;
@end

@implementation OpenPeerUser

/**
 Retrieves singleton object of the Open Peer User.
 @return Singleton object of the Open Peer User.
 */
+ (id) sharedOpenPeerUser
{
    static dispatch_once_t pred = 0;
    __strong static id _sharedObject = nil;
    dispatch_once(&pred, ^{
        _sharedObject = [[self alloc] initSingleton];
    });
    return _sharedObject;
}

/**
 Initialization of Open Peer User singleton object.
 @return Object of the Open Peer User.
 */
- (id) initSingleton
{
    self = [super init];
    
    if (self)
    {
        self.archiveUserId = @"archiveUserId";
        self.archiveContactId = @"archiveContactId";
        self.archiveAccountSalt = @"archiveAccountSalt";
        self.archivePasswordNonce = @"archivePasswordNonce";
        self.archivePrivatePeerFile = @"archivePrivatePeerFile";
        self.archivePeerFilePassword = @"archivePeerFilePassword";
        self.archiveLastProfileUpdateTimestamp = @"archiveLastProfileUpdateTimestamp";
        
        self.keyOpenPeerUser = @"keyOpenPeerUser";
        
        NSData* data = [[NSUserDefaults standardUserDefaults] objectForKey:self.keyOpenPeerUser];
        NSKeyedUnarchiver *aDecoder = [[[NSKeyedUnarchiver alloc] initForReadingWithData:data] autorelease];
        
        self.userId = [aDecoder decodeObjectForKey:self.archiveUserId];
        self.contactId = [aDecoder decodeObjectForKey:self.archiveContactId];
        self.accountSalt = [aDecoder decodeObjectForKey:self.archiveAccountSalt];
        self.passwordNonce = [aDecoder decodeObjectForKey:self.archivePasswordNonce];
        self.privatePeerFile = [aDecoder decodeObjectForKey:self.archivePrivatePeerFile];
        self.peerFilePassword = [aDecoder decodeObjectForKey:self.archivePeerFilePassword];
        self.lastProfileUpdateTimestamp = [aDecoder decodeDoubleForKey:self.archiveLastProfileUpdateTimestamp];
        [aDecoder finishDecoding];
    }
    return self;
}

/**
 Saves user information on local device.
 */
- (void) saveUserData
{
    self.userId = [[HOPProvisioningAccount sharedInstance] getUserID];
    self.contactId = [[HOPProvisioningAccount sharedInstance] getContactID];
    self.accountSalt = [[HOPProvisioningAccount sharedInstance] getAccountSalt];
    self.passwordNonce = [[HOPProvisioningAccount sharedInstance] getPasswordNonce];
    self.privatePeerFile = [[HOPProvisioningAccount sharedInstance] getPrivatePeerFile];
    self.peerFilePassword = [[HOPProvisioningAccount sharedInstance] getPassword];
    self.lastProfileUpdateTimestamp = [[HOPProvisioningAccount sharedInstance] getLastProfileUpdatedTime];
    
    NSMutableData *data = [NSMutableData data];
    NSKeyedArchiver *aCoder = [[[NSKeyedArchiver alloc] initForWritingWithMutableData:data] autorelease];
    [aCoder encodeObject:self.userId forKey:self.archiveUserId];
    [aCoder encodeObject:self.contactId forKey:self.archiveContactId];
    [aCoder encodeObject:self.accountSalt forKey:self.archiveAccountSalt];
    [aCoder encodeObject:self.passwordNonce forKey:self.archivePasswordNonce];
    [aCoder encodeObject:self.privatePeerFile forKey:self.archivePrivatePeerFile];
    [aCoder encodeObject:self.peerFilePassword forKey:self.archivePeerFilePassword];
    [aCoder encodeDouble:self.lastProfileUpdateTimestamp forKey:self.archiveLastProfileUpdateTimestamp];
    [aCoder finishEncoding];
    
    [[NSUserDefaults standardUserDefaults] setObject:data forKey:self.keyOpenPeerUser];
}

/**
 deletes user information from local device.
 */
- (void) deleteUserData
{
    self.userId = nil;
    self.contactId = nil;
    self.accountSalt = nil;
    self.passwordNonce = nil;
    self.privatePeerFile = nil;
    self.peerFilePassword = nil;
    self.lastProfileUpdateTimestamp = 0;
    
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:self.keyOpenPeerUser];
}


@end
