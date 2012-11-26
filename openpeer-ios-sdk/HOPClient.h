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

#import <Foundation/Foundation.h>

#import "HOPTypes.h"

@class HOPClientLogDelegate;

@interface HOPClient : NSObject
/**
 This routine must be called only ONCE from the GUI thread. This method will through an invalid usage exception if the HOPClient::setup routine was already called.
 */
+ (void) setup;

/**
 Obtain a pointer to the previously setup HOPClient. This routine will throw an invalid usage exception if the HOPClient::setup method was not previously called.
 @returns Shared instance to the self object.
 */
+ (id) sharedInstance;

/**
 This method is to notify the hookflash client that a messaage put GUI queue is now being processed by the GUI queue.
 */
- (void) processMessagePutInGUIQueue;

/**
 This method will block until the hookflash API is fully shutdown.
 */
- (void) finalizeShutdown;

/**
 Install a logger to output to the standard out.
 @param colorizeOutput BOOL Flag to enable/disable output colorization
 */
+ (void) installStdOutLogger: (BOOL) colorizeOutput;

/**
 Install a logger to output to a file.
 @param filename NSString Name of the log file
 @param colorizeOutput BOOL Flag to enable/disable output colorization
 */
+ (void) installFileLogger: (NSString*) filename colorizeOutput: (BOOL) colorizeOutput;

/**
 Install a logger to output to a telnet prompt.
 @param listenPort unsigned short Port for listening
 @param maxSecondsWaitForSocketToBeAvailable unsigned long Specify how long will logger wait for socket
 @param colorizeOutput BOOL Flag to enable/disable output colorization
 */
+ (void) installTelnetLogger: (unsigned short) listenPort maxSecondsWaitForSocketToBeAvailable:(unsigned long) maxSecondsWaitForSocketToBeAvailable colorizeOutput: (BOOL) colorizeOutput;

/**
 Install a logger that sends a telnet outgoing to a telnet server.
 @param serverToConnect NSString Call Server address
 @param colorizeOutput BOOL Flag to enable/disable output colorization
 @param stringToSendUponConnection NSString String to send to the server when connection is established
 */
+ (void) installOutgoingTelnetLogger: (NSString*) serverToConnect colorizeOutput: (BOOL) colorizeOutput stringToSendUponConnection: (NSString*) stringToSendUponConnection;

/**
 Install a logger to output to the windows debugger window.
 */
+ (void) installWindowsDebuggerLogger;

/**
 Install a logger to monitor the functioning of the application internally.
 */
+ (void) installCustomLogger: (HOPClientLogDelegate*) delegate;

/**
 Gets the unique ID for the GUI's subsystem (to pass into the log routine for GUI logging)
 @return Return subsystem unique ID
 */
+ (unsigned int) getGUISubsystemUniqueID;

/**
 Gets the currently set log level for a particular subsystem.
 @param subsystemUniqueID unsigned int Unique ID of the log subsystem
 @returns Log level enum
 */
+ (HOPClientLogLevels) getLogLevel: (unsigned int) subsystemUniqueID;

/**
 Sets all subsystems to a specific log level.
 @param level HOPClientLogLevels Level to set
 */
+ (void) setLogLevel: (HOPClientLogLevels) level;

/**
 Sets a particular subsystem's log level by unique ID.
 @param subsystemUniqueID unsigned long Unique ID of the log subsystem
 @param level HOPClientLogLevels Level to set
 */
+ (void) setLogLevelByID: (unsigned long) subsystemUniqueID level: (HOPClientLogLevels) level;

/**
 Sets a particular subsystem's log level by its subsystem name.
 @param subsystemName NSString Name of the log subsystem
 @param level HOPClientLogLevels Level to set
 */
+ (void) setLogLevelbyName: (NSString*) subsystemName level: (HOPClientLogLevels) level;

/**
 Sends a message to the logger(s) for a particular subsystem.
 @param subsystemUniqueID unsigned long Unique ID of the log subsystem
 @param severity HOPClientLogSeverities Log severity
 @param level HOPClientLogLevels Log level
 @param message NSString Message to log
 @param function NSString Log function
 @param filePath NSString Path to log file
 @param lineNumber unsigned long Number of the log line
 @returns String representation of call closed reason enum
 */
+ (void) log: (unsigned int) subsystemUniqueID severity: (HOPClientLogSeverities) severity level: (HOPClientLogLevels) level message: (NSString*) message function: (NSString*) function filePath: (NSString*) filePath lineNumber: (unsigned long) lineNumber;

@end