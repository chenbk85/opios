
Thank you for downloading Hookflash's Open Peer iOS SDK.

This release is a preliminary 1.0 release of the SDK and Hookflash will be publishing updates to the SDK in time, including various sample applications. For this release, no sample is yet provided.

From your terminal, please clone the "OP" git repository:
git clone git@github.com:openpeer/OP.git

This repository will yield the C++ open peer core, stack, media and libraries needed to support the underlying SDK.

Next, from your terminal, please clone the "OPiOS" git repository:
git clone git@github.com:openpeer/OPiOS.git

This repository contains the iOS SDK objective-C source code wrapper to the C++ SDK. This allows you to build objective-C applications without learning the C++ code.

Directory structure:
OPiOS/                            - contains the project files for building the Open Peer iOS SDK framework
OPiOS/openpeer-ios-sdk/           - contains the Open Peer iOS SDK header files
OPiOS/openpeer-ios-sdk/source/    - contains the implementation of the iOS SDK header files
OPiOS/openpeer-ios-sdk/internal/  - contains the wrapper interface that implements the Objective-C to C++ interaction

How to build:

1) Build curl, from your terminal:

cd OP/hookflash-libs/curl/projects/gnu-make/
./build all

2) Build boost, from your terminal:

cd OP/hookflash-libs/boost/projects/gnu-make/
./build all

3) From X-code, load:

OPiOS/openpeer-ios-sdk (project/workspace)

4) Select OpenpeerSDK > iOS Device schema and then build


The framework will be built inside:
OPiOS/build/Debug-iphoneos/OpenpeerSDK.framework

Required frameworks:
CoreAudio
CoreVideo
CoreMedia
CoreImage
CoreGraphics
AudioToolbox
AVFoundation
AssetsLibrary
MobileCoreServices
libresolve.dylib
libxml2.dylib (only for sample app)


Exploring the dependency libraries:
Core Projects/zsLib      - asynchronous communication library for C++
Core Projects/udns       - C language DNS resolution library
Core Projects/cryptopp   – C++ cryptography language
Core Projects/hfservices - C++ Hookflash Open Peer communication services layer
Core Projects/hfstack    – C++ Hookflash Open Peer stack
Core Projects/hfcore     – C++ Hookflash Open Peer core API (works on the Open Peer stack)
Core Projects/WebRTC     – iPhone port of the webRTC media stack

Exploring the SDK:
openpeer-ios-sdk/         - header files used to build Open Peer iOS applications
openpeer-ios-sdk/Source   - implementation of header files
openpeer-ios-sdk/Internal – internal implementation of iOS to C++ wrapper for SDK
Samples/OpenPeerSampleApp - basic example of how to use the SDK


Exploring the header files:

HOPTypes.h
- basic HOP types

HOPStack.h
- Object to be constructed after HOPClient object, pass in all the listener event protocol objects

HOPProtocols.h
- Object-C protocols to implement callback event routines

HOPAccountSubscription.h
- Object returned when subscribing to Open Peer account status

HOPCall.h
- Call object for audio/video calls created with the contact of a conversation thread

HOPConctact.h
- Contact object representing a local or remote peer contact/person

HOPConversationThread.h
- Conversation object where contacts are added and text and calls can be performed

HOPMediaEngine.h
- controls for media

HOPMedaEngineStatistics.h
- Object used for gathering RTCP media statistics

HOPIdentity.h
- Identity object used in provisioning, used to map user's identity to open peer contact

HOPIdentityInfo.h
- Object representing information about the state of the identity of "self" contact during provisioning

HOPLookupProfileInfo.h
- Object returned after lookup of an identity representing a peer contact for provisioning

HOPProvisioingAccount.h
- Object used to create an account or login to an existing account for provisioned accounts

HOPProvisioningAccountOAuthIdentityAssociation.h
– API for associating an OAuth identity to the provisioned account

HOPAccountPush.h
- Object used for push notifications for offline messages

HOPProvisioningAccountIdentityLookupQuery.h
- Object used to lookup identities of peer contacts to obtain peer contact information

HOPProvisioningAccountPeerFileLookupQuery.h
- Object used to lookup the public peer files to create contact objects for peer contacts

HOPProvisioningAccount_ForFutureUse.h
- Not currently used, this will be the set of APIs that will replace the current provisioning mechanism


Notes on the future API changes:

The provisioning API will change to allow for 3rd party identities with any website and federation between websites. The new provisioning API is put inside the _ForFutureUse.h header file and has no implementation at this time. This API is of high priority.

The current provisioning API supports email, phone number, LinkedIn and Facebook identity association only. The new API will allow any Open Peer oauth login to any Open Peer enabled websites.

Please contact robin@hookflash.com if you have any suggestions to improve the API. Please use support@hookflash.com for any bug reports. New feature requests should be directed to erik@hookflash.com.

Thank you for your interest in the Hookflash Open Peer iOS SDK.


Changes in SDK version B2:

 - Added face detection 
 - Sample app is using ARC now.
 - Sample app examples added: initiating remote session between two selected contacts, checking contacts availability, face detection in session, redial in case of call failure (eg. network failure)


License:

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



