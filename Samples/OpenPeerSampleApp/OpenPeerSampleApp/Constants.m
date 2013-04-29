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

#import "Constants.h"

//Provisioning URI
NSString* const provisioningURI = @"provisioning-stable-dev.hookflash.me";//Not in use
NSString* const outerFrameURL = @"https://app-light.hookflash.me/outer.html";
NSString* const afterLoginCompleteURL = @"OpenpeerLoginFinished";
NSString* const identityProviderDomain = @"unstable.hookflash.me";
NSString* const peerContactServiceDomain = @"unstable.hookflash.me";
NSString* const contactsLoadingtServiceDomain = @"example-light.hookflash.me";
NSString* const identityFacebookBaseURI = @"identity://facebook.com/";
NSString* const identityLinkedInBaseURI = @"identity://linkedin.com/";

NSString* const facebookContactsLoadingPage = @"fbconnections.html";

NSString * const keyOpenPeerUser = @"keyOpenPeerUser";

//User defaults keys

NSString * const archiveUserId = @"archiveUserId";
NSString * const archiveContactId = @"archiveContactId";
NSString * const archiveAccountSalt = @"archiveAccountSalt";
NSString * const archivePasswordNonce = @"archivePasswordNonce";
NSString * const archivePrivatePeerFile = @"archivePrivatePeerFile";
NSString * const archivePrivatePeerFileSecret = @"archivePrivatePeerFileSecret";
NSString * const archivePeerFilePassword = @"archivePeerFilePassword";
NSString * const archiveAssociatedIdentities = @"archiveAssociatedIdentities";
NSString * const archiveLastProfileUpdateTimestamp = @"archiveLastProfileUpdateTimestamp";

//Contact Profile xml tags
NSString* const profileXmlTagProfile = @"profile";
NSString* const profileXmlTagName = @"name";
NSString* const profileXmlTagIdentities = @"identities";
NSString* const profileXmlTagIdentityBundle = @"identityBundle";
NSString* const profileXmlTagIdentity = @"identity";
NSString* const profileXmlTagSignature = @"signature";
NSString* const profileXmlTagAvatar = @"avatar";
NSString* const profileXmlTagContactID = @"contactID";
NSString* const profileXmlTagPublicPeerFile = @"publicPeerFile";
NSString* const profileXmlTagSocialId = @"socialId";
NSString* const profileXmlAttributeId = @"id";
NSString* const profileXmlTagUserID = @"userID";

//Message types
NSString* const messageTypeText = @"text/x-application-hookflash-message-text";
NSString* const messageTypeSystem = @"text/x-application-hookflash-message-system";

NSString * const TagEvent           = @"event";
NSString * const TagId              = @"id";
NSString * const TagText            = @"text";

NSString * const systemMessageRequest = @"?";

NSString * const notificationRemoteSessionModeChanged = @"notificationRemoteSessionModeChanged";