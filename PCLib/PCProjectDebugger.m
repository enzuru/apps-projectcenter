/*
   GNUstep ProjectCenter - http://www.gnustep.org

   Copyright (C) 2000-2002 Free Software Foundation

   Author: Philippe C.D. Robert <probert@siggraph.org>

   This file is part of GNUstep.

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

#include "PCProjectDebugger.h"
#include "PCDefines.h"
#include "PCProject.h"
#include "PCProjectManager.h"

#include <AppKit/AppKit.h>

#ifndef IMAGE
#define IMAGE(X) [[[NSImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForImageResource:(X)]] autorelease]
#endif

#ifndef NOTIFICATION_CENTER
#define NOTIFICATION_CENTER [NSNotificationCenter defaultCenter]
#endif

enum {
    DEBUG_DEFAULT_TARGET = 1,
    DEBUG_DEBUG_TARGET   = 2
};

@interface PCProjectDebugger (CreateUI)

- (void)_createLaunchPanel;
- (void)_createComponentView;

@end

@implementation PCProjectDebugger (CreateUI)

- (void) _createLaunchPanel
{
  launchPanel = [[NSPanel alloc]
    initWithContentRect: NSMakeRect (0, 300, 480, 322)
    styleMask: (NSTitledWindowMask 
		| NSClosableWindowMask
		| NSResizableWindowMask)
    backing: NSBackingStoreRetained
    defer: YES];
  [launchPanel setMinSize: NSMakeSize(400, 160)];
  [launchPanel setFrameAutosaveName: @"ProjectLauncher"];
  [launchPanel setReleasedWhenClosed: NO];
  [launchPanel setHidesOnDeactivate: NO];
  [launchPanel setTitle: [NSString 
    stringWithFormat: @"%@ - Launch", [currentProject projectName]]];

  if (![launchPanel setFrameUsingName: @"ProjectLauncher"])
    {
      [launchPanel center];
    }
}

- (void)_createComponentView
{
  NSSplitView  *split;
  NSScrollView *scrollView1; 
  NSScrollView *scrollView2; 
  NSMatrix     *matrix;
  NSRect       _w_frame;
  NSButtonCell *buttonCell = [[[NSButtonCell alloc] init] autorelease];
  id           button;
  NSBox        *box;

  componentView = [[NSBox alloc] initWithFrame:NSMakeRect(8,-1,464,322)];
  [componentView setTitlePosition:NSNoTitle];
  [componentView setBorderType:NSNoBorder];
  [componentView setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
  [componentView setContentViewMargins: NSMakeSize(0.0,0.0)];

  /*
   * Top buttons
   */
  _w_frame = NSMakeRect(0, 270, 88, 44);
  matrix = [[NSMatrix alloc] initWithFrame: _w_frame
			              mode: NSHighlightModeMatrix
			         prototype: buttonCell
			      numberOfRows: 1
			   numberOfColumns: 2];
  [matrix sizeToCells];
  [matrix setSelectionByRect: YES];
  [matrix setAutoresizingMask: (NSViewMaxXMargin | NSViewMinYMargin)];
  [matrix setTarget: self];
  [componentView addSubview: matrix];

  RELEASE(matrix);

  runButton = [matrix cellAtRow:0 column:0];
  [runButton setTag: 0];
  [runButton setImagePosition: NSImageOnly];
  [runButton setImage: IMAGE(@"ProjectCenter_run")];
  [runButton setAlternateImage: IMAGE(@"ProjectCenter_run")];
  [runButton setButtonType: NSMomentaryPushButton];
  [runButton setTitle: @"Run"];
  [runButton setAction: @selector(run:)];

  button = [matrix cellAtRow:0 column:1];
  [button setTag: 1];
  [button setImagePosition: NSImageOnly];
  [button setImage: IMAGE(@"ProjectCenter_debug")];
  [button setAlternateImage: IMAGE(@"ProjectCenter_debug")];
  [button setButtonType: NSMomentaryPushButton];
  [button setTitle: @"Debug"];
  [button setAction: @selector(debug:)];

  /*
   *
   */

/*  scrollView1 = [[NSScrollView alloc] initWithFrame:NSMakeRect (-1,0,562,46)];

  [scrollView1 setHasHorizontalScroller: NO];
  [scrollView1 setHasVerticalScroller: YES];
  [scrollView1 setBorderType: NSBezelBorder];
  [scrollView1 setAutoresizingMask:(NSViewWidthSizable | NSViewHeightSizable)];

  stdOut = [[NSTextView alloc] initWithFrame:[[scrollView1 contentView]frame]];

  [stdOut setRichText:NO];
  [stdOut setEditable:NO];
  [stdOut setSelectable:YES];
  [stdOut setAutoresizingMask: NSViewWidthSizable | NSViewHeightSizable];
  [stdOut setBackgroundColor:[NSColor colorWithDeviceRed:0.95
				      green:0.75
				      blue:0.85
				      alpha:1.0]];
  [[stdOut textContainer] setWidthTracksTextView:YES];

  [scrollView1 setDocumentView:stdOut];*/

  /*
   *
   */

  scrollView2 = [[NSScrollView alloc] initWithFrame:NSMakeRect (0,-1,464,253)];

  [scrollView2 setHasHorizontalScroller:NO];
  [scrollView2 setHasVerticalScroller:YES];
  [scrollView2 setBorderType: NSBezelBorder];
  [scrollView2 setAutoresizingMask:(NSViewWidthSizable | NSViewHeightSizable)];

  stdError=[[NSTextView alloc] initWithFrame:[[scrollView2 contentView]frame]];

  [stdError setRichText:NO];
  [stdError setEditable:NO];
  [stdError setSelectable:YES];
  [stdError setAutoresizingMask: NSViewWidthSizable | NSViewHeightSizable];
  [stdError setBackgroundColor:[NSColor whiteColor]];
  [[stdError textContainer] setWidthTracksTextView:YES];

  [scrollView2 setDocumentView:stdError];

/*  split = [[NSSplitView alloc] initWithFrame:NSMakeRect(-1,-1,562,152)];  
  [split setAutoresizingMask: (NSViewWidthSizable | NSViewHeightSizable)];
  [split addSubview: scrollView1];
  [split addSubview: scrollView2];
  
  [componentView addSubview:split];*/
  [componentView addSubview: scrollView2];

//  RELEASE(scrollView1);
  RELEASE(scrollView2);
//  RELEASE(split);

//  [componentView sizeToFit];
//  [split adjustSubviews];
}

@end

@implementation PCProjectDebugger

- (id)initWithProject:(PCProject *)aProject
{
  NSAssert(aProject,@"No project specified!");

  if ((self = [super init])) 
  {
    currentProject = aProject;
    debugTarget = DEBUG_DEFAULT_TARGET;

  }
  return self;
}

- (void)dealloc
{
  RELEASE(componentView);

  RELEASE(stdOut);
  RELEASE(stdError);

  if (readHandle) RELEASE(readHandle); 
  if (errorReadHandle) RELEASE(errorReadHandle);

  [super dealloc];
}

- (NSPanel *) createLaunchPanel
{
  if (!launchPanel)
    {
      [self _createLaunchPanel];
    }

  return launchPanel;
}

- (NSPanel *) launchPanel
{
  return launchPanel;
}

- (NSView *)componentView;
{
  if (!componentView) {
    [self _createComponentView];
  }

  return componentView;
}

- (void)popupChanged:(id)sender
{
  switch ([sender indexOfSelectedItem])
  {
      case 0:
          debugTarget = DEBUG_DEFAULT_TARGET;
          break;
      case 1:
          debugTarget = DEBUG_DEBUG_TARGET;
          break;
      default:
          break;
  }
}

- (void)debug:(id)sender
{
  NSRunAlertPanel(@"Attention!",@"Integrated debugging is not yet available...",@"OK",nil,nil);
}

- (void)run:(id)sender
{
  NSMutableArray *args;
  NSPipe *logPipe;
  NSPipe *errorPipe;
  NSString *openPath;

  logPipe = [NSPipe pipe];
  RELEASE(readHandle);
  readHandle = [[logPipe fileHandleForReading] retain];

  errorPipe = [NSPipe pipe];
  RELEASE(errorReadHandle);
  errorReadHandle = [[errorPipe fileHandleForReading] retain];

  RELEASE(task);
  task = [[NSTask alloc] init];

  args = [[NSMutableArray alloc] init];

  /*
   * Ugly hack! We should ask the porject itself about the req. information!
   *
   */

  if ([currentProject isKindOfClass:NSClassFromString(@"PCAppProject")] ||
      [currentProject isKindOfClass:NSClassFromString(@"PCRenaissanceProject")] ||
      [currentProject isKindOfClass:NSClassFromString(@"PCGormProject")]) 
  {
    NSString *tn;
    NSString *pn = [currentProject projectName];

    openPath = [NSString stringWithString:@"openapp"];

    switch( debugTarget )
    {
        case DEBUG_DEFAULT_TARGET:
	    tn = [pn stringByAppendingPathExtension:@"app"];
            break;
        case DEBUG_DEBUG_TARGET:
	    tn = [pn stringByAppendingPathExtension:@"debug"];
            break;
        default:
	    [NSException raise:@"PCInternalDevException" 
                        format:@"Unknown build target!"];
            break;
    }
    [args addObject:tn];
  }
  else if ([currentProject isKindOfClass:NSClassFromString(@"PCToolProject")]) 
  {
    openPath = [NSString stringWithString:@"opentool"];
    [args addObject:[currentProject projectName]];
  }
  else 
  {
    [NSException raise:@"PCInternalDevException" 
                format:@"Unknown executable project type!"];
    return;
  }

  /*
   * Setting everything up
   */

  [NOTIFICATION_CENTER addObserver:self 
		       selector:@selector(logStdOut:) 
		       name:NSFileHandleDataAvailableNotification
		       object:readHandle];
  
  [NOTIFICATION_CENTER addObserver:self 
		       selector:@selector(logErrOut:) 
		       name:NSFileHandleDataAvailableNotification
		       object:errorReadHandle];

  [NOTIFICATION_CENTER addObserver:self
		       selector: @selector(buildDidTerminate:)
		       name: NSTaskDidTerminateNotification
		       object:task];  
  
  [task setArguments:args];  
  RELEASE(args);

  [task setCurrentDirectoryPath:[currentProject projectPath]];
  [task setLaunchPath:openPath];
  
  [task setStandardOutput:logPipe];
  [task setStandardError:errorPipe];

  [stdOut setString:@""];
  [readHandle waitForDataInBackgroundAndNotify];

  [stdError setString:@""];
  [errorReadHandle waitForDataInBackgroundAndNotify];

  /*
   * Go! Later on this will be handled much more optimised!
   *
   */

  [task launch];
}

- (void)buildDidTerminate:(NSNotification *)aNotif
{
  if ([aNotif object] == task) {

    /*
     * Clean up...
     *
     */
    
    [NOTIFICATION_CENTER removeObserver:self 
			 name:NSFileHandleDataAvailableNotification
			 object:readHandle];
    
    [NOTIFICATION_CENTER removeObserver:self 
			 name:NSFileHandleDataAvailableNotification
			 object:errorReadHandle];

    [NOTIFICATION_CENTER removeObserver:self 
			 name:NSTaskDidTerminateNotification 
			 object:task];

    RELEASE(task);
    task = nil;

    [runButton setNextState];
    [componentView display];
  }
}

- (void)logStdOut:(NSNotification *)aNotif
{
  NSData *data;

  if ((data = [readHandle availableData])) {
    [self logData:data error:NO];
  }

  [readHandle waitForDataInBackgroundAndNotifyForModes:nil];
}

- (void)logErrOut:(NSNotification *)aNotif
{
  NSData *data;

  if ((data = [errorReadHandle availableData])) {
    [self logData:data error:YES];
  }

  [errorReadHandle waitForDataInBackgroundAndNotifyForModes:nil];
}

@end

@implementation PCProjectDebugger (BuildLogging)

- (void)logString:(NSString *)string error:(BOOL)yn
{
  [self logString:string error:yn newLine:YES];
}

- (void)logString:(NSString *)str error:(BOOL)yn newLine:(BOOL)newLine
{
  NSTextView *out = (yn)?stdError:stdOut;

  [out replaceCharactersInRange:NSMakeRange([[out string] length],0) 
       withString:str];

  if (newLine) {
    [out replaceCharactersInRange:NSMakeRange([[out string] length], 0) 
	 withString:@"\n"];
  }
  else {
    [out replaceCharactersInRange:NSMakeRange([[out string] length], 0) 
	 withString:@" "];
  }
  
  [out scrollRangeToVisible:NSMakeRange([[out string] length], 0)];
}

- (void)logData:(NSData *)data error:(BOOL)yn
{
  NSString *s = [[NSString alloc] initWithData:data 
				  encoding:[NSString defaultCStringEncoding]];

  [self logString:s error:yn newLine:YES];
  [s autorelease];
}

@end
