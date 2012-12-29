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

#import "ActiveSessionViewController.h"
#import "Session.h"
#import "SessionManager.h"
#import <OpenpeerSDK/HOPCall.h>
#import <OpenpeerSDK/HOPMediaEngine.h>
#import "Utility.h"

#define MAKE_CALL 1
#define END_CALL 2
@interface ActiveSessionViewController ()

@property (nonatomic, assign) int messageCounter;
@end

@implementation ActiveSessionViewController

- (id) initWithSession:(Session*) inSession
{
    self = [self initWithNibName:@"ActiveSessionViewController" bundle:nil];
    if (self)
    {
        self.session = inSession;
        self.messageCounter = 1;
        self.isIncomingCall = NO;
    }
    return self;
}
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
//    self.callStatusView.hidden = YES;
//    self.incomingCallView.hidden = YES;
//    self.videoView.hidden = YES;
    [[HOPMediaEngine sharedInstance] setCaptureRenderView:self.videoPreviewImageView];
    [[HOPMediaEngine sharedInstance] setChannelRenderView:self.videoImageView];
    [[HOPMediaEngine sharedInstance] setDefaultVideoOrientation:HOPMediaEngineVideoOrientationPortrait];
    //[[HOPMediaEngine sharedInstance] setVideoOrientation];
    
    [self.view bringSubviewToFront:self.buttonsView];
    [self prepareForCall:NO withVideo:NO];
    
    if (self.isIncomingCall)
    {
        [self prepareForIncomingCall];
        self.isIncomingCall = NO;
    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [_videoView release];
    [_callStatusView release];
    [_buttonsView release];
    [_statusLabel release];
    [_voiceCallButton release];
    [_videoCallButton release];
    [_messageButton release];
    [_incomingCallView release];
    [_videoImageView release];
    [_videoPreviewImageView release];
    [super dealloc];
}
- (IBAction)actionSendMessage:(id)sender
{
    [[SessionManager sharedSessionManager] sendMessage:[NSString stringWithFormat:@"This is a test message %d.",self.messageCounter] forSession:self.session];
    self.messageCounter++;
}

- (IBAction)actionVideoCall:(id)sender
{
    if ([sender tag] == MAKE_CALL)
    {
        [self prepareForCall:YES withVideo:YES];
        [[SessionManager sharedSessionManager] makeCallForSession:self.session includeVideo:YES];
    }
    else
    {
        [self.session.currentCall hangup:HOPCallClosedReasonUser];
    }
}

- (IBAction)actionVoiceCall:(id)sender
{
    if ([((UIButton*)sender) tag] == MAKE_CALL)
    {
        [self prepareForCall:YES withVideo:NO];
        [[SessionManager sharedSessionManager] makeCallForSession:self.session includeVideo:NO];
    }
    else
    {
        [self.session.currentCall hangup:HOPCallClosedReasonUser];
    }
}

- (IBAction)actionDeclineCall:(id)sender
{
    [self.session.currentCall hangup:CallClosedReasonDecline];
}

- (IBAction)actionAcceptCall:(id)sender
{
    [self.session.currentCall answer];
}

- (void)prepareForCall:(BOOL)isCallSession withVideo:(BOOL)includeVideo
{
    self.incomingCallView.hidden = YES;
    self.buttonsView.hidden = NO;
    if (isCallSession)
    {
        self.callStatusView.hidden = NO;
        //[self.statusLabel setText:[NSString stringWithFormat:@"%d",[self.session.currentCall getState]]];
        if (includeVideo)
        {
            self.videoView.hidden = NO;
            self.voiceCallButton.enabled = NO;
            self.videoCallButton.enabled = YES;
            self.videoCallButton.tag = END_CALL;
            [self.voiceCallButton setTitle:@"Audio" forState:UIControlStateNormal];
            [self.videoCallButton setTitle:@"End Call" forState:UIControlStateNormal];
            //[[HOPMediaEngine sharedInstance] setVideoOrientation];
            [self.view bringSubviewToFront:self.buttonsView];
            self.videoImageView.contentMode = UIViewContentModeScaleAspectFill;
            self.videoImageView.clipsToBounds = YES;
            self.videoPreviewImageView.contentMode = UIViewContentModeScaleAspectFill;
            self.videoPreviewImageView.clipsToBounds = YES;
        }
        else
        {
            self.videoView.hidden = YES;
            self.videoCallButton.enabled = NO;
            [self.voiceCallButton setBackgroundColor:[UIColor whiteColor]];
            self.voiceCallButton.enabled = YES;
            self.voiceCallButton.tag = END_CALL;
            [self.voiceCallButton setTitle:@"End Call" forState:UIControlStateNormal];
            [self.videoCallButton setTitle:@"Video" forState:UIControlStateNormal];
        }
    }
    else
    {
        self.videoView.hidden = YES;
        self.callStatusView.hidden = YES;
        self.videoCallButton.enabled = YES;
        self.voiceCallButton.enabled = YES;
        self.videoCallButton.tag = MAKE_CALL;
        self.voiceCallButton.tag = MAKE_CALL;
        [self.voiceCallButton setTitle:@"Audio" forState:UIControlStateNormal];
        [self.videoCallButton setTitle:@"Video" forState:UIControlStateNormal];
    }
}

- (void) prepareForIncomingCall
{
    self.incomingCallView.hidden = NO;
    self.callStatusView.hidden = NO;
    self.videoView.hidden = YES;
    self.buttonsView.hidden = YES;
    
    //[self.statusLabel setText:[NSString stringWithFormat:@"%d",[self.session.currentCall getState]]];
}

- (void) updateCallState
{
    //[self.statusLabel setText:[NSString stringWithFormat:@"%d",[self.session.currentCall getState]]];
    [self.statusLabel setText:[Utility getCallStateAsString:[self.session.currentCall getState]]];
}
@end
