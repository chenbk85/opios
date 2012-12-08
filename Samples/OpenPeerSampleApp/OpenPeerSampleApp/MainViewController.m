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

#import "MainViewController.h"
#import "LoginViewController.h"
#import "WebLoginViewController.h"
#import "ContactsTableViewController.h"

#import "LoginManager.h"

@interface MainViewController ()

- (void) removeAllSubViews;

@end

@implementation MainViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        // Custom initialization
    }
    return self;
}

- (void)dealloc
{
    [_loginViewController release];
    [super dealloc];
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

- (void) removeAllSubViews
{
    [self dismissViewControllerAnimated:NO completion:nil];
    [[[self view] subviews] makeObjectsPerformSelector: @selector(removeFromSuperview)];
}

#pragma mark - Login views
- (void) showLoginView
{
    if (!self.loginViewController)
    {
        self.loginViewController = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
    }
    
    [self removeAllSubViews];
    [self.view addSubview:self.loginViewController.view];
}

- (void) showWebLoginView:(NSString*) url
{
    if (!self.webLoginViewController)
        self.webLoginViewController = [[WebLoginViewController alloc] initWithNibName:@"WebLoginViewController" bundle:nil];
    
    if (url)
    {
        [self removeAllSubViews];
        [self.view addSubview:self.webLoginViewController.view];
        [self.webLoginViewController openLoginUrl:url];
    }
}

#pragma mark - Contacts views

- (void)showContactsTable
{
    [self removeAllSubViews];
    
    if (!self.contactsTableViewController)
        self.contactsTableViewController = [[ContactsTableViewController alloc] initWithNibName:@"ContactsTableViewController" bundle:nil];
    
    if (!self.contactsNavigationController)
    {
        self.contactsNavigationController = [[UINavigationController alloc] initWithRootViewController:self.contactsTableViewController];
        [self.contactsNavigationController.navigationBar.topItem setTitle:@"Contacts"];
        UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithTitle:@"LogOut"
                                                                      style:UIBarButtonItemStyleBordered
                                                                     target:[LoginManager sharedLoginManager]
                                                                     action:@selector(logout)];
        self.contactsTableViewController.navigationItem.rightBarButtonItem = barButton;
        [barButton release];
    }
    
    [self presentViewController:self.contactsNavigationController animated:NO completion:nil];
}
@end
