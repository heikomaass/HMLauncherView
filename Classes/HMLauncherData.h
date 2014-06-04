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

#import <Foundation/Foundation.h>
#import "HMLauncherIcon.h"


// HMLauncherData contains a list of pages. Each page is represented by a NSMutableArray.
@interface HMLauncherData : NSObject

@property (nonatomic, assign) NSInteger maxRows;
@property (nonatomic, assign) NSInteger maxColumns;
@property (nonatomic, strong) NSString *persistKey;
@property (nonatomic, strong) NSMutableArray *launcherIconPages;


- (void)  addIcon:(HMLauncherIcon*) icon;

- (void)      addIcon:(HMLauncherIcon*) icon
            pageIndex:(NSUInteger) pageIndex
            iconIndex:(NSUInteger) iconIndex;

- (void)     moveIcon: (HMLauncherIcon*) icon 
               toPage: (NSUInteger) pageIndex
              toIndex: (NSUInteger) iconIndex;

- (void) removeIcon:(HMLauncherIcon*) icon;

- (NSMutableArray*) addPage;

- (void) removeEmptyPages;

- (NSArray*) findIconsByIdentifier:(NSString*) identifier;

- (NSMutableArray*) pageOfIcon:(HMLauncherIcon*) icon;

- (NSUInteger) iconCount;

- (NSUInteger) pageCount;

@end
