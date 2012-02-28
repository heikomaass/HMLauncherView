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

#import "HMLauncherDataTest.h"
#import "HMLauncherIcon.h"
#import "HMLauncherItem.h"

#import <UIKit/UIKit.h>

@interface HMLauncherDataTest(private)
-(HMLauncherIcon*) createDummyIcon;
@end

@implementation HMLauncherDataTest

- (void)setUp {
    cut = [[HMLauncherData alloc] init];
    [cut setMaxRows:2];
    [cut setMaxColumns:2];
    STAssertNotNil(cut, @"HMLauncherData could not be created");
}

- (void) test_when_one_icon_is_added_page_count_should_be_one {
    HMLauncherIcon *icon = [self createDummyIcon];
    [cut addIcon:icon];
    
    STAssertEquals((NSUInteger) 1, [cut pageCount], @"expected 1 page, but is: %d", [cut pageCount]);
    STAssertEquals((NSUInteger) 1, [cut iconCount], @"expected 1 icon, but is: %d", [cut iconCount]);
}

- (void) test_when_five_icons_are_added_page_count_should_be_two {
    HMLauncherIcon *icon1 = [self createDummyIcon];
    HMLauncherIcon *icon2 = [self createDummyIcon];
    HMLauncherIcon *icon3 = [self createDummyIcon];
    HMLauncherIcon *icon4 = [self createDummyIcon];
    HMLauncherIcon *icon5 = [self createDummyIcon];
    [cut addIcon:icon1];
    [cut addIcon:icon2];    
    [cut addIcon:icon3];
    [cut addIcon:icon4];
    [cut addIcon:icon5];
    STAssertEquals((NSUInteger) 2, [cut pageCount], @"expected 2 page, but is: %d", [cut pageCount]);
    STAssertEquals((NSUInteger) 5, [cut iconCount], @"expected 5 icon, but is: %d", [cut iconCount]);

}

- (HMLauncherIcon*) createDummyIcon {
    HMLauncherItem *item = [[[HMLauncherItem alloc] init] autorelease];
    [item setIconPath:@"1.png"] ;
    
    HMLauncherIcon *icon = [[[HMLauncherIcon alloc] initWithLauncherItem:item] autorelease];
    return icon;
}

- (void) tearDown {
    [cut release];
}


@end
