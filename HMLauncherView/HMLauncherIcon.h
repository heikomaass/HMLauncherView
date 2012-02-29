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
@class HMLauncherView;
@class HMLauncherItem;

// Baseclass for an Icon. You've to extend from this class.
// See LauncherExampleIcon.h for an example.
@interface HMLauncherIcon : UIControl {
}
@property (nonatomic, assign) BOOL canBeDeleted;
@property (nonatomic, assign) BOOL canBeDragged;
@property (nonatomic, assign) BOOL canBeTapped;
@property (nonatomic, assign) BOOL hideDeleteImage;
@property (nonatomic, retain) NSString *identifier;
@property (nonatomic, retain) NSIndexPath *originIndexPath;
@property (nonatomic, retain) HMLauncherItem *launcherItem;

- (BOOL) hitCloseButton:(CGPoint) point;
- (id) initWithLauncherItem: (HMLauncherItem*) launcherItem;

@end
