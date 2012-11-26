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


#import <hookflash/IStack.h>

#import "HOPStack_Internal.h"
#import "OpenPeerStorageManager.h"

#import "HOPStack.h"


@implementation HOPStack

+ (id)sharedInstance
{
    static dispatch_once_t pred = 0;
    __strong static id _sharedObject = nil;
    dispatch_once(&pred, ^{
        _sharedObject = [[self alloc] init]; // or some other init method
    });
    return _sharedObject;
}

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
        //Create stack
        stackPtr = IStack::create(openPeerStackDelegatePtr,openPeerMediaEngineDelegatePtr,openPeerConversationThreadDelegatePtr,openPeerCallDelegatePtr, [@"ID" UTF8String], [userAgent UTF8String], [deviceOs UTF8String], [platform UTF8String]);
    
        if (stackPtr)
            initiated = YES;
    }
    
    return initiated;
}

- (void) startShutdown
{
    stackPtr->startShutdown();
    [self deleteLocalDelegates];
}

- (BOOL) createLocalDelegates:(id<HOPStackDelegate>) stackDelegate mediaEngineDelegate:(id<HOPMediaEngineDelegate>) mediaEngineDelegate conversationThreadDelegate:(id<HOPConversationThreadDelegate>) conversationThreadDelegate callDelegate:(id<HOPCallDelegate>) callDelegate
{
    openPeerStackDelegatePtr = OpenPeerStackDelegate::create(stackDelegate);
    openPeerCallDelegatePtr = OpenPeerCallDelegate::create(callDelegate);
    openPeerConversationThreadDelegatePtr = OpenPeerConversationThreadDelegate::create(conversationThreadDelegate);
    openPeerMediaEngineDelegatePtr = OpenPeerMediaEngineDelegate::create(mediaEngineDelegate);
    
    return YES;
}

- (void) deleteLocalDelegates
{
    openPeerStackDelegatePtr.reset();
    openPeerMediaEngineDelegatePtr.reset();
    openPeerConversationThreadDelegatePtr.reset();
    openPeerCallDelegatePtr.reset();
}

#pragma mark - Internal methods
- (IStackPtr) getStackPtr
{
    return stackPtr;
}
@end


