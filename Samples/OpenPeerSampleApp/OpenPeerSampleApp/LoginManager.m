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

#import "LoginManager.h"
#import "MainViewController.h"
#import "OpenPeer.h"
#import "OpenPeerSDK/HOPProvisioningAccount.h"
#import "OpenPeerSDK/HOPTypes.h"
#import "StackDelegate.h"
#import "XMLWriter.h"
#import "Utility.h"
#import "ContactsManager.h"
#import "OpenPeerUser.h"
#import "OpenPeerSDK/HOPIdentityInfo.h"

@interface LoginManager ()

- (id) initSingleton;
@end
@implementation LoginManager

+ (id) sharedLoginManager
{
    static dispatch_once_t pred = 0;
    __strong static id _sharedObject = nil;
    dispatch_once(&pred, ^{
        _sharedObject = [[self alloc] initSingleton];
    });
    return _sharedObject;
}

- (id) initSingleton
{
    self = [super init];
    if (self)
    {
    }
    return self;
}

- (void) login
{
    //If peer file doesn't exists, show login view, otherwise start relogin
    if ([[[OpenPeerUser sharedOpenPeerUser] privatePeerFile] length] == 0)
    {
        [[[OpenPeer sharedOpenPeer] mainViewController] showLoginView];
    }
    else
    {
        [self startRelogin];
    }
}

- (void) logout
{
    //Delete all cookies from linkedin login page.
//    NSHTTPCookieStorage *cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
//    for (NSHTTPCookie *each in [[[cookieStorage cookiesForURL:[NSURL URLWithString:@"https://www.linkedin.com/secure/login?session_full_logout=&trk=hb_signout"]] copy] autorelease]) {
//        [cookieStorage deleteCookie:each];
//    }
    
    [Utility removeCookiesAndClearCredentialsForUrl:@"https://www.linkedin.com/secure/login?session_full_logout=&trk=hb_signout"];
    
    [[OpenPeerUser sharedOpenPeerUser] deleteUserData];
    [[HOPProvisioningAccount sharedInstance] shutdown];
    [[[OpenPeer sharedOpenPeer] mainViewController] showLoginView];
}


- (void) startLogin
{
    [[HOPProvisioningAccount sharedInstance] firstTimeOAuthLoginWithProvisioningAccountDelegate:[[OpenPeer sharedOpenPeer] provisioningAccountDelegate] provisioningURI:@"provisioning-stable-dev.hookflash.me" deviceToken:@"" oauthIdentityType:HOPProvisioningAccountIdentityTypeLinkedInID];
}

- (void) startRelogin
{
    HOPIdentityInfo* identityInfo = [[HOPIdentityInfo alloc] init];
    identityInfo.type = HOPProvisioningAccountIdentityTypeLinkedInID;
    
    [[HOPProvisioningAccount sharedInstance] reloginWithProvisioningAccountDelegate:[[OpenPeer sharedOpenPeer] provisioningAccountDelegate] provisioningURI:@"provisioning-stable-dev.hookflash.me" deviceToken:@"" userID:[[OpenPeerUser sharedOpenPeerUser] userId] accountSalt:[[OpenPeerUser sharedOpenPeerUser] accountSalt] passwordNonce:[[OpenPeerUser sharedOpenPeerUser] passwordNonce] password:[[OpenPeerUser sharedOpenPeerUser] peerFilePassword] privatePeerFile:[[OpenPeerUser sharedOpenPeerUser] privatePeerFile] lastProfileUpdatedTimestamp:[[OpenPeerUser sharedOpenPeerUser] lastProfileUpdateTimestamp]  previousIdentities:[NSArray arrayWithObject:identityInfo ]];
    [identityInfo release];
}

- (void) onLoginSocialUrlReceived:(NSString*) url
{    
    [[[OpenPeer sharedOpenPeer] mainViewController] showWebLoginView:url];
}

- (void) onCredentialProviderResponseReceived:(NSString*) url
{
    XMLWriter *xmlWriter = [[XMLWriter alloc] init];
    [xmlWriter writeStartElement:@"result"];
    [xmlWriter writeAttribute:@"xmlns" value:@"http://www.hookflash.com/provisioning/1.0/message"];
    [xmlWriter writeAttribute:@"method" value:@"oauth-login-webpage"];
    [xmlWriter writeAttribute:@"id" value:@"abc"];
    NSArray *array = [url componentsSeparatedByString:@"&"];

    for (NSString* element in array)
    {
        NSArray *attributeValue = [element componentsSeparatedByString:@"="];
        NSString *attribute = [attributeValue objectAtIndex:0];
        NSString *value = [attributeValue objectAtIndex:1];

        if ([attribute isEqualToString:@"properties"])
        {
            NSString *decodedValue = (NSString *) CFURLCreateStringByReplacingPercentEscapesUsingEncoding(NULL, (CFStringRef) [value stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding], CFSTR(""), kCFStringEncodingUTF8);
            decodedValue = (NSString *) CFURLCreateStringByReplacingPercentEscapesUsingEncoding(NULL, (CFStringRef) [decodedValue stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding], CFSTR(""), kCFStringEncodingUTF8);
            
            NSString *decodedAccountProperties = [Utility decodeBase64:decodedValue];
            //    result is in format: "stun=173.192.183.148&stun=173.192.183.147&stun=173.192.183.146$turn=173.192.183.146|toto|toto&turn=173.192.183.147|toto4|toto4&turn=173.192.183.148|toto|toto"
            //networkURI=http://bootstrapper.hookflash.me&stun=173.192.183.147&stun=173.192.183.146&stun=173.192.183.148$turn=173.192.183.147|toto2|toto2&turn=173.192.183.148|toto4|toto4&turn=173.192.183.146|toto3|toto3
            [xmlWriter writeStartElement:attribute];
            NSArray *attributeArray = [decodedAccountProperties componentsSeparatedByString:@"&"];
            NSArray *pair = [[attributeArray objectAtIndex:0] componentsSeparatedByString:@"="];
            NSString *propertiesAttribute = [pair objectAtIndex:0];
            NSString *propertiesValue = [pair objectAtIndex:1];
            [xmlWriter writeStartElement:propertiesAttribute];
            [xmlWriter writeCharacters:propertiesValue];
            [xmlWriter writeEndElement];
            
            NSRange replaceRange = [decodedAccountProperties rangeOfString:@"&"];
            NSString *decodedStunsAndTurns = [decodedAccountProperties substringFromIndex:replaceRange.location+1  ];
            
            
            NSArray *stunsAndTurnsArray = [decodedStunsAndTurns componentsSeparatedByString:@"$"];
            
            NSArray *stuns = [[stunsAndTurnsArray objectAtIndex:0] componentsSeparatedByString:@"&"];
            NSArray *turns = [[stunsAndTurnsArray objectAtIndex:1] componentsSeparatedByString:@"&"];
            
            [xmlWriter writeStartElement:@"turnServer"];
            NSString *turnAddressString = @"";
            for (NSString* turn in turns)
            {
                NSString *turnAddressValue = [[[[turn componentsSeparatedByString:@"="] objectAtIndex:1] componentsSeparatedByString:@"|"] objectAtIndex:0];
                if (![turnAddressString isEqualToString:@""])
                {
                    turnAddressString = [turnAddressString stringByAppendingString:@","];
                }
                turnAddressString = [turnAddressString stringByAppendingString:turnAddressValue];
            }
            [xmlWriter writeCharacters:turnAddressString];
            [xmlWriter writeEndElement];
            NSString *turnUsername = [[[turns objectAtIndex:0] componentsSeparatedByString:@"|"] objectAtIndex:1];
            NSString *turnPassword = [[[turns objectAtIndex:0] componentsSeparatedByString:@"|"] objectAtIndex:2];;
            [xmlWriter writeStartElement:@"turnUsername"];
            [xmlWriter writeCharacters:turnUsername];
            [xmlWriter writeEndElement];
            [xmlWriter writeStartElement:@"turnPassword"];
            [xmlWriter writeCharacters:turnPassword];
            [xmlWriter writeEndElement];
            
            [xmlWriter writeStartElement:@"stunServer"];
            NSString *stunsString = @"";
            for (NSString* stun in stuns)
            {
                NSString *stunValue = [[stun componentsSeparatedByString:@"="] objectAtIndex:1];
                if (![stunsString isEqualToString:@""])
                {
                    stunsString = [stunsString stringByAppendingString:@","];
                }
                stunsString = [stunsString stringByAppendingString:stunValue];
            }
            [xmlWriter writeCharacters:stunsString];
            [xmlWriter writeEndElement];
            
            [xmlWriter writeEndElement];
        }
        else
        {
            // add key-value
            [xmlWriter writeStartElement:attribute];
            [xmlWriter writeCharacters:value];
            [xmlWriter writeEndElement];
            
            
        }
    }
    [xmlWriter writeEndElement];

    [[HOPProvisioningAccount sharedInstance] completeOAuthLoginProcess:[xmlWriter toString]];
    [xmlWriter release];
}

- (void) onUserLoggedIn
{
    [[OpenPeerUser sharedOpenPeerUser] saveUserData];

    [[ContactsManager sharedContactsManager] loadContacts];
}
@end
