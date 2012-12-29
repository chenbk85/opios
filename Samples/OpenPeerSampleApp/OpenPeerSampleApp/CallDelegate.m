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

#import "CallDelegate.h"
#import "OpenPeer.h"
#import <OpenpeerSDK/HOPCall.h>
#import <OpenpeerSDK/HOPContact.h>
#import <OpenpeerSDK/HOPTypes.h>
#import <OpenpeerSDK/HOPConversationThread.h>
#import "SessionManager.h"
#import "Session.h"
#import "MainViewController.h"
#import "ActiveSessionViewController.h"


@implementation CallDelegate

- (void) onCallStateChanged:(HOPCall*) call callState:(HOPCallStates) callState
{
    NSString* sessionId = [[call getConversationThread] getThreadId];
    dispatch_async(dispatch_get_main_queue(), ^{
        Session* session = [[[SessionManager sharedSessionManager] sessionsDictionary] objectForKey:sessionId];
        
        ActiveSessionViewController* sessionViewController = [[[[OpenPeer sharedOpenPeer] mainViewController] sessionViewControllersDictionary] objectForKey:sessionId];
        switch (callState)
        {
            case HOPCallStatePreparing:             //Receives both parties, caller and callee.
                {
                    if (![[call getCaller] isSelf])
                    {
                        [[[OpenPeer sharedOpenPeer] mainViewController] showSessionViewControllerForSession:session forIncomingCall:YES];
                        if (!sessionViewController)
                            sessionViewController = [[[[OpenPeer sharedOpenPeer] mainViewController] sessionViewControllersDictionary] objectForKey:sessionId];
                        [sessionViewController prepareForIncomingCall];
                    }
                    [sessionViewController updateCallState];
                }
                break;
                
            case HOPCallStateIncoming:              //Receives just callee
                [[SessionManager sharedSessionManager] handleIncomingCall:call forSession:session];
                [sessionViewController prepareForIncomingCall];
                [sessionViewController updateCallState];
                break;
                
            case HOPCallStatePlaced:                //Receives just calller
                [sessionViewController updateCallState];
                break;
                
            case HOPCallStateEarly:                 //Currently is not in use
                [sessionViewController updateCallState];
                break;
                
            case HOPCallStateRinging:               //Receives just callee side. Now should play ringing sound
                [sessionViewController updateCallState];
                break;
                
            case HOPCallStateRingback:              //Receives just caller side
                [sessionViewController updateCallState];
                break;
                
            case HOPCallStateOpen:                  //Receives both parties. Call is established
                [sessionViewController updateCallState];
                [sessionViewController prepareForCall:YES withVideo:[call hasVideo]];
                break;
                
            case HOPCallStateActive:                //Currently not in use
                [sessionViewController updateCallState];
                break;
                
            case HOPCallStateInactive:              //Currently not in use
                [sessionViewController updateCallState];
                break;
                
            case HOPCallStateHold:                  //Receives both parties
                [sessionViewController updateCallState];
                break;
                
            case HOPCallStateClosing:               //Receives both parties
                [call hangup:HOPCallClosedReasonUser];
                break;
                
            case HOPCallStateClosed:                //Receives both parties
                [sessionViewController updateCallState];
                [sessionViewController prepareForCall:NO withVideo:NO];
                break;
                
            case HOPCallStateNone:
            default:
                break;
        }
    });

}
@end
