//
// Copyright 2012 Heiko Maaß (mail@heikomaass.de)
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

// only adds the icon to the view, not to the datasource
- (void) addIcon:(HMLauncherIcon*) icon;

// only removes the icon from the view, not from the datasource
- (void) removeIcon:(HMLauncherIcon*) icon;
- (void) removeIconAnimated:(HMLauncherIcon*) icon completion:(void (^) (void)) block;
- (void) layoutIconsAnimated;
- (void) layoutIcons;

@property (nonatomic, assign) BOOL shouldLayoutDragButton;
@property (nonatomic, readonly) BOOL editing;
@property (nonatomic, retain) NSIndexPath *targetPath;
@property (nonatomic, assign) NSObject<HMLauncherDataSource> *dataSource;
@property (nonatomic, assign) NSObject<HMLauncherViewDelegate> *delegate;
@property (nonatomic, retain) NSString *persistKey;
@end