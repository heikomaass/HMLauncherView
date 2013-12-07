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

#import "HMLauncherIcon.h"
#import "HMLauncherItem.h"

#import <UIKit/UIKit.h>

#import <XCTest/XCTest.h>
#import "HMLauncherData.h"

@interface HMLauncherDataTest : XCTestCase {
    
}
@end

@interface HMLauncherDataTest()
@property (nonatomic, strong) HMLauncherData *cut;
@end

@implementation HMLauncherDataTest

- (void)setUp {
    _cut = [[HMLauncherData alloc] init];
    [_cut setMaxRows:2];
    [_cut setMaxColumns:2];
    XCTAssertNotNil(_cut, @"HMLauncherData could not be created");
}

- (void) testAddIcon_should_increaseIconCount_byOne {
    [self addDummyIcons:1];
    XCTAssertEqual((NSUInteger) 1, [_cut iconCount], @"expected 1 icon, but is: %d", [_cut iconCount]);
}

- (void) testAddIcon_should_increasePageCount_byOne {
    [self addDummyIcons:1];
    XCTAssertEqual((NSUInteger) 1, [_cut pageCount], @"expected 1 page, but is: %d", [_cut pageCount]);
}

- (void) testAddIcon_should_increaseIconCount_byFive {
    [self addDummyIcons:5];
    XCTAssertEqual((NSUInteger) 5, [_cut iconCount], @"expected 5 icon, but is: %d", [_cut iconCount]);
}

- (void) testAddIcon_should_increasePageCounty_byTwo {
    [self addDummyIcons:5];
    XCTAssertEqual((NSUInteger) 2, [_cut pageCount], @"expected 2 page, but is: %d", [_cut pageCount]);
}

- (void) testRemoveIcon_should_decreaseIconCount_byOne {
    NSArray *addedIcons = [self addDummyIcons:2];
    
    [_cut removeIcon:addedIcons[0]];
    XCTAssertEqual((NSUInteger) 1, [_cut iconCount], @"expected 1 icon, but is: %d", [_cut iconCount]);
    NSArray *pageOfFirstIcon = [_cut pageOfIcon:addedIcons[0]];
    NSArray *pageOfSecondIcon = [_cut pageOfIcon:addedIcons[1]];
    XCTAssertNil(pageOfFirstIcon, @"expected nil page, because firstIcon is no longer part of the HMLauncherData");
    XCTAssertNotNil(pageOfSecondIcon, @"expected non nil page, because secondIcon is still part of the HMLauncherData");
}

- (void) testRemoveIcon_should_decreasePageCount_byOne_when_pageIsEmpty_1 {
    NSArray *addedIcons = [self addDummyIcons:5];
    [_cut removeIcon:addedIcons[4]];
    
    XCTAssertEqual((NSUInteger) 1, [_cut pageCount], @"expected 1 page, but is: %d", [_cut pageCount]);
}

- (void) testRemoveIcon_should_decreasePageCount_byOne_when_pageIsEmpty_2 {
    NSArray *addedIcons = [self addDummyIcons:6];
    [_cut removeIcon:addedIcons[0]];
    [_cut removeIcon:addedIcons[1]];
    [_cut removeIcon:addedIcons[2]];
    [_cut removeIcon:addedIcons[3]];
    
    XCTAssertEqual((NSUInteger) 1, [_cut pageCount], @"expected 1 page, but is: %d", [_cut pageCount]);
}


- (void) testRemoveIcon_should_notChangePageCount_when_pageIsNotEmpty {
    NSArray *addedIcons = [self addDummyIcons:6];
    [_cut removeIcon:addedIcons[4]];
    
    XCTAssertEqual((NSUInteger) 2, [_cut pageCount], @"expected 2 pages, but is: %d", [_cut pageCount]);
}


- (HMLauncherIcon*) createDummyIcon {
    HMLauncherItem *item = [[HMLauncherItem alloc] init] ;
    [item setIconPath:@"dummy.png"] ;
    HMLauncherIcon *icon = [[HMLauncherIcon alloc] initWithLauncherItem:item];
    return icon;
}

- (NSArray*) addDummyIcons:(NSInteger) amount {
    NSMutableArray *addedIcons = [NSMutableArray array];
    for (int i = 0; i< amount; i++) {
        HMLauncherIcon *icon = [self createDummyIcon];
        [addedIcons addObject:icon];
        [_cut addIcon:icon];
    }
    return addedIcons;
}



@end
