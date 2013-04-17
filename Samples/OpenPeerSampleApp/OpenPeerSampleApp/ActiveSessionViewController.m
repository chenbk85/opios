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
#import "MessageManager.h"
#import "OpenPeer.h"
#import "ChatViewController.h"
#import <OpenpeerSDK/HOPCall.h>
#import <OpenpeerSDK/HOPMediaEngine.h>
#import "Utility.h"

#define MAKE_CALL 1
#define END_CALL 2

@interface ActiveSessionViewController ()

@property (nonatomic, assign) int messageCounter;
@property (nonatomic, assign) CGRect originalFrame;
@property (assign) BOOL isFaceDetectionForSessionActive;

- (void) prepareForFaceDetection:(BOOL) toPrepare;

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
    if (self)
    {
        
    }
    return self;
}

- (ChatViewController*) chatViewController
{
    if (!_chatViewController)
    {
        _chatViewController = [[ChatViewController alloc] initWithNibName:@"ChatViewController" bundle:nil];
        _chatViewController.session = self.session;
    }
    
    return _chatViewController;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.originalFrame = self.videoPreviewImageView.frame;
    
    //Set default video orientation to be portrait
    [[HOPMediaEngine sharedInstance] setDefaultVideoOrientation:HOPMediaEngineVideoOrientationPortrait];
    
    //Set UIImageViews where will be shown camera preview and video
    [[HOPMediaEngine sharedInstance] setCaptureRenderView:self.videoPreviewImageView];
    [[HOPMediaEngine sharedInstance] setChannelRenderView:self.videoImageView];
    //Set default video orientation to be portrait
    [[HOPMediaEngine sharedInstance] setDefaultVideoOrientation:HOPMediaEngineVideoOrientationPortrait];
    
    [self.view bringSubviewToFront:self.buttonsView];
    //Prepare view controller for default state - no call
    [self prepareForCall:NO withVideo:NO];
    
    //In case this session is created for incoming call prepare it for
    if (self.isIncomingCall)
    {
        [self prepareForIncomingCall];
        //This is just used for opening session view controller so we can reset it to default state
        self.isIncomingCall = NO;
    }
    
}

-(void)viewDidAppear:(BOOL)animated
{
    if (([[OpenPeer sharedOpenPeer] isFaceDetectionModeOn] && !self.isFaceDetectionForSessionActive) ||  (![[OpenPeer sharedOpenPeer] isFaceDetectionModeOn]) )
    {
        [self prepareForFaceDetection:[[OpenPeer sharedOpenPeer] isFaceDetectionModeOn]];
        
    }
    
    //In case face detection is turned on/off show or remove record button
    [self stopVideoRecording:YES hideRecordButton:![[OpenPeer sharedOpenPeer] isFaceDetectionModeOn]];
    
    [super viewDidAppear:animated];
}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}
- (void)viewDidDisappear:(BOOL)animated
{
    if ([[OpenPeer sharedOpenPeer] isFaceDetectionModeOn] && self.isFaceDetectionForSessionActive)
        [self prepareForFaceDetection:NO];
    
    [super viewDidDisappear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (IBAction)actionRecordVideo:(id)sender
{
    //If recording button is selected, start recording
    if (!self.recordingButton.selected)
    {
        [[SessionManager sharedSessionManager] startVideoRecording];
        
        self.recordingButton.selected = YES;
    }
    else
    {
        //Stop video recording
        [self stopVideoRecording:YES hideRecordButton:NO];
    }
}


- (void) prepareForFaceDetection:(BOOL) toPrepare
{
    if (toPrepare)
    {
        self.videoView.hidden = NO;
        self.videoPreviewImageView.hidden = NO;
        self.videoPreviewImageView.clipsToBounds = YES;
        self.videoPreviewImageView.frame = self.videoView.bounds;
        
        [[SessionManager sharedSessionManager] setSessionWithFaceDetectionOn:self.session];
        [[HOPMediaEngine sharedInstance] startFaceDetectionForImageView:self.videoPreviewImageView];
        
        self.isFaceDetectionForSessionActive = YES;
    }
    else
    {
        [[SessionManager sharedSessionManager] setSessionWithFaceDetectionOn:nil];
        [[HOPMediaEngine sharedInstance] stopFaceDetection];
        
        self.videoPreviewImageView.image = nil;
        self.videoPreviewImageView.frame = self.originalFrame;
        self.isFaceDetectionForSessionActive = NO;
    }
    
}

- (IBAction)actionSendMessage:(id)sender
{
    [self.navigationController pushViewController:self.chatViewController animated:YES];
}

- (IBAction)actionVideoCall:(id)sender
{
    if ([sender tag] == MAKE_CALL)
    {
        //Prepare view for video call
        [self prepareForCall:YES withVideo:YES];
        //Create a video call
        [[SessionManager sharedSessionManager] makeCallForSession:self.session includeVideo:YES isRedial:NO];
    }
    else
    {
        //End video call
        [[SessionManager sharedSessionManager] endCallForSession:self.session];
    }
}

- (IBAction)actionVoiceCall:(id)sender
{
    if ([((UIButton*)sender) tag] == MAKE_CALL)
    {
        //Prepare view for audio call
        [self prepareForCall:YES withVideo:NO];
        //Create a audio call
        [[SessionManager sharedSessionManager] makeCallForSession:self.session includeVideo:NO isRedial:NO];
    }
    else
    {
        //End audio call
        [[SessionManager sharedSessionManager] endCallForSession:self.session];
    }
}

- (IBAction)actionDeclineCall:(id)sender
{
    //End incoming call
    [[SessionManager sharedSessionManager] endCallForSession:self.session];
}

- (IBAction)actionAcceptCall:(id)sender
{
    //Answer call
    [[SessionManager sharedSessionManager] answerCallForSession:self.session];
}

- (void)prepareForCall:(BOOL)isCallSession withVideo:(BOOL)includeVideo
{
    //Hide incoming view 
    self.incomingCallView.hidden = YES;
    //Show control buttons (Audio, Video, Message)
    self.buttonsView.hidden = NO;
    
    if (isCallSession)
    {
        self.callStatusView.hidden = NO;
        
        if (includeVideo) //Update controller if video call is active
        {
            [self prepareForFaceDetection:NO];
            self.videoView.hidden = NO;
            self.voiceCallButton.enabled = NO;
            self.videoCallButton.enabled = YES;
            self.videoCallButton.tag = END_CALL;
            [self.voiceCallButton setTitle:@"Audio" forState:UIControlStateNormal];
            [self.videoCallButton setTitle:@"End Call" forState:UIControlStateNormal];
            [self.view bringSubviewToFront:self.buttonsView];
            self.videoImageView.contentMode = UIViewContentModeScaleAspectFill;
            self.videoImageView.clipsToBounds = YES;
            self.videoImageView.image = nil;
            self.videoPreviewImageView.contentMode = UIViewContentModeScaleAspectFill;
            self.videoPreviewImageView.clipsToBounds = YES;
            self.videoPreviewImageView.image = nil;
        }
        else //Update controller if audio call is active
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
    else //Update controller if call is not active
    {
        self.videoImageView.image = nil;
        self.videoPreviewImageView.image = nil;
        self.videoView.hidden = YES;
        self.callStatusView.hidden = YES;
        self.videoCallButton.enabled = YES;
        self.voiceCallButton.enabled = YES;
        self.videoCallButton.tag = MAKE_CALL;
        self.voiceCallButton.tag = MAKE_CALL;
        [self.voiceCallButton setTitle:@"Audio" forState:UIControlStateNormal];
        [self.videoCallButton setTitle:@"Video" forState:UIControlStateNormal];
        
        [self prepareForFaceDetection:[[OpenPeer sharedOpenPeer] isFaceDetectionModeOn]];
    }
}

- (void) prepareForIncomingCall
{
    NSLog(@"Prepare for incoming call");
    self.incomingCallView.hidden = NO;
    self.callStatusView.hidden = NO;
    self.videoView.hidden = YES;
    self.buttonsView.hidden = YES;
}

- (void) updateCallState
{
    [self.statusLabel setText:[Utility getCallStateAsString:[self.session.currentCall getState]]];
}

- (void)viewDidUnload {
    
    [self setRecordingButton:nil];
    [super viewDidUnload];
}

- (void) stopVideoRecording:(BOOL) stopRecording hideRecordButton:(BOOL) hideButton
{
    if (stopRecording && self.recordingButton.selected)
    {
        //Stop video recording
        [[SessionManager sharedSessionManager] stopVideoRecording];
        self.recordingButton.selected = NO;
    }
    
    self.recordingButton.hidden = hideButton;
}
@end
