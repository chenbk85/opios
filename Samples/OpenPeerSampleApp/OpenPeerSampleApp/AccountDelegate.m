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

#import "UIKit/UIKit.h"
#import "AccountDelegate.h"
#import "OpenpeerSDK/HOPAccount.h"
#import "LoginManager.h"
#import "OpenPeer.h"
#import "MainViewController.h"

@implementation AccountDelegate

//Provisioning account delegate implementation.

//This method handles account state changes from SDK.

//- (void)onAccountStateChanged:(HOPAccount *)account accountState:(HOPAccountStates)accountState
- (void) account:(HOPAccount*) account stateChanged:(HOPAccountStates) accountState
{
    NSLog(@"HOPAccount state: %@", [HOPAccount toStringAccountState:accountState]);
    
    dispatch_async(dispatch_get_main_queue(), ^
    {
        switch (accountState)
        {
            case HOPAccountStatePending:
                break;
                
            case HOPAccountStateReady:
                [[LoginManager sharedLoginManager] onUserLoggedIn];
                break;
                
            case HOPAccountStateShuttingDown:
                break;
                
            case HOPAccountStateShutdown:
                [[[OpenPeer sharedOpenPeer] mainViewController] showLoginView];
                break;
                
            default:
                break;
        }
    });
}

- (void)onAccountAssociatedIdentitiesChanged:(HOPAccount *)account
{
    dispatch_async(dispatch_get_main_queue(), ^{
    });
}

@end
