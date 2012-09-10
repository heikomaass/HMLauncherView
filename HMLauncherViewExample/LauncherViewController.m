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

#import "LauncherViewController.h"
#import "LauncherParentView.h"
#import "LauncherService.h"
#import "HMLauncherData.h"
#import "HMLauncherView.h"

@interface LauncherViewController() 
    @property(nonatomic, assign) BOOL dragIconHasMoved;
@end

@implementation LauncherViewController
@synthesize launcherService;
@synthesize currentDraggingView;
@synthesize dragIconHasMoved;

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (LauncherParentView*) launcherParentView {
    return (LauncherParentView*) self.view;
}

#pragma mark - View lifecycle
- (void)loadView {
    LauncherParentView *launcherParentView = [[LauncherParentView alloc] initWithFrame:CGRectZero];
    self.view = launcherParentView;
    [launcherParentView release];
}


- (void)viewDidLoad {
    NSParameterAssert(launcherService != nil);
    [launcherService launcherDataLeft];
    HMLauncherData *launcherDataLeft = launcherService.launcherDataLeft;
    HMLauncherView *launcherViewLeft = self.launcherParentView.launcherViewLeft;
    
    NSParameterAssert(launcherDataLeft != nil);
    [launcherViewLeft setPersistKey:launcherDataLeft.persistKey];
    [launcherViewLeft setDataSource:launcherService];
    [launcherViewLeft setDelegate:self];
    [launcherViewLeft reloadData];
    
    
    HMLauncherData *launcherDataRight = launcherService.launcherDataRight;
    HMLauncherView *launcherViewRight = self.launcherParentView.launcherViewRight;
    NSParameterAssert(launcherViewRight != nil);
    [launcherViewRight setPersistKey:launcherDataRight.persistKey];
    [launcherViewRight setDataSource:launcherService];
    [launcherViewRight setDelegate:self];
    [launcherViewRight reloadData];
    
    [super viewDidLoad];
}

- (void)viewDidUnload {
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}
#pragma mark - HMLauncherViewDelegate 
- (void) launcherView:(HMLauncherView *)launcherView didTapLauncherIcon:(HMLauncherIcon *)icon {
    NSLog(@"didTapLauncherIcon: %@", icon);
}

- (void) launcherView:(HMLauncherView *)launcherView didStartDragging:(HMLauncherIcon *)icon {
    NSLog(@"didStartDragging");
    self.currentDraggingView = launcherView;
}

- (void) launcherView:(HMLauncherView *)launcherView didStopDragging:(HMLauncherIcon *)icon {
    NSLog(@"didStopDragging");
    self.currentDraggingView = nil;
    
}

- (void) launcherView:(HMLauncherView*) launcherView willMoveIcon:(HMLauncherIcon *)icon fromIndex:(NSIndexPath *)fromIndex toIndex:(NSIndexPath *)toIndex {
    self.dragIconHasMoved = YES;
}

- (void) launcherView:(HMLauncherView*) launcherView willAddIcon:(HMLauncherIcon*) addedIcon {
    
}

- (void) launcherView:(HMLauncherView*) launcherView didDeleteIcon:(HMLauncherIcon*) deletedIcon {
    
}

- (void) launcherViewDidAppear:(HMLauncherView *)launcherView {
    
}

- (void) launcherViewDidDisappear:(HMLauncherView *)launcherView {
    
}

- (BOOL) launcherViewShouldStopEditingAfterDraggingEnds:(HMLauncherView *)launcherView {
    return self.dragIconHasMoved;
}

- (void) launcherViewDidStartEditing:(HMLauncherView*) launcherView {
    if (!self.launcherParentView.launcherViewLeft.editing) {
        [self.launcherParentView.launcherViewLeft startEditing];          
    }
    
    if (!self.launcherParentView.launcherViewRight.editing) {
        [self.launcherParentView.launcherViewRight startEditing];
    }
}

- (void) launcherViewDidStopEditing:(HMLauncherView*) launcherView {
    self.dragIconHasMoved = NO;
    if (self.launcherParentView.launcherViewLeft.editing) {
        [self.launcherParentView.launcherViewLeft stopEditing];          
    }
    
    if (self.launcherParentView.launcherViewRight.editing) {
        [self.launcherParentView.launcherViewRight stopEditing];
    }
}

- (HMLauncherView*) targetLauncherViewForIcon:(HMLauncherIcon *) icon {
    
    CGRect leftLauncherViewRectInKeyView = [icon.superview convertRect:self.launcherParentView.launcherViewLeft.frame
                                                              fromView:self.launcherParentView.launcherViewLeft.superview];
    
    CGRect rightLauncherViewRectInKeyView = [icon.superview convertRect:self.launcherParentView.launcherViewRight.frame
                                                               fromView:self.launcherParentView.launcherViewRight.superview];
    BOOL inLeftLauncherView = (CGRectContainsPoint(leftLauncherViewRectInKeyView, icon.center));
    BOOL inRightLauncherView = (CGRectContainsPoint(rightLauncherViewRectInKeyView, icon.center));
    
    if (inLeftLauncherView && inRightLauncherView) {
        // both launcherviews are overlapping. this is not intended. 
        // in order to prevent a crash, the current draggingView will be returned.
    } else {
        if (inLeftLauncherView) {
            return self.launcherParentView.launcherViewLeft;
        }
        
        if (inRightLauncherView) {
            return self.launcherParentView.launcherViewRight; 
        }
    }
    return self.currentDraggingView;
}

#pragma mark - Lifecycle
- (id) initWithLauncherService:(LauncherService*) inLauncherService {
    if (self = [super init]) {
        self.launcherService = inLauncherService;
    }
    return self;
    
}

- (void) dealloc {
    [launcherService release], launcherService = nil;
    [super dealloc];
}


@end
