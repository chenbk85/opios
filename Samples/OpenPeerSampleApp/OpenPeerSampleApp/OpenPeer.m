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

#import "OpenPeer.h"
#import "OpenPeerUser.h"
#import "Utility.h"
//SDK
#import "OpenpeerSDK/HOPStack.h"
#import "OpenpeerSDK/HOPLogger.h"
//Managers
#import "LoginManager.h"
//Delegates
#import "StackDelegate.h"
#import "MediaEngineDelegate.h"
#import "ConversationThreadDelegate.h"
#import "CallDelegate.h"
#import "AccountDelegate.h"
#import "IdentityDelegate.h"
//View controllers
#import "MainViewController.h"

//Private methods
@interface OpenPeer ()

- (void) createDelegates;

@end


@implementation OpenPeer

/**
 Retrieves singleton object of the Open Peer.
 @return Singleton object of the Open Peer.
 */
+ (id) sharedOpenPeer
{
    static dispatch_once_t pred = 0;
    __strong static id _sharedObject = nil;
    dispatch_once(&pred, ^{
        _sharedObject = [[self alloc] init];
    });
    return _sharedObject;
}

/**
 Method used initialization of open peer stack. After initialization succeeds, login screen is showed.
 @param inMainViewController MainViewController Input main view controller.
 */
- (void) prepareWithMainViewController:(MainViewController *)inMainViewController
{
    self.mainViewController = inMainViewController;
    
    //Set log levels and start logging
    [self startLogger];
    
    //Created all delegates required for openpeer stack initialization.
    [self createDelegates];

    //Init openpeer stack and set created delegates
    [[HOPStack sharedStack] setupWithStackDelegate:self.stackDelegate mediaEngineDelegate:self.mediaEngineDelegate deviceID:@"ID" userAgent:[Utility getUserAgentName] deviceOs:[Utility getDeviceOs] system:[Utility getPlatform]];
    
    //Start with login procedure and display login view
    [[LoginManager sharedLoginManager] login];
}

/**
 Method used for all delegates creation. Delegates will catch events from the Open Peer SDK and handle them properly.
 */
- (void) createDelegates
{
    self.stackDelegate = [[StackDelegate alloc] init];
    self.mediaEngineDelegate = [[MediaEngineDelegate alloc] init];
    self.conversationThreadDelegate = [[ConversationThreadDelegate alloc] init];
    self.callDelegate = [[CallDelegate alloc] init];
    self.accountDelegate = [[AccountDelegate alloc] init];
    self.identityDelegate = [[IdentityDelegate alloc] init];
}

/**
 Method used for setting log levels and starting logger.
 */
- (void) startLogger
{
    //For each system you can choose log level from HOPClientLogLevelNone (turned off) to HOPClientLogLevelTrace (most detail).
    [HOPLogger setLogLevel:HOPLoggerLevelNone];
    [HOPLogger setLogLevelbyName:@"hookflash_gui" level:HOPLoggerLevelNone];
    [HOPLogger setLogLevelbyName:@"hookflash" level:HOPLoggerLevelNone];
    [HOPLogger setLogLevelbyName:@"hookflash_services" level:HOPLoggerLevelTrace];
    [HOPLogger setLogLevelbyName:@"zsLib" level:HOPLoggerLevelNone];
    [HOPLogger setLogLevelbyName:@"hookflash_services_http" level:HOPLoggerLevelTrace];
    [HOPLogger setLogLevelbyName:@"hookflash_stack_message" level:HOPLoggerLevelTrace];
    [HOPLogger setLogLevelbyName:@"hookflash_stack" level:HOPLoggerLevelTrace];
    [HOPLogger setLogLevelbyName:@"hookflash_webrtc" level:HOPLoggerLevelNone];
    //Srart logger without colorized output
    [HOPLogger installStdOutLogger:NO];
}
@end
