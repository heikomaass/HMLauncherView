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

#import "LauncherService.h"
#import "HMLauncherItem.h"
#import "HMLauncherIcon.h"
#import "LauncherExampleIcon.h"
#import "HMLauncherView.h"
#import "HMLauncherData.h"


@interface LauncherService() 
- (HMLauncherData*) launcherDataFor:(HMLauncherView*) launcherView;
- (HMLauncherIcon*) launcherIconForTitle:(NSString*) titleText 
                               imagePath:(NSString*) imagePath
                     imageBackgroundPath:(NSString*) imageBackgroundPath;
@end

@implementation LauncherService
@synthesize launcherDataLeft;
@synthesize launcherDataRight;

- (NSMutableArray*) addPageToLauncherView:(HMLauncherView*) launcherView {
    NSParameterAssert(launcherView != nil);
    HMLauncherData *data = [self launcherDataFor:launcherView];
    return [data addPage];
}

- (HMLauncherData*) launcherDataFor:(HMLauncherView*) launcherView {
    NSParameterAssert(launcherView.persistKey != nil);
    if ([launcherView.persistKey isEqualToString:self.launcherDataLeft.persistKey]) {
        return self.launcherDataLeft;
    }
    if ([launcherView.persistKey isEqualToString:self.launcherDataRight.persistKey]) {
        return self.launcherDataRight;
    }
    return nil;
}

#pragma mark - HMLauncherDataSource
- (NSUInteger) numberOfRowsInLauncherView:(HMLauncherView *) launcherView {
    HMLauncherData *data = [self launcherDataFor:launcherView];
    return data.maxRows;
}

- (NSUInteger) numberOfColumnsInLauncherView:(HMLauncherView*) launcherView {
    HMLauncherData *data = [self launcherDataFor:launcherView];
    return data.maxColumns;
}

- (CGSize) buttonDimensionsInLauncherView:(HMLauncherView *)launcherView {
    return CGSizeMake(80, 120);
}

- (NSUInteger)numberOfPagesInLauncherView:(HMLauncherView *)launcherView {
    NSParameterAssert(launcherView != nil);
    HMLauncherData *data = [self launcherDataFor:launcherView];
    return [data.launcherIconPages count];
}

- (NSUInteger)numberOfIconsInLauncherView:(HMLauncherView *)launcherView {
    HMLauncherData *data = [self launcherDataFor:launcherView];
    NSUInteger count = 0;
    for (NSMutableArray *page in data.launcherIconPages) {
        count += [page count];
    }
    return count;
}

- (NSUInteger)launcherView:(HMLauncherView *)launcherView numberOfIconsInPage:(NSUInteger) page {
    NSParameterAssert(launcherView != nil);
    NSParameterAssert(page < 5000);
    HMLauncherData *data = [self launcherDataFor:launcherView];
    NSMutableArray *buttons = [data.launcherIconPages objectAtIndex:page];
    return [buttons count];
}

- (BOOL) launcherView:(HMLauncherView *) launcherView contains:(HMLauncherIcon*) icon {
    NSParameterAssert(launcherView != nil);
    NSParameterAssert(icon != nil);
    HMLauncherData *data = [self launcherDataFor:launcherView];    
    if ([data pageOfIcon:icon] == nil) {
        return NO;
    }
    return YES;
}

- (HMLauncherIcon *) launcherView: (HMLauncherView *)launcherView
                      iconForPage: (NSUInteger)pageIndex
                          atIndex: (NSUInteger)iconIndex {
    HMLauncherData *data = [self launcherDataFor:launcherView];    
    NSMutableArray *buttons = [data.launcherIconPages objectAtIndex:pageIndex];
    return [buttons objectAtIndex:iconIndex];
}

- (void) launcherView:(HMLauncherView *) launcherView
              addIcon:(HMLauncherIcon*) icon {
    HMLauncherData *data = [self launcherDataFor:launcherView];    
    [data addIcon:icon];
}

- (void) launcherView:(HMLauncherView*) launcherView
              addIcon:(HMLauncherIcon*) icon
            pageIndex:(NSUInteger) pageIndex
            iconIndex:(NSUInteger) iconIndex {
    HMLauncherData *data = [self launcherDataFor:launcherView];     
    [data addIcon:icon pageIndex:pageIndex iconIndex:iconIndex];
}

- (void) launcherView:(HMLauncherView *)launcherView removeIcon:(HMLauncherIcon *)icon {
    NSParameterAssert(launcherView != nil);
    HMLauncherData *data = [self launcherDataFor:launcherView];
    [data removeIcon:icon];
}

- (void) launcherView:(HMLauncherView*) launcherView
             moveIcon:(HMLauncherIcon*) icon 
               toPage:(NSUInteger) pageIndex
              toIndex:(NSUInteger) iconIndex {
    HMLauncherData *data = [self launcherDataFor:launcherView];
    NSParameterAssert(data != nil);
    [data moveIcon:icon toPage:pageIndex toIndex:iconIndex];
}

- (void) removeEmptyPages:(HMLauncherView*) launcherView {
    NSParameterAssert(launcherView != nil);
    HMLauncherData *data = [self launcherDataFor:launcherView];
    [data removeEmptyPages];
}

- (NSArray*) launcherView:(HMLauncherView*) launcherView findIconsByIdentifier:(NSString*) identifier {
    NSParameterAssert(launcherView != nil);
    NSParameterAssert(identifier != nil);
    HMLauncherData *data = [self launcherDataFor:launcherView];
    return [data findIconsByIdentifier:identifier];
}

- (void) loadLauncherData {
    NSParameterAssert(self.launcherDataLeft != nil);
    NSString *lorem = @"Lorem ipsum dolor sit amet consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut";
    NSArray *loremArray = [lorem componentsSeparatedByString:@" "];
    
    NSString *imageBackgroundLightPath = @"icon_border_bold_light.png";

    // Add some dummy icons for launcherview on the left side.
    for (int i=1;i<15;i++) {
        NSString *imagePath = [NSString stringWithFormat:@"%d.png", i];
        NSString *titleText = [loremArray objectAtIndex:i];
        HMLauncherIcon *icon = [self launcherIconForTitle:titleText
                                      imagePath:imagePath
                                      imageBackgroundPath:imageBackgroundLightPath];
        if (i %2 == 0) {
            [icon setCanBeDeleted:YES];
        }
        
        [self.launcherDataLeft addIcon:icon];          
        
    }

    NSString *imageBackgroundDarkPath = @"icon_border_bold_dark.png";
    
    // Add some dummy icons for launcherview on the right side.
    char start = 'a';
    for (int i=1;i<14;i++) {
        NSString *titleText = [loremArray objectAtIndex:i];
        NSString *imagePath = [NSString stringWithFormat:@"%c.png", start];
        HMLauncherIcon *icon = [self launcherIconForTitle:titleText
                                      imagePath:imagePath
                                      imageBackgroundPath:imageBackgroundDarkPath];
        if (i %2 == 1) {
            [icon setCanBeDeleted:YES];
        }        
        [self.launcherDataRight addIcon:icon];
        start++;
    }
}

- (HMLauncherIcon*) launcherIconForTitle:(NSString*) titleText
                               imagePath:(NSString*) imagePath 
                     imageBackgroundPath:(NSString*) imageBackgroundPath {
    NSParameterAssert(titleText != nil);
    NSString *titleLowercase  = [titleText lowercaseString];
    NSString *titleReplaced = [titleLowercase stringByReplacingOccurrencesOfString:@" " withString:@"_"];    
    NSString *identifier = [NSString stringWithFormat:@"static_%@", titleReplaced];
    
    HMLauncherItem *launcherItem = [[HMLauncherItem alloc] init];
    [launcherItem setIdentifier:identifier];
    [launcherItem setTitleText:titleText];
    [launcherItem setIconPath:imagePath];
    [launcherItem setIconBackgroundPath:imageBackgroundPath];
    LauncherExampleIcon *launcherIcon = [[LauncherExampleIcon alloc] initWithLauncherItem:launcherItem];
    [launcherIcon setCanBeTapped:YES];
    [launcherIcon setCanBeDragged:YES];   

    
    [launcherItem release];
    return [launcherIcon autorelease]; 
}

- (BOOL) launcherItem:(HMLauncherItem*) item inData:(HMLauncherData*) data {
    NSParameterAssert(item != nil);
    NSArray *array = [data findIconsByIdentifier:item.identifier];
    return [array count] > 0;
}

#pragma mark - lifecycle
- (id) init {
    if (self = [super init]) {
        self.launcherDataLeft  = [[[HMLauncherData alloc] init] autorelease];
        self.launcherDataLeft.persistKey = @"LauncherDataLeft";
        self.launcherDataLeft.maxRows = 3;
        self.launcherDataLeft.maxColumns = 3;
        self.launcherDataRight = [[[HMLauncherData alloc] init] autorelease];
        self.launcherDataRight.persistKey = @"LauncherDataRight"; 
        self.launcherDataRight.maxRows = 2;
        self.launcherDataRight.maxColumns = 4;
    }
    return self;
}

- (void) dealloc {
    [launcherDataLeft release], launcherDataLeft = nil;
    [launcherDataRight release], launcherDataRight = nil;
    [super dealloc];
}

@end
