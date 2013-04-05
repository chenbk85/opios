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

#import <UIKit/UIKit.h>

@class Session;
@interface ActiveSessionViewController : UIViewController

@property (nonatomic, strong) Session* session;

@property (nonatomic, weak) IBOutlet UIView *videoView;
@property (nonatomic, weak) IBOutlet UIView *callStatusView;
@property (nonatomic, weak) IBOutlet UIView *buttonsView;
@property (nonatomic, weak) IBOutlet UIView *incomingCallView;
@property (nonatomic, weak) IBOutlet UIImageView *videoImageView;
@property (nonatomic, weak) IBOutlet UIImageView *videoPreviewImageView;


@property (nonatomic, weak) IBOutlet UILabel *statusLabel;

@property (nonatomic, weak) IBOutlet UIButton *voiceCallButton;
@property (nonatomic, weak) IBOutlet UIButton *videoCallButton;
@property (nonatomic, weak) IBOutlet UIButton *messageButton;
@property (weak, nonatomic) IBOutlet UIButton *recordingButton;

@property (assign) BOOL isIncomingCall;

- (id) initWithSession:(Session*) inSession;

- (IBAction)actionSendMessage:(id)sender;
- (IBAction)actionVideoCall:(id)sender;
- (IBAction)actionVoiceCall:(id)sender;
- (IBAction)actionDeclineCall:(id)sender;
- (IBAction)actionAcceptCall:(id)sender;
- (IBAction)actionRecordVideo:(id)sender;

- (void) prepareForCall:(BOOL) isCallSession withVideo:(BOOL) includeVideo;
- (void) prepareForIncomingCall;
- (void) updateCallState;

- (void) stopVideoRecording:(BOOL) stopRecording hideRecordButton:(BOOL) hideButton;
@end
