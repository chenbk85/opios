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

@interface HOPProvisioningAccountOAuthIdentityAssociation : NSObject

/**
 Check if OAuth identity association query is completed.
 @return YES if completed, NO if not
 */
- (BOOL) isComplete;

/**
 Check if OAuth identity association query was successful.
 @return YES if succeeded, NO if not
 */
- (BOOL) didSucceed;

/**
 Cancel the OAuth identity association query.
 */
- (void) cancel;

/**
 Retrieves OAuth login URL.
 @return String representation of login URL
 */
- (NSString*) getOAuthLoginURL;

/**
 Retrieves provider type.
 @return Provider type enum
 */
- (HOPProvisioningAccountIdentityTypes) getProviderType;

/**
 Retrieves provider unique ID.
 @return String representation of provider unique ID
 */
- (NSString*) getProviderUniqueID;

/**
 Retrieves OAuth access token.
 @return String representation of OAuth access token
 */
- (NSString*) getProviderOAuthAccessToken;

/**
 Retrieves OAuth encrypted access secret.
 @return String representation of OAuth encrypted access secret
 */
- (NSString*) getProviderEncryptedOAuthAccessSecret;

/**
 Retrieves OAuth login URL.
 @param xmlResultFromJavascript NSString Client generated XML from web view response URL
 */
- (void) completeOAuthLoginProcess: (NSString*) xmlResultFromJavascript;

@end
