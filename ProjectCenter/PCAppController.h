/*
   GNUstep ProjectCenter - http://www.projectcenter.ch

   Copyright (C) 2000 Philippe C.D. Robert

   Author: Philippe C.D. Robert <phr@projectcenter.ch>

   This file is part of ProjectCenter.

   This application is free software; you can redistribute it and/or
   modify it under the terms of the GNU General Public
   License as published by the Free Software Foundation; either
   version 2 of the License, or (at your option) any later version.

   This application is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
   Library General Public License for more details.

   You should have received a copy of the GNU General Public
   License along with this library; if not, write to the Free
   Software Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111 USA.

   $Id$
*/

#import <AppKit/AppKit.h>

#import "PCPrefController.h"
#import "PCFindController.h"
#import "PCInfoController.h"
#import "PCLogController.h"

@class PCBundleLoader;
@class PCServer;
@class PCProjectManager;
@class PCFileManager;
@class PCMenuController;

@interface PCAppController : NSObject
{
    IBOutlet PCPrefController 	*prefController;
    IBOutlet PCFindController 	*finder;
    IBOutlet PCInfoController 	*infoController;
    IBOutlet PCLogController 	*logger;
    IBOutlet PCProjectManager 	*projectManager;
    IBOutlet PCFileManager	*fileManager;
    IBOutlet PCMenuController	*menuController;
    
    PCBundleLoader 		*bundleLoader;
    PCServer 			*doServer;
    NSConnection 		*doConnection;
    
    id				delegate;

    NSMutableDictionary		*projectTypes;
}

//============================================================================
//==== Intialization & deallocation
//============================================================================

+ (void)initialize;

- (id)init;
- (void)dealloc;

//============================================================================
//==== Delegate
//============================================================================

- (id)delegate;
- (void)setDelegate:(id)aDelegate;

//============================================================================
//==== Bundle Management
//============================================================================

- (PCBundleLoader *)bundleLoader;
- (PCProjectManager *)projectManager;
- (PCPrefController *)prefController;
- (PCServer *)doServer;
- (PCFindController *)finder;
- (PCLogController *)logger;

- (NSDictionary *)projectTypes;

//============================================================================
//==== Misc...
//============================================================================

- (void)applicationDidFinishLaunching:(NSNotification *)notification;
- (BOOL)applicationShouldTerminate:(id)sender;
- (void)applicationWillTerminate:(NSNotification *)notification;

//============================================================================
//==== Delegate stuff
//============================================================================

- (BOOL)application:(NSApplication *)theApplication openFile:(NSString *)filename;

- (void)bundleLoader:(id)sender didLoadBundle:(NSBundle *)aBundle;

@end

@interface PCAppController (ProjectRegistration)

- (BOOL)registerProjectCreator:(NSString *)className forKey:(NSString *)aKey;
// Returns YES upon successfully registering a new projecttype.

@end