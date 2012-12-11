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

#import "ContactsManager.h"
#import "MainViewController.h"
#import "ContactsTableViewController.h"
#import "OpenPeer.h"
#import "Contact.h"
#import "SBJsonParser.h"
#import <OpenpeerSDK/HOPProvisioningAccount.h>
#import <OpenpeerSDK/HOPProvisioningAccountIdentityLookupQuery.h>
#import <OpenpeerSDK/HOPIdentity.h>
#import <OpenpeerSDK/HOPLookupProfileInfo.h>
#import <OpenpeerSDK/HOPProvisioningAccountPeerFileLookupQuery.h>

@interface ContactsManager ()

- (id) initSingleton;

@end
@implementation ContactsManager

/**
 Retrieves singleton object of the Contacts Manager.
 @return Singleton object of the Contacts Manager.
 */
+ (id) sharedContactsManager
{
    static dispatch_once_t pred = 0;
    __strong static id _sharedObject = nil;
    dispatch_once(&pred, ^{
        _sharedObject = [[self alloc] initSingleton];
    });
    return _sharedObject;
}

/**
 Initialize singleton object of the Contacts Manager.
 @return Singleton object of the Contacts Manager.
 */
- (id) initSingleton
{
    self = [super init];
    if (self)
    {
        self.linkedinContactsWebView = [[[UIWebView alloc] init] autorelease];
        self.linkedinContactsWebView.delegate = self;
        
        self.contactArray = [[NSMutableArray alloc] init];
    }
    return self;
}

/**
 Initiates contacts loading procedure.
 */
- (void) loadContacts
{
    [[[OpenPeer sharedOpenPeer] mainViewController] showContactsTable];
    [[[[OpenPeer sharedOpenPeer] mainViewController] contactsTableViewController] onContactsLoadingStarted];
    
    NSString* urlAddress = [NSString stringWithFormat:@"http://%@/%@", @"provisioning-stable-dev.hookflash.me", @"/api_web_res/liconnections.html"];
    
    NSURL *url = [NSURL URLWithString:urlAddress];
    
    //URL Requst Object
    NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
    
    //Load the request in the UIWebView.
    [self.linkedinContactsWebView loadRequest:requestObj];
}

/**
 Web view which will perform contacts loading procedure.
 */
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSString *requestString = [[request URL] absoluteString];
    if ([requestString hasPrefix:@"hookflash-js-frame:"]) {
        
        NSArray *components = [requestString componentsSeparatedByString:@":"];
        
        NSString *function = (NSString*)[components objectAtIndex:1];
        
        requestString = [requestString stringByReplacingOccurrencesOfString:function withString:@""];
        requestString = [requestString stringByReplacingOccurrencesOfString:(NSString*)[components objectAtIndex:0] withString:@""];
        requestString = [requestString stringByReplacingCharactersInRange:NSMakeRange(0, 2) withString:@""];
        
        NSString *params = [requestString stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        
        NSString *functionNameSelector = [NSString stringWithFormat:@"%@:", function];
        [self performSelector:NSSelectorFromString(functionNameSelector) withObject:params];
        return NO;
    }
    return YES;
}

/**
 Parse JSON to get the profile for logged user.
 @param input NSString JSON input for processing.
 */
- (void)proccessMyProfile:(NSString*)input
{
    NSString *jsMethodName = @"getAllConnections()";
    NSNumber *lastUpdateTimestamp = 0;//[[StorageManager storageManager] getLastUpdateTimestamp];
    if ([lastUpdateTimestamp intValue] != 0)
    {
        jsMethodName = [NSString stringWithFormat:@"getNewConnections(%@)", [lastUpdateTimestamp stringValue]];
    }
    
    [self.linkedinContactsWebView performSelectorOnMainThread:@selector(stringByEvaluatingJavaScriptFromString:) withObject:jsMethodName waitUntilDone:NO];
}

/**
 Process connections.
 @param input NSString JSON input for processing.
 */
- (void)proccessConnections:(NSString*)input
{
    NSString* const keyJSONContactId          = @"id";
    NSString* const keyJSONContactFirstName   = @"firstName";
    NSString* const keyJSONContacLastName     = @"lastName";
    NSString* const keyJSONContactProfession  = @"headline";
    NSString* const keyJSONContactPictureURL  = @"pictureUrl";
    NSString* const keyJSONContactFullName    = @"fullName";
    
    //Parse JSON to get the contacts
    SBJsonParser *jsonParser = [[SBJsonParser alloc] init];
    NSError *error = nil;
    NSArray *result = [jsonParser objectWithString:input error:&error];
    [jsonParser release], jsonParser = nil;
    
    if (!error)
    {
       for (NSDictionary* dict in result)
       {
           NSString* providerContactId = [dict objectForKey:keyJSONContactId];
           
           if (providerContactId)
           {
               NSString *fullName = [[NSString stringWithFormat:@"%@ %@", [dict objectForKey:keyJSONContactFirstName], [dict objectForKey:keyJSONContacLastName]] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
               if (fullName)
               {
                   NSString* profession = [dict objectForKey:keyJSONContactProfession];
                   NSString *avatarUrl = [dict objectForKey:keyJSONContactPictureURL];
                   
                   Contact* contact = [[Contact alloc] initWithFullName:fullName profession:profession avatarUrl:avatarUrl identityProvider:HOPProvisioningAccountIdentityTypeLinkedInID identityContactId:providerContactId];
                   [self.contactArray addObject:contact];
               }
           }
       }
    }
    
    [[[[OpenPeer sharedOpenPeer] mainViewController] contactsTableViewController] onContactsLoaded];
    
    [self contactsLookupQuery:self.contactArray];
}

- (void)contactsLookupQuery:(NSArray *)contacts
{
    NSMutableArray* identities = [[NSMutableArray alloc] init];
    
    for (Contact* contact in self.contactArray)
    {
        for (HOPIdentity* identity in contact.identities)
        {
            [identities addObject:identity];
        }
        
    }
    
    HOPProvisioningAccountIdentityLookupQuery* lookupQuery = [[HOPProvisioningAccount sharedProvisioningAccount] identityLookup:self identities:identities];
    
    [identities release];
}

- (void) onAccountIdentityLookupQueryComplete:(HOPProvisioningAccountIdentityLookupQuery*) query
{
    if([query isComplete] && [query didSucceed])
    {
        for(HOPIdentity* identity in [query getIdentities])
        {
            HOPLookupProfileInfo* lookupProfileInfo = [query getLookupProfile:identity];
            
            for (Contact* contact in self.contactArray)
            {
                HOPIdentity* contactIdentity = [contact.identities objectAtIndex:0];
                if ([contactIdentity.identityId isEqualToString:identity.identityId])
                {
                    contact.contactId = lookupProfileInfo.contactId;
                    contact.userId = lookupProfileInfo.userId;
                    contact.lastProfileUpdateTimestamp = lookupProfileInfo.lastProfileUpdateTimestamp;
                }

            }
            
        }
        [[[[OpenPeer sharedOpenPeer] mainViewController] contactsTableViewController] onContactsLoaded];
        
        [self peerFileLookupQuery:self.contactArray];
    }

}

- (void)peerFileLookupQuery:(NSArray *)contacts
{
    NSMutableArray* userIds = [[NSMutableArray alloc] init];
    NSMutableArray* contactIds = [[NSMutableArray alloc] init];
    
    for (Contact* contact in self.contactArray)
    {
        if ([[contact contactId] length] > 0 && [[contact userId] length] > 0)
        {
            [userIds addObject:contact.userId];
            [contactIds addObject:contact.contactId];
        }
        
    }
    
    HOPProvisioningAccountPeerFileLookupQuery* lookupQuery = [[HOPProvisioningAccount sharedProvisioningAccount] peerFileLookup:self userIDs:userIds associatedContactIDs:contactIds];
    
    [userIds release];
    [contactIds release];
}

- (void) onAccountPeerFileLookupQueryComplete:(HOPProvisioningAccountPeerFileLookupQuery*) query
{
    NSArray* userIDs = [query getUserIDs];
    
    for (NSString* userId in userIDs)
    {
        NSString* peerFile = [query getPublicPeerFileString:userId];
        Contact* contact = [self getContactForUserId:userId];
        contact.peerFile = peerFile;
    }
}

- (Contact*) getContactForUserId:(NSString*) userId
{
    for (Contact* contact in self.contactArray)
    {
        if ([contact.userId isEqualToString:userId])
        {
            return contact;
        }
    }
    return nil;
}
@end
