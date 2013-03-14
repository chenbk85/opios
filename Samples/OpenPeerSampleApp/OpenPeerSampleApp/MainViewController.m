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

#import "MainViewController.h"
#import "OpenPeer.h"
#import "Constants.h"

//SDK
#import <OpenpeerSDK/HOPConversationThread.h>
#import <OpenpeerSDK/HOPContact.h>
//Managers
#import "SessionManager.h"
#import "LoginManager.h"
#import "ContactsManager.h"
#import "MessageManager.h"
//Model
#import "Session.h"
#import "Contact.h"
//View controllers
#import "LoginViewController.h"
#import "WebLoginViewController.h"
#import "ContactsTableViewController.h"
#import "ActiveSessionViewController.h"
#import "MainViewController.h"

//Private methods
@interface MainViewController ()

- (void) removeAllSubViews;
- (void) actionDemo;

@end

@implementation MainViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        self.sessionViewControllersDictionary = [[NSMutableDictionary alloc] init];
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) removeAllSubViews
{
    [self dismissViewControllerAnimated:NO completion:nil];
    [[[self view] subviews] makeObjectsPerformSelector: @selector(removeFromSuperview)];
}


/**
 Show Demo menu
 */
- (void)actionDemo
{
    NSString* remoteSessionTitle = ![[OpenPeer sharedOpenPeer] isRemoteSessionActivationModeOn] ? @"Remote Session - Turn On" : @"Remote Session - Turn Off";
    NSString* faceDectionTitle = ![[OpenPeer sharedOpenPeer] isFaceDetectionModeOn] ? @"Face Detection - Turn On" : @"Face Detection - Turn Off";
    
    NSString* redialTitle = ![[OpenPeer sharedOpenPeer] isRedialModeOn] ? @"Redial - Turn On" : @"Redial - Turn Off";
    
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"Demo options"
                                                       delegate:self
                                              cancelButtonTitle:@"Cancel"
                                         destructiveButtonTitle:nil
                                              otherButtonTitles:remoteSessionTitle, @"Check availability", faceDectionTitle, redialTitle,nil];
    [sheet setActionSheetStyle:UIActionSheetStyleAutomatic];
    
    [sheet setAlpha:0.9];
    
    [sheet showFromBarButtonItem:self.contactsTableViewController.navigationItem.leftBarButtonItem animated:YES];
}

#pragma mark - Login views
/**
 Show view with login button
*/
- (void) showLoginView
{
    if (!self.loginViewController)
    {
        self.loginViewController = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
    }
    
    [self removeAllSubViews];
    [self.view addSubview:self.loginViewController.view];
}

/**
 Show web view with opened login page.
 @param url NSString Login page url.
*/
- (void) showWebLoginView:(NSString*) url
{
    if (!self.webLoginViewController)
        self.webLoginViewController = [[WebLoginViewController alloc] initWithNibName:@"WebLoginViewController" bundle:nil];
    
    if (url)
    {
        [self removeAllSubViews];
        [self.view addSubview:self.webLoginViewController.view];
        [self.webLoginViewController openLoginUrl:url];
    }
}

#pragma mark - Contacts views
/**
 Show table with list of contacts.
 */
- (void)showContactsTable
{
    [self removeAllSubViews];
    
    if (!self.contactsTableViewController)
        self.contactsTableViewController = [[ContactsTableViewController alloc] initWithNibName:@"ContactsTableViewController" bundle:nil];
    
    if (!self.contactsNavigationController)
    {
        self.contactsNavigationController = [[UINavigationController alloc] initWithRootViewController:self.contactsTableViewController];
        [self.contactsNavigationController.navigationBar.topItem setTitle:@"Contacts"];
        // Add logout button in navigation bar
        UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithTitle:@"Logout"
                                                                      style:UIBarButtonItemStyleBordered
                                                                     target:[LoginManager sharedLoginManager]
                                                                     action:@selector(logout)];
        self.contactsTableViewController.navigationItem.rightBarButtonItem = barButton;
        
        //Create Demo options button
        UIBarButtonItem *barButtonLeft = [[UIBarButtonItem alloc] initWithTitle:@"Demo"
                                                                      style:UIBarButtonItemStyleBordered
                                                                     target:self
                                                                     action:@selector(actionDemo)];
        self.contactsTableViewController.navigationItem.leftBarButtonItem = barButtonLeft;
    }
    
    [self presentViewController:self.contactsNavigationController animated:NO completion:nil];
}

#pragma mark - Session view
/**
 Show session view.
 @param session Session which needs to be displyed
 @param incomingCall BOOL - Yes if it is session with incoming call, otherwise NO
 */
- (void) showSessionViewControllerForSession:(Session*) session forIncomingCall:(BOOL) incomingCall
{
    NSString* sessionId = [[session conversationThread] getThreadId];
    
    //If session view controller is laredy created for this session get it from dictionary 
    ActiveSessionViewController* sessionViewContorller = [self.sessionViewControllersDictionary objectForKey:sessionId];
    
    //If session view controller doesn't exist, create a new one
    if (!sessionViewContorller)
    {
        sessionViewContorller = [[ActiveSessionViewController alloc] initWithSession:session];
        [self.sessionViewControllersDictionary setObject:sessionViewContorller forKey:sessionId];
    }
    
    sessionViewContorller.isIncomingCall = incomingCall;
    
    //Set title, and push session view conntroller
    if (sessionViewContorller.parentViewController == nil)
    {
        NSString* title = [[[session participantsArray] objectAtIndex:0] fullName];
        [self.contactsNavigationController pushViewController:sessionViewContorller animated:NO];
        [self.contactsNavigationController.navigationBar.topItem setTitle:title];
    }
}

/**
 Remove specific session view controller from the dictionary.
 @param sessionId NSString session id
 */
- (void) removeSessionViewControllerForSession:(NSString*) sessionId
{
    [self.sessionViewControllersDictionary removeObjectForKey:sessionId];
}

/**
 Prepare specific session vire controller for incoming call
 @param session Session with incomming call
 */
- (void) showIncominCallForSession:(Session*) session
{
    ActiveSessionViewController* sessionViewContorller = [self.sessionViewControllersDictionary objectForKey:[[session conversationThread] getThreadId]];
    [sessionViewContorller prepareForIncomingCall];
}

#pragma mark - UIActionSheet Delegate Methods
/**
 Handling choosed Demo option
 */
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex)
    {
        case DEMO_REMOTE_SESSION_INIT:
        {
            ((OpenPeer*)[OpenPeer sharedOpenPeer]).isRemoteSessionActivationModeOn = ![[OpenPeer sharedOpenPeer] isRemoteSessionActivationModeOn];
            [[NSNotificationCenter defaultCenter] postNotificationName:notificationRemoteSessionModeChanged object:nil];
            
            NSString* message = [[OpenPeer sharedOpenPeer] isRemoteSessionActivationModeOn] ? @"Remote session activation mode is turned ON. Please, select two openpeer contacts from your list and remote session will be created." : @"Remote session activation mode is turned OFF";
            
            UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Remote session activation"
                                                                 message:message
                                                                delegate:self
                                                       cancelButtonTitle:@"Ok"
                                                       otherButtonTitles:nil];
            [alertView show];
        }
        break;
            
        case DEMO_CHECK_AVAILABILITY:
        {
            [[ContactsManager sharedContactsManager] checkAvailability];
        }
        break;
            
        case DEMO_FACE_DETECTION_MODE:
        {
            ((OpenPeer*)[OpenPeer sharedOpenPeer]).isFaceDetectionModeOn = ![[OpenPeer sharedOpenPeer] isFaceDetectionModeOn];
            
            NSString* message = [[OpenPeer sharedOpenPeer] isFaceDetectionModeOn] ? @"Face detection mode is turned ON. Please, select contact from the list. Session will be created and face detection activated. As soon face is detected, video call will be started." : @"Face detection mode is turned OFF";
            
            UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Face detection"
                                                                 message:message
                                                                delegate:self
                                                       cancelButtonTitle:@"Ok"
                                                       otherButtonTitles:nil];
            [alertView show];
        }
        break;
            
        case DEMO_CALL_REDIAL:
            ((OpenPeer*)[OpenPeer sharedOpenPeer]).isRedialModeOn = ![[OpenPeer sharedOpenPeer] isRedialModeOn];
            break;
        
        default:
            
        break;
    }

}

- (void) prepareForViewCallSession:(Session*) session withVideo:(BOOL) withVideo
{
    ActiveSessionViewController* sessionViewContorller = [self.sessionViewControllersDictionary objectForKey:[[session conversationThread] getThreadId]];
    [sessionViewContorller prepareForCall:YES withVideo:withVideo];
}
@end
