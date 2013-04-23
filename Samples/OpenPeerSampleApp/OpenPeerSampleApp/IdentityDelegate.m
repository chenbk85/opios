//
//  IdentityDelegate.m
//  OpenPeerSampleApp
//
//  Created by Sergej on 3/14/13.
//  Copyright (c) 2013 Sergej. All rights reserved.
//

#import "IdentityDelegate.h"
#import <OpenpeerSDK/HOPIdentity.h>
#import "LoginManager.h"
#import "Constants.h"

@implementation IdentityDelegate

- (void)identity:(HOPIdentity *)identity stateChanged:(HOPIdentityStates)state
{
    switch (state)
    {
        case HOPIdentityStatePending:
            
            break;
        
        case HOPIdentityStateWaitingAttachment:
            
            break;
            
        case HOPIdentityStateWaitingToLoadBrowserWindow:
            //[[LoginManager sharedLoginManager] onLoginUrlReceived:[identity getIdentityLoginURL]];
            //[[LoginManager sharedLoginManager] onLoginUrlReceived:@"app.unstable.hookflash.me"];
            [[LoginManager sharedLoginManager] onLoginUrlReceived:outerFrameURL forIdentity:identity];
            break;
            
        case HOPIdentityStateWaitingToMakeBrowserWindowVisible:
            [[LoginManager sharedLoginManager] makeLoginWebViewVisible:YES];
            [identity notifyBrowserWindowVisible];
            break;
            
        case HOPIdentityStateWaitingLoginCompleteBrowserRedirection:
            
            break;
            
        case HOPIdentityStateWaitingAssociation:
            [[LoginManager sharedLoginManager] onIdentityassociationFinished:identity];
            break;
            
        case HOPIdentityStateReady:
            [[LoginManager sharedLoginManager] onIdentityLoginFinished:identity];
            break;
            
        case HOPIdentityStateShutdown:
            
            break;
        default:
            break;
    }
}

- (void)onIdentityPendingMessageForInnerBrowserWindowFrame:(HOPIdentity *)identity
{
    NSString* messageForJS = [identity getNextMessageForInnerBrowerWindowFrame];
}

@end

