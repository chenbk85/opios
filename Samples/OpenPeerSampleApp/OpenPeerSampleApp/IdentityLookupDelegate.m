//
//  IdentityLookupDelegate.m
//  OpenPeerSampleApp
//
//  Created by Sergej on 4/26/13.
//  Copyright (c) 2013 Sergej. All rights reserved.
//

#import "IdentityLookupDelegate.h"
#import <OpenpeerSDK/HOPIdentityLookup.h>
#import "ContactsManager.h"
@implementation IdentityLookupDelegate

- (void) onIdentityLookupCompleted:(HOPIdentityLookup*) lookup
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [[ContactsManager sharedContactsManager] updateContactsWithDataFromLookup:lookup];
    });
}
@end
