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

@interface ContactsManager ()

- (id) initSingleton;
@end
@implementation ContactsManager

+ (id) sharedContactsManager
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
        self.linkedinContactsWebView = [[[UIWebView alloc] init] autorelease];
        self.linkedinContactsWebView.delegate = self;
        
        self.contactArray = [[NSMutableArray alloc] init];
    }
    return self;
}

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

- (void)proccessMyProfile:(NSString*)input
{
    //Parse JSON to get the profile for logged user

    NSString *jsMethodName = @"getAllConnections()";
    NSNumber *lastUpdateTimestamp = 0;//[[StorageManager storageManager] getLastUpdateTimestamp];
    if ([lastUpdateTimestamp intValue] != 0)
    {
        jsMethodName = [NSString stringWithFormat:@"getNewConnections(%@)", [lastUpdateTimestamp stringValue]];
    }
    
    [self.linkedinContactsWebView performSelectorOnMainThread:@selector(stringByEvaluatingJavaScriptFromString:) withObject:jsMethodName waitUntilDone:NO];
}

//process LinkedIn connections
- (void)proccessConnections:(NSString*)input
{
    //Parse JSON to get the contacts
    [[[[OpenPeer sharedOpenPeer] mainViewController] contactsTableViewController] onContactsLoaded];
}
@end
