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

#import "LauncherParentView.h"
#import "HMLauncherView.h"

#define BUTTON_SPACER 10

@interface LauncherParentView(private)
- (CGRect) centerRectForLauncherView:(HMLauncherView*) launcherView parentRect:(CGRect) parentRect;
@end

@implementation LauncherParentView
@synthesize launcherViewLeft;
@synthesize launcherViewRight;

- (void) drawRect:(CGRect)rect {
    CGContextRef c = UIGraphicsGetCurrentContext();
    [[UIColor blackColor] setFill];
    CGContextFillRect(c, self.bounds);
}

- (void) layoutSubviews {
    CGRect leftHalfRect = CGRectMake(0, 0, self.bounds.size.width / 2, self.bounds.size.height);
    CGRect launcherViewLeftRect = [self centerRectForLauncherView:launcherViewLeft parentRect:leftHalfRect];
    [self.launcherViewLeft setFrame:launcherViewLeftRect];
    
    CGRect rightHalfRect = CGRectMake(self.bounds.size.width / 2, 0, self.bounds.size.width / 2, self.bounds.size.height);
    CGRect launcherViewRightRect =[self centerRectForLauncherView:launcherViewRight parentRect:rightHalfRect];
    [self.launcherViewRight setFrame:launcherViewRightRect];
    
}

- (CGRect) centerRectForLauncherView:(HMLauncherView*) launcherView parentRect:(CGRect) parentRect {
    CGSize buttonDimensionsInLauncherView = [launcherView.dataSource buttonDimensionsInLauncherView:launcherView];
    
    int rows = [launcherView.dataSource numberOfRowsInLauncherView:launcherView];
    int cols = [launcherView.dataSource numberOfColumnsInLauncherView:launcherView];
    
    CGRect launcherViewRect = CGRectMake(parentRect.origin.x,
                                         parentRect.origin.y, 
                                         cols * (buttonDimensionsInLauncherView.width + BUTTON_SPACER) ,
                                         rows * buttonDimensionsInLauncherView.height);
    
    CGRect centeredLauncherViewRect = launcherViewRect;
    centeredLauncherViewRect.origin.x = parentRect.origin.x + (parentRect.size.width / 2  - launcherViewRect.size.width / 2);
    centeredLauncherViewRect.origin.y = parentRect.origin.y + (parentRect.size.height / 2  - launcherViewRect.size.height / 2);    

    return centeredLauncherViewRect;
}



#pragma mark - lifecycle
- (id) initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
        self.launcherViewLeft = [[[HMLauncherView alloc] initWithFrame:CGRectZero] autorelease];
        self.launcherViewRight = [[[HMLauncherView alloc] initWithFrame:CGRectZero] autorelease];
        [self addSubview:self.launcherViewLeft];
        [self addSubview:self.launcherViewRight];
    }
    return self;
}

- (void) dealloc {
    [launcherViewLeft release], launcherViewLeft = nil;
    [launcherViewRight release], launcherViewRight = nil;
    [super dealloc];
}

@end
