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


#import <hookflash/core/IStack.h>

#import "HOPStack_Internal.h"
#import "OpenPeerStorageManager.h"

#import "HOPStack.h"


@implementation HOPStack

+ (id)sharedStack
{
    static dispatch_once_t pred = 0;
    __strong static id _sharedObject = nil;
    dispatch_once(&pred, ^{
        _sharedObject = [[self alloc] init]; // or some other init method
    });
    return _sharedObject;
}

- (void) setupWithStackDelegate:(id<HOPStackDelegate>) stackDelegate mediaEngineDelegate:(id<HOPMediaEngineDelegate>) mediaEngineDelegate deviceID:(NSString*) deviceID userAgent:(NSString*) userAgent deviceOs:(NSString*) deviceOs system:(NSString*) system
{
    //Check if delegates are nil
    if (!stackDelegate || !mediaEngineDelegate)
        [NSException raise:NSInvalidArgumentException format:@"Passed invalid delegates!"];
    
    //Check if other arguments are valid
    if ( ([userAgent length] == 0 ) || ([deviceOs length] == 0 ) || ([system length] == 0 ) || ([deviceID length] == 0))
        [NSException raise:NSInvalidArgumentException format:@"Invalid system information!"];
    
    [self createLocalDelegates:stackDelegate mediaEngineDelegate:mediaEngineDelegate];
    
    IStack::singleton()->setup(openPeerStackDelegatePtr, openPeerMediaEngineDelegatePtr, [deviceID UTF8String], [userAgent UTF8String], [deviceOs UTF8String], [system UTF8String]);
}
/*
- (BOOL) initStackDelegate:(id<HOPStackDelegate>) stackDelegate mediaEngineDelegate:(id<HOPMediaEngineDelegate>) mediaEngineDelegate conversationThreadDelegate:(id<HOPConversationThreadDelegate>) conversationThreadDelegate callDelegate:(id<HOPCallDelegate>) callDelegate userAgent:(NSString*) userAgent deviceOs:(NSString*) deviceOs platform:(NSString*) platform
{
    BOOL initiated = NO;
    
    //Check if delegates are nil
    if (!stackDelegate || !mediaEngineDelegate || !conversationThreadDelegate || !callDelegate)
        return initiated;
    
    //Check if other arguments are valid
    if ( ([userAgent length] == 0 ) || ([deviceOs length] == 0 ) || ([platform length] == 0 ) )
        return initiated;
    
    //Create delegates wrappers and init them with delegates created by user
    BOOL delegatesCreated = [self createLocalDelegates:stackDelegate mediaEngineDelegate:mediaEngineDelegate conversationThreadDelegate:conversationThreadDelegate callDelegate:callDelegate];
    
    if (delegatesCreated)
    {
        //Create client
        IClient::setup();
        clientPtr = IClient::singleton();
        
        //Create stack
        stackPtr = IStack::create(openPeerStackDelegatePtr,openPeerMediaEngineDelegatePtr,openPeerConversationThreadDelegatePtr,openPeerCallDelegatePtr, [@"ID" UTF8String], [userAgent UTF8String], [deviceOs UTF8String], [platform UTF8String]);
        
        if (stackPtr && clientPtr)
            initiated = YES;
    }
    
    return initiated;
}*/

- (void) shutdown
{
    IStack::singleton()->shutdown();
    [self deleteLocalDelegates];
}


- (void) createLocalDelegates:(id<HOPStackDelegate>) stackDelegate mediaEngineDelegate:(id<HOPMediaEngineDelegate>) mediaEngineDelegate 
{
    openPeerStackDelegatePtr = OpenPeerStackDelegate::create(stackDelegate);
    //openPeerCallDelegatePtr = OpenPeerCallDelegate::create(callDelegate);
    //openPeerConversationThreadDelegatePtr = OpenPeerConversationThreadDelegate::create(conversationThreadDelegate);
    openPeerMediaEngineDelegatePtr = OpenPeerMediaEngineDelegate::create(mediaEngineDelegate);
}

- (void) deleteLocalDelegates
{
    openPeerStackDelegatePtr.reset();
    openPeerMediaEngineDelegatePtr.reset();
    //openPeerConversationThreadDelegatePtr.reset();
    //openPeerCallDelegatePtr.reset();
}
/*
#pragma mark - IClient methods wrapper

+ (void) setup
{
    IClient::setup();
}

- (void) processMessagePutInGUIQueue
{
    if(clientPtr)
    {
        clientPtr->processMessagePutInGUIQueue();
    }
    else
    {
        [NSException raise:NSInvalidArgumentException format:@"Invalid OpenPeer client pointer!"];
    }
}

- (void) finalizeShutdown
{
    if(clientPtr)
    {
        clientPtr->finalizeShutdown();
    }
    else
    {
        [NSException raise:NSInvalidArgumentException format:@"Invalid OpenPeer client pointer!"];
    }
}

+ (void) installStdOutLogger: (BOOL) colorizeOutput
{
    IClient::installStdOutLogger(colorizeOutput);
}

+ (void) installFileLogger: (NSString*) filename colorizeOutput: (BOOL) colorizeOutput
{
    IClient::installFileLogger([filename UTF8String], colorizeOutput);
}

+ (void) installTelnetLogger: (unsigned short) listenPort maxSecondsWaitForSocketToBeAvailable:(unsigned long) maxSecondsWaitForSocketToBeAvailable colorizeOutput: (BOOL) colorizeOutput
{
    IClient::installTelnetLogger(listenPort, maxSecondsWaitForSocketToBeAvailable, colorizeOutput);
}

+ (void) installOutgoingTelnetLogger: (NSString*) serverToConnect colorizeOutput: (BOOL) colorizeOutput stringToSendUponConnection: (NSString*) stringToSendUponConnection
{
    IClient::installOutgoingTelnetLogger([serverToConnect UTF8String], colorizeOutput);
}

+ (void) installWindowsDebuggerLogger
{
    IClient::installWindowsDebuggerLogger();
}

+ (void) installCustomLogger: (id<HOPStackDelegate>) delegate
{
    IClient::installCustomLogger();
}

+ (unsigned int) getGUISubsystemUniqueID
{
    return IClient::getGUISubsystemUniqueID();
}

+ (HOPClientLogLevels) getLogLevel: (unsigned int) subsystemUniqueID
{
    return (HOPClientLogLevels) IClient::getLogLevel(subsystemUniqueID);
}

+ (void) setLogLevel: (HOPClientLogLevels) level
{
    IClient::setLogLevel((IClient::Log::Level) level);
}

+ (void) setLogLevelByID: (unsigned long) subsystemUniqueID level: (HOPClientLogLevels) level
{
    IClient::setLogLevel((zsLib::PTRNUMBER)subsystemUniqueID, (IClient::Log::Level) level);
}

+ (void) setLogLevelbyName: (NSString*) subsystemName level: (HOPClientLogLevels) level
{
    IClient::setLogLevel([subsystemName UTF8String], (IClient::Log::Level) level);
}

+ (void) log: (unsigned int) subsystemUniqueID severity: (HOPClientLogSeverities) severity level: (HOPClientLogLevels) level message: (NSString*) message function: (NSString*) function filePath: (NSString*) filePath lineNumber: (unsigned long) lineNumber
{
    IClient::log((zsLib::PTRNUMBER) subsystemUniqueID, (IClient::Log::Severity) severity, (IClient::Log::Level) level, [message UTF8String], [function UTF8String], [filePath UTF8String], lineNumber);
}
*/

#pragma mark - Internal methods
- (IStackPtr) getStackPtr
{
    return IStack::singleton();
}

@end


