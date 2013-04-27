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
    NSLog(@"Identity Login state: %@",[HOPIdentity toStringIdentityState:state]);
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
            //[[LoginManager sharedLoginManager] onIdentityassociationFinished:identity];
            [[LoginManager sharedLoginManager] onIdentityLoginFinished:identity];
            [[LoginManager sharedLoginManager] onUserLoggedIn];
            break;
            
        case HOPIdentityStateReady:
            [[LoginManager sharedLoginManager] onUserLoggedIn];
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

