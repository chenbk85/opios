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

#import "ContactsTableViewController.h"
#import "ContactsManager.h"
#import "SessionManager.h"
#import "Contact.h"
#import <OpenpeerSDK/HOPContact.h>
#import "OpenPeer.h"
#import "ActivityIndicatorViewController.h"
#import "MainViewController.h"

@interface ContactsTableViewController ()

@end

@implementation ContactsTableViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationController.navigationBar.hidden = NO;
    //[self.activityIndicator setHidesWhenStopped:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) onContactsLoadingStarted
{    
    //[self.activityIndicator startAnimating];
    //[self showActivityIndicator:YES withText:@"Getting contacts from the LinkedIn ..."];
    //[[[OpenPeer sharedOpenPeer] mainViewController] showActivityIndicator:YES withText:@"Getting contacts from social provider ..."];
    [[ActivityIndicatorViewController sharedActivityIndicator] showActivityIndicator:YES withText:@"Getting contacts from social provider ..." inView:self.view];
}

- (void) onContactsPeerFilesLoadingStarted
{
    //[self.activityIndicator startAnimating];
    //[self showActivityIndicator:YES withText:@"Getting peer files for contacts ..."];
    //[[[OpenPeer sharedOpenPeer] mainViewController] showActivityIndicator:YES withText:@"Getting peer files for contacts ..."];
    [[ActivityIndicatorViewController sharedActivityIndicator] showActivityIndicator:YES withText:@"Getting peer files for contacts ..." inView:self.view];
}
- (void) onContactsLoaded
{
    [self.contactsTableView reloadData];
    [[ActivityIndicatorViewController sharedActivityIndicator] showActivityIndicator:NO withText:nil inView:nil];
}

#pragma  mark - UINavigationControllerDelegate

- (void)navigationController:(UINavigationController *)navigationController
       didShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    [viewController viewDidAppear:animated];
}

- (void) navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    [viewController viewWillAppear:animated];
}


#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[[ContactsManager sharedContactsManager] contactArray] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"ContactCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil)
    {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier] autorelease];
    }
    
    Contact* contact = [[[ContactsManager sharedContactsManager] contactArray] objectAtIndex:indexPath.row];
    [cell.textLabel setText:contact.fullName];
    
    if ([[contact.hopContact getPeerFile] length] > 0)
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    else
        cell.accessoryType = UITableViewCellAccessoryNone;
    
    //[cell.detailTextLabel setText:contact.profession];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50.0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    //if ([tableView cellForRowAtIndexPath:indexPath].accessoryType == UITableViewCellAccessoryDisclosureIndicator)
    {
        Contact* contact = [[[ContactsManager sharedContactsManager] contactArray] objectAtIndex:indexPath.row];
        if (contact)
        {
    
            Session* session = [[SessionManager sharedSessionManager] getSessionForContact:contact];
            if (!session)
                session = [[SessionManager sharedSessionManager] createSessionForContact:contact];
            
            [[[OpenPeer sharedOpenPeer] mainViewController] showSessionViewControllerForSession:session forIncomingCall:NO];
            //[[[OpenPeer sharedOpenPeer] mainViewController] showIncominCallForSession:session];
//            if (session)
//            {
//                SessionViewController* sessionViewController = [[SessionViewController alloc] initWithSession:session];
//                [self.navigationController pushViewController:sessionViewController animated:NO];
//                [sessionViewController release];
//            }
        }
        
    }
}

- (void)dealloc {

    [super dealloc];
}


@end
