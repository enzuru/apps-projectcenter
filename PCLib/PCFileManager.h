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

#import <Foundation/Foundation.h>

@interface PCFileManager : NSObject
{
    id newFileWindow;
    id fileTypePopup;
    id newFileName;

    id delegate;

    id fileTypeAccessaryView;
    id addFileTypePopup;

    NSMutableDictionary	*creators;

    BOOL _needsAdditionalReleasing;
}

//===========================================================================================
// ==== Init and free
//===========================================================================================

- (id)init;
- (void)dealloc;

- (void)awakeFromNib;

// ===========================================================================
// ==== Delegate
// ===========================================================================

- (id)delegate;
- (void)setDelegate:(id)aDelegate;

// ===========================================================================
// ==== File stuff
// ===========================================================================

- (void)fileTypePopupChanged:(id)sender;
- (void)showAddFileWindow;

- (void)showNewFileWindow;
- (void)buttonsPressed:(id)sender;

- (void)createFile;

- (void)registerCreatorsWithObjectsAndKeys:(NSDictionary *)dict;

@end

@interface  NSObject (FileManagerDelegates)

- (NSString *)fileManager:(id)sender willCreateFile:(NSString *)aFile withKey:(NSString *)key;
    // Returns the correct, full path - or nil!

- (void)fileManager:(id)sender didCreateFile:(NSString *)aFile withKey:(NSString *)key;

- (id)fileManagerWillAddFiles:(id)sender;
    // Is invoked to get the currently active project!

- (BOOL)fileManager:(id)sender shouldAddFile:(NSString *)file forKey:(NSString *)key;
- (void)fileManager:(id)sender didAddFile:(NSString *)file forKey:(NSString *)key;

@end



