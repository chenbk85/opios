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

#import "LoginViewController.h"
#import "MainViewController.h"
#import "LoginManager.h"
#import "Constants.h"

@interface LoginViewController ()
@property (weak, nonatomic) IBOutlet UIButton *buttonLinkedIn;
@property (weak, nonatomic) IBOutlet UIButton *buttonFacebook;

@end

@implementation LoginViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
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

- (IBAction)actionLoginWithFacebook:(id)sender
{
    [[LoginManager sharedLoginManager] startLoginUsingIdentityURI:identityFacebookBaseURI];
}

- (IBAction)actionLoginWithLinkedIn:(id)sender
{
    [[LoginManager sharedLoginManager] startLoginUsingIdentityURI:identityLinkedInBaseURI];
}


- (void)viewDidUnload {
    [self setButtonLinkedIn:nil];
    [self setButtonFacebook:nil];
    [super viewDidUnload];
}

- (void) prepareForLogin
{
    self.buttonLinkedIn.hidden = [[LoginManager sharedLoginManager] isAssociatedIdentity:identityLinkedInBaseURI];
    self.buttonLinkedIn.enabled = !self.buttonLinkedIn.hidden;
    self.buttonFacebook.hidden = [[LoginManager sharedLoginManager] isAssociatedIdentity:identityFacebookBaseURI];
    self.buttonFacebook.enabled = !self.buttonFacebook.hidden;
}
@end
