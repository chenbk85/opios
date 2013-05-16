/*
 
 Copyright (c) 2013, SMB Phone Inc.
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

#import "IdentityDelegate.h"
#import <OpenpeerSDK/HOPIdentity.h>
#import "LoginManager.h"
#import "Constants.h"
#import "OpenPeerUser.h"

@implementation IdentityDelegate

- (void)identity:(HOPIdentity *)identity stateChanged:(HOPIdentityStates)state
{
    NSLog(@"Identity Login state: %@",[HOPIdentity toStringIdentityState:state]);
    switch (state)
    {
        case HOPIdentityStatePending:
            
            break;
        
        case HOPIdentityStateWaitingAttachment:
            
            break;
            
        case HOPIdentityStateWaitingToLoadBrowserWindow:
            [[LoginManager sharedLoginManager] onLoginUrlReceived:outerFrameURL forIdentity:identity];
            break;
            
        case HOPIdentityStateWaitingToMakeBrowserWindowVisible:
            [[LoginManager sharedLoginManager] makeLoginWebViewVisible:YES];
            [identity notifyBrowserWindowVisible];
            break;
            
        case HOPIdentityStateWaitingLoginCompleteBrowserRedirection:
            
            break;
            
        case HOPIdentityStateWaitingAssociation:
            [[LoginManager sharedLoginManager] onIdentityLoginFinished:identity];
            break;
            
        case HOPIdentityStateReady:
            //[((OpenPeerUser*)[OpenPeerUser sharedOpenPeerUser]).dictionaryIdentities setObject:[identity getIdentityURI] forKey:[identity identityBaseURI]];
            break;
            
        case HOPIdentityStateShutdown:
            
            break;
        default:
            break;
    }
}

- (void)onIdentityPendingMessageForInnerBrowserWindowFrame:(HOPIdentity *)identity
{
    //NSString* messageForJS = [identity getNextMessageForInnerBrowerWindowFrame];
    [[LoginManager sharedLoginManager] onMessageForJS:[identity getNextMessageForInnerBrowerWindowFrame]];
}

@end

