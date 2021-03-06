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

@class LoginViewController;
@class WebLoginViewController;
@class ContactsTableViewController;

typedef enum
{
    DEMO_REMOTE_SESSION_INIT,
    DEMO_CHECK_AVAILABILITY,
    DEMO_FACE_DETECTION_MODE,
    DEMO_CALL_REDIAL
} DemoOptions;

@interface MainViewController : UIViewController<UIActionSheetDelegate>

@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (nonatomic, weak) IBOutlet UILabel *activityLabel;
@property (nonatomic, weak) IBOutlet UIView *activityView;


@property (nonatomic, strong) LoginViewController *loginViewController;
@property (nonatomic, strong) WebLoginViewController *webLoginViewController;
@property (nonatomic, strong) ContactsTableViewController *contactsTableViewController;
@property (nonatomic, strong) UINavigationController *contactsNavigationController;

@property (nonatomic, strong) NSMutableDictionary *sessionViewControllersDictionary;

- (void) showLoginView;
- (void) showWebLoginView:(NSString*) url;
- (void) showContactsTable;

//- (void) showSessionViewControllerForSession:(Session*) session;
- (void) showSessionViewControllerForSession:(Session*) session forIncomingCall:(BOOL) incomingCall;
- (void) removeSessionViewControllerForSession:(NSString*) sessionId;

- (void) showIncominCallForSession:(Session*) session;

- (void) prepareForViewCallSession:(Session*) session withVideo:(BOOL) withVideo;
@end
