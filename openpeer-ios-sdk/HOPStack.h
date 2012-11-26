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


#import <Foundation/Foundation.h>
#import "HOPProtocols.h"

@class IStackPtrWrapper;

/**
 Singleton class to represent the openpeer stack.
 */
@interface HOPStack : NSObject

/**
 Returns singleton object of this class.
 */
+ (id)sharedInstance;

/**
 Initialise delegates objects required for communication between core and client.
 @param stackDelegate IStack delegate
 @param mediaEngineDelegate IMediaEngine delegate
 @param conversationThreadDelegate IConversationThread delegate
 @param callDelegate ICall delegate
 @param userAgent e.g. "App Name/App version (iOS/iPad)"
 @param deviceOs iOs version (e.g. "iOS 5.1.1") 
 @param platform Plafrom name (e.g. "iPhone 4S", "iPod Touch 4G")
 @returns YES if initialisation was sucessfull
 */
- (BOOL) initStackDelegate:(id<HOPStackDelegate>) stackDelegate mediaEngineDelegate:(id<HOPMediaEngineDelegate>) mediaEngineDelegate conversationThreadDelegate:(id<HOPConversationThreadDelegate>) conversationThreadDelegate callDelegate:(id<HOPCallDelegate>) callDelegate userAgent:(NSString*) userAgent deviceOs:(NSString*) deviceOs platform:(NSString*) platform;

/**
 Shoutdown stack.
 */
- (void) startShutdown;
@end
