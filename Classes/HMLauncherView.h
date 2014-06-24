//
// Copyright 2014 Heiko Maaß (mail@heikomaass.de)
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

#import <UIKit/UIKit.h>
#import "HMLauncherView.h"
#import "HMLauncherDataSource.h"
#import "HMLauncherViewDelegate.h"

@interface HMLauncherView : UIView <UIScrollViewDelegate, UIAlertViewDelegate>

- (void) reloadData;
- (void) startEditing;
- (void) stopEditing;

/**
 Jumps to the given (0-based) page
 @param currentPage the (0-based) index of the page which should be displayed.
 @param animated if the transition should be animated
 **/
- (void) setCurrentPage:(NSUInteger) currentPage animated:(BOOL) animated;

/** 
 Returns the current displayed page (0-based)
 **/
- (NSUInteger) currentPage;

/**
 Adds the icon to the view. Please note that the icon has to be added to the datasource before.
 **/
- (void) addIcon:(HMLauncherIcon*) icon;

/** 
 Removes the icon from the view. Please note that the icon will not be removed from the datasource.
 **/
- (void) removeIcon:(HMLauncherIcon*) icon;

- (void) removeIconAnimated:(HMLauncherIcon*) icon completion:(void (^) (void)) block;


@property (nonatomic, assign) BOOL shouldLayoutDragButton;
@property (nonatomic, readonly) BOOL editing;
@property (nonatomic, strong) NSIndexPath *targetPath;
@property (nonatomic, weak) NSObject<HMLauncherDataSource> *dataSource;
@property (nonatomic, weak) NSObject<HMLauncherViewDelegate> *delegate;
@property (nonatomic, strong) NSString *persistKey;
@property (nonatomic, weak) UIView *keyView;

@end