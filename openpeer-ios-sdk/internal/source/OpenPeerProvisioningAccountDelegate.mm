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


#include "OpenPeerProvisioningAccountDelegate.h"
#import "HOPProvisioningAccount.h"
#import "OpenPeerStorageManager.h"

OpenPeerProvisioningAccountDelegate::OpenPeerProvisioningAccountDelegate(id<HOPProvisioningAccountDelegate> inProvisioningAccountDelegate)
{
    provisioningAccountDelegate = inProvisioningAccountDelegate;
}

boost::shared_ptr<OpenPeerProvisioningAccountDelegate> OpenPeerProvisioningAccountDelegate::create(id<HOPProvisioningAccountDelegate> inProvisioningAccountDelegate)
{
    return boost::shared_ptr<OpenPeerProvisioningAccountDelegate> (new OpenPeerProvisioningAccountDelegate(inProvisioningAccountDelegate));
}

HOPProvisioningAccount* OpenPeerProvisioningAccountDelegate::getOpenPeerProvisioningAccount(provisioning::IAccountPtr account)
{
    HOPProvisioningAccount * hopProvisioningAccount = nil;
    
    NSString* userId = [NSString stringWithUTF8String:account->getUserID()];
    if (userId)
    {
        hopProvisioningAccount = [[OpenPeerStorageManager sharedInstance] getProvisioningAccountForUserId:userId];
    }
    return hopProvisioningAccount;
}

void OpenPeerProvisioningAccountDelegate::onProvisioningAccountStateChanged(hookflash::provisioning::IAccountPtr account,AccountStates state)
{
    HOPProvisioningAccount* hopProvisioningAccount = this->getOpenPeerProvisioningAccount(account);
    if (hopProvisioningAccount)
        [provisioningAccountDelegate onProvisioningAccountStateChanged:hopProvisioningAccount accountStates:(HOPAccountStates) state];
}

void OpenPeerProvisioningAccountDelegate::onProvisioningAccountError(provisioning::IAccountPtr account,AccountErrorCodes error)
{
    HOPProvisioningAccount* hopProvisioningAccount = this->getOpenPeerProvisioningAccount(account);
    if (hopProvisioningAccount)
        [provisioningAccountDelegate onProvisioningAccountError:hopProvisioningAccount errorCodes:(HOPProvisioningAccountErrorCodes) error];
}

void OpenPeerProvisioningAccountDelegate::onProvisioningAccountProfileChanged(provisioning::IAccountPtr account)
{
    HOPProvisioningAccount* hopProvisioningAccount = this->getOpenPeerProvisioningAccount(account);
    if (hopProvisioningAccount)
        [provisioningAccountDelegate onProvisioningAccountProfileChanged:hopProvisioningAccount];
}

void OpenPeerProvisioningAccountDelegate::onProvisioningAccountIdentityValidationResult(provisioning::IAccountPtr account,IdentityID identity,IdentityValidationResultCode result)
{
   
}
