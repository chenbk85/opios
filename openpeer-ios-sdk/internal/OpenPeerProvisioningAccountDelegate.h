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


#import <Foundation/Foundation.h>
#import <dispatch/dispatch.h>

#include <hookflash/core/types.h>
#include <hookflash/core/IAccount.h>
//#include <hookflash/IAccount.h>
#import "HOPProtocols.h"

using namespace hookflash;
using namespace hookflash::provisioning;

class OpenPeerProvisioningAccountDelegate : public provisioning::IAccountDelegate, public hookflash::IAccountDelegate
{
protected:
    id<HOPProvisioningAccountDelegate> provisioningAccountDelegate;
    //id<HOPAccountDelegate> openpeerAccountDelegate;
    
    OpenPeerProvisioningAccountDelegate(id<HOPProvisioningAccountDelegate> inProvisioningAccountDelegate);
    
    HOPProvisioningAccount* getOpenPeerProvisioningAccount(provisioning::IAccountPtr account);
public:
    static boost::shared_ptr<OpenPeerProvisioningAccountDelegate> create(id<HOPProvisioningAccountDelegate> inProvisioningAccountDelegate);
    
#pragma mark - provisioning::IAccount delegate methods

    virtual void onProvisioningAccountStateChanged(provisioning::IAccountPtr account,provisioning::IAccount::AccountStates state);
    
    virtual void onProvisioningAccountError(provisioning::IAccountPtr account,AccountErrorCodes error);
    
    virtual void onProvisioningAccountProfileChanged(provisioning::IAccountPtr account);
    
    virtual void onProvisioningAccountIdentityValidationResult(provisioning::IAccountPtr account,IdentityID identity,IdentityValidationResultCode result);
    
#pragma mark - hookflash::IAccount delegate methods
    
    virtual void onAccountStateChanged(hookflash::IAccountPtr account, hookflash::IAccount::AccountStates state);
    
    //virtual void onAccountPeerFileLookupQueryComplete(provisioning::IAccountPeerFileLookupQueryPtr query);
};
