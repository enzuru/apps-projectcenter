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

#import "PCFileManager.h"
#import "ProjectCenter.h"

#if defined(GNUSTEP)
#import <AppKit/IMLoading.h>
#endif

@interface PCFileManager (CreateUI)

- (void)_initUI;

@end

@implementation PCFileManager (CreateUI)

- (void)_initUI
{
  NSView *_c_view;
  unsigned int style = NSTitledWindowMask | NSClosableWindowMask | 
                       NSMiniaturizableWindowMask | NSResizableWindowMask;
  NSBox *box;
  NSRect _w_frame;
  NSMatrix* matrix;
  id button;
  NSButtonCell* buttonCell = [[[NSButtonCell alloc] init] autorelease];
  id textField;

  /*
   * the file creation window
   *
   */

  _w_frame = NSMakeRect(100,100,264,160);
  newFileWindow = [[NSWindow alloc] initWithContentRect:_w_frame
				    styleMask:style
				    backing:NSBackingStoreBuffered
				    defer:NO];
  [newFileWindow setMinSize:NSMakeSize(264,160)];
  [newFileWindow setTitle:@"New File..."];

  box = [[[NSBox alloc] init] autorelease];
  [box setFrame:NSMakeRect(16,96,224,56)];
  fileTypePopup = [[[NSPopUpButton alloc] initWithFrame:NSMakeRect(32,2,160,20)
					  pullsDown:NO] autorelease];
  [fileTypePopup addItemWithTitle:@"No type available!"];
  [fileTypePopup setAutoresizingMask: (NSViewWidthSizable)];
  [box setTitle:@"Type"];
  [box setTitlePosition:NSAtTop];
  [box setBorderType:NSGrooveBorder];
  [box addSubview:fileTypePopup];
  [box setAutoresizingMask: (NSViewWidthSizable | NSViewMinYMargin)];

  _c_view = [newFileWindow contentView];
  [_c_view addSubview:box];

  /*
   * Button matrix
   */

  _w_frame = NSMakeRect(136,8,116,24);
  matrix = [[[NSMatrix alloc] initWithFrame: _w_frame
                                       mode: NSHighlightModeMatrix
                                  prototype: buttonCell
                               numberOfRows: 1
                            numberOfColumns: 2] autorelease];
  [matrix setSelectionByRect:YES];
  [matrix setAutoresizingMask: (NSViewMinXMargin | NSViewMaxYMargin)];
  [matrix setTarget:self];
  [matrix setAction:@selector(buttonsPressed:)];
  [matrix setIntercellSpacing: NSMakeSize(2,2)];
  [_c_view addSubview:matrix];

  button = [matrix cellAtRow:0 column:0];
  [button setTag:0];
  [button setStringValue:@"Cancel"];
  [button setBordered:YES];
  [button setButtonType:NSMomentaryPushButton];

  button = [matrix cellAtRow:0 column:1];
  [button setTag:1];
  [button setStringValue:@"OK"];
  [button setBordered:YES];
  [button setButtonType:NSMomentaryPushButton];

  /*
   * The name of the new file...
   */

  // Status message
  textField = [[NSTextField alloc] initWithFrame:NSMakeRect(16,56,48,21)];
  [textField setAlignment: NSLeftTextAlignment];
  [textField setBordered: NO];
  [textField setEditable: NO];
  [textField setBezeled: NO];
  [textField setDrawsBackground: NO];
  [textField setStringValue:@"Name:"];
  [textField setAutoresizingMask: (NSViewMaxXMargin | 
				   NSViewWidthSizable | 
				   NSViewMinYMargin)];
  [_c_view addSubview:[textField autorelease]];

  // Target
  newFileName = [[NSTextField alloc] initWithFrame:NSMakeRect(64,56,176,21)];
  [newFileName setAlignment: NSLeftTextAlignment];
  [newFileName setBordered: YES];
  [newFileName setBezeled: YES];
  [newFileName setEditable: YES];
  [newFileName setDrawsBackground: YES];
  [newFileName setStringValue:@""];
  [newFileName setAutoresizingMask: (NSViewWidthSizable | NSViewMinYMargin)];
  [_c_view addSubview:[newFileName autorelease]];

  /*
   * the accessory view needed for adding files
   *
   */

  fileTypeAccessaryView = [[NSBox alloc] init];
  addFileTypePopup = [[[NSPopUpButton alloc] initWithFrame:NSMakeRect(20,30,160,20) pullsDown:NO] autorelease];
  [addFileTypePopup addItemWithTitle:@"No type available!"];
  
  [fileTypeAccessaryView setTitle:@"Add to category"];
  [fileTypeAccessaryView setTitlePosition:NSAtTop];
  [fileTypeAccessaryView setBorderType:NSGrooveBorder];
  [fileTypeAccessaryView addSubview:addFileTypePopup];
  [fileTypeAccessaryView sizeToFit];
  [fileTypeAccessaryView setAutoresizingMask: NSViewWidthSizable];
  
  [fileTypePopup setTarget:self];
  [fileTypePopup setAction:@selector(fileTypePopupChanged:)];

  _needsAdditionalReleasing = YES;
}

@end

@implementation PCFileManager

//===========================================================================================
// ==== Init and free
//===========================================================================================

- (id)init
{
    if ((self = [super init])) {
       	creators = [[NSMutableDictionary alloc] init];

#if defined(GNUSTEP)
	[self _initUI];
#else
        if(![NSBundle loadNibNamed:@"FileCreation.nib" owner:self]) {
	  [[NSException exceptionWithName:NIB_NOT_FOUND_EXCEPTION reason:@"Could not load FileCreation.gmodel" userInfo:nil] raise];
	  return nil;
        }
#endif
    }
    return self;
}

- (void)dealloc
{
  [creators release];
  
  if (_needsAdditionalReleasing) {
    [fileTypeAccessaryView release];
    [newFileWindow release];
  }
  
  [super dealloc];
}

- (void)awakeFromNib
{
    [fileTypePopup removeAllItems];
}

// ===========================================================================
// ==== Delegate
// ===========================================================================

- (id)delegate
{
    return delegate;
}

- (void)setDelegate:(id)aDelegate
{
    delegate = aDelegate;
}

// ===========================================================================
// ==== File stuff
// ===========================================================================

- (void)fileTypePopupChanged:(id)sender
{
}

- (void)showAddFileWindow
{
  NSOpenPanel	*openPanel;
  int	retval;
  NSMutableArray *validTypes = nil;
  NSDictionary *categories = nil;
  PCProject *project = nil;
  
  if (delegate && [delegate respondsToSelector:@selector(fileManagerWillAddFiles:)]) {
    if (!(project = [delegate fileManagerWillAddFiles:self])) {
      NSLog(@"No project to add files available...");
    }
  }
  
  // Ask the active project for the valid file types first!
  categories = [project rootCategories];
  validTypes = [NSMutableArray arrayWithArray:[categories allKeys]];
  [validTypes removeObject:@"Subprojects"];
  
  [addFileTypePopup removeAllItems];
  [addFileTypePopup addItemsWithTitles:validTypes];
  
  openPanel = [NSOpenPanel openPanel];
  [openPanel setAllowsMultipleSelection:YES];
  [openPanel setCanChooseDirectories:NO];
  [openPanel setCanChooseFiles:YES];
  
  [openPanel setTitle:@"Add File(s)..."];
  [openPanel setAccessoryView:fileTypeAccessaryView];
  
  retval = [openPanel runModalForDirectory:[[NSUserDefaults standardUserDefaults] objectForKey:@"LastOpenDirectory"] file:nil types:nil];
  
  if (retval == NSOKButton) {
    NSString *key = [categories objectForKey:[addFileTypePopup titleOfSelectedItem]];
    NSEnumerator *enumerator;
    NSString *file;
    
    [[NSUserDefaults standardUserDefaults] setObject:[openPanel directory] forKey:@"LastOpenDirectory"];
    
    enumerator = [[openPanel filenames] objectEnumerator];
    while (file = [enumerator nextObject]) {
      if ([delegate fileManager:self shouldAddFile:file forKey:key]) {
	NSString *fileName = [file lastPathComponent];
	NSString *pth = [[project projectPath] stringByAppendingPathComponent:fileName];
	
	if (![key isEqualToString:PCLibraries]) {
	  if ([[NSFileManager defaultManager] copyPath:file toPath:pth handler:nil]) {
	    [delegate fileManager:self didAddFile:pth forKey:key];
	  }
	}
	else {
	  [delegate fileManager:self didAddFile:pth forKey:key];
	}
      }
    }
  }
}

- (void)showNewFileWindow
{
  [newFileWindow center];
  [newFileWindow makeKeyAndOrderFront:self];
}

- (void)buttonsPressed:(id)sender
{
  switch ([[sender selectedCell] tag]) {
  case 0:
    break;
  case 1:
    [self createFile];
    break;
  }
  [newFileWindow orderOut:self];
  [newFileName setStringValue:@""];
}

- (void)createFile
{
  NSString *path = nil;
  NSString *fileName = [newFileName stringValue];
  NSString *fileType = [fileTypePopup titleOfSelectedItem];
  NSString *key = [[creators objectForKey:fileType] objectForKey:@"ProjectKey"];
  
  if (delegate) {
    path = [delegate fileManager:self willCreateFile:fileName withKey:key];
  }
  
  NSLog(@"<%@ %x>: creating file at %@",[self class],self,path);
  
  // Create file
  if (path) {
    NSDictionary *newFiles;
    id<FileCreator> creator = [[creators objectForKey:fileType] objectForKey:@"Creator"];
    PCProject *p = [delegate activeProject];

    if (!creator) {
      NSRunAlertPanel(@"Attention!",@"Could not create %@. The appropriate creator is missing!",@"OK",nil,nil,fileName);
      return;
    }
    
    // Do it finally...
    newFiles = [creator createFileOfType:fileType path:path project:p];
    if (delegate && [delegate respondsToSelector:@selector(fileManager:didCreateFile:withKey:)]) {
      NSEnumerator *enumerator;
      NSString *aFile;
      
      enumerator = [[newFiles allKeys] objectEnumerator]; // Key: name of the file
      while (aFile = [enumerator nextObject]) {
	NSString *theType = [newFiles objectForKey:aFile];
	NSString *theKey = [[creators objectForKey:theType] objectForKey:@"ProjectKey"];
	
	[delegate fileManager:self didCreateFile:aFile withKey:theKey];
      }
    }
  }
}

- (void)registerCreatorsWithObjectsAndKeys:(NSDictionary *)dict
{
  NSEnumerator *enumerator = [dict keyEnumerator];
  id type;
  
  NSLog(@"<%@ %x>: Registering creators...",[self class],self);
  
  while (type = [enumerator nextObject]) {
    id creator = [[dict objectForKey:type] objectForKey:@"Creator"];
    
    if (![creator conformsToProtocol:@protocol(FileCreator)]) {
      [NSException raise:@"FileManagerGenericException" format:@"The target does not conform to the FileCreator protocol!"];
      return;
    }
    
    if ([creators objectForKey:type]) {
      [NSException raise:@"FileManagerGenericException" format:@"There is alreay a creator registered for this type!"];
      return;
    }
    
    // Register the creator!
    [creators setObject:[dict objectForKey:type] forKey:type];
    [fileTypePopup addItemWithTitle:type];
  }
}

@end
