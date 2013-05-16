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

#import "WebLoginViewController.h"
#import "LoginManager.h"
#import "OpenPeer.h"
#import "ActivityIndicatorViewController.h"
#import "Constants.h"
#import "Utility.h"

@interface WebLoginViewController ()

@property (nonatomic) BOOL outerFrameInitialised;
@end

@implementation WebLoginViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.outerFrameInitialised = NO;
    }
    return self;
}

- (id)init
{
    self = [self initWithNibName:@"WebLoginViewController" bundle:nil];
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

- (void) openLoginUrl:(NSString*) url
{
    [[ActivityIndicatorViewController sharedActivityIndicator] showActivityIndicator:YES withText:@"Opening login page ..." inView:self.view.superview];
    [self.loginWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]]];
}

- (void) passMessageToJS:(NSString*) message
{
    //NSString* javaScript = [NSString stringWithFormat:@"JSMethod:%@",message];
    [self.loginWebView stringByEvaluatingJavaScriptFromString:message];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSString *requestString = [[request URL] absoluteString];
    NSLog(@"Login process - web request: %@", requestString);
    
    if ([requestString hasPrefix:@"https://datapass.hookflash.me/?method="] || [requestString hasPrefix:@"http://datapass.hookflash.me/?method="])
    {
        NSString *function = [Utility getFunctionNameForRequest:requestString];
        NSString *params = [Utility getParametersNameForRequest:requestString];

        params = [params stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            
        NSString *functionNameSelector = [NSString stringWithFormat:@"%@:", function];
        //Execute JSON parsing in function read from requestString.
        if ([[LoginManager sharedLoginManager] respondsToSelector:NSSelectorFromString(functionNameSelector)])
            [[LoginManager sharedLoginManager] performSelector:NSSelectorFromString(functionNameSelector) withObject:params];
        return NO;
    }
    else
    {
        if ([requestString rangeOfString:afterLoginCompleteURL].length > 0)
        {
            [[LoginManager sharedLoginManager] onLoginRedirectURLReceived];
            return NO;
        }
    }
    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{

}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    //Login page is opened, so remove the activity indicator
    [[ActivityIndicatorViewController sharedActivityIndicator] showActivityIndicator:NO withText:nil inView:nil];
    
    NSString *requestString = [[[webView request] URL] absoluteString];
    if (!self.outerFrameInitialised && [requestString isEqualToString:outerFrameURL])
    {
        self.outerFrameInitialised = YES;
        [[LoginManager sharedLoginManager] onOuterFrameLoaded];
    }
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    NSLog(@"UIWebView _ERROR_ : %@",[error localizedDescription]);
}

- (void) clientNotify:(NSString*) message
{

}
@end
