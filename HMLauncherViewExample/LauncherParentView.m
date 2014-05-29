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
#define PAGECONTROL_HEIGHT 20

@interface LauncherParentView(private)
- (CGRect) centerRectForLauncherView:(HMLauncherView*) launcherView parentRect:(CGRect) parentRect;
@end

@implementation LauncherParentView

- (void) drawRect:(CGRect)rect {
    CGContextRef c = UIGraphicsGetCurrentContext();
    [[UIColor blackColor] setFill];
    CGContextFillRect(c, self.bounds);
}

- (void) layoutSubviews {
    CGRect leftHalfRect = CGRectMake(0, 0, self.bounds.size.width / 2, self.bounds.size.height);
    CGRect launcherViewLeftRect = [self centerRectForLauncherView:self.launcherViewLeft parentRect:leftHalfRect];
    [self.launcherViewLeft setFrame:launcherViewLeftRect];
    
    CGRect rightHalfRect = CGRectMake(self.bounds.size.width / 2, 0, self.bounds.size.width / 2, self.bounds.size.height);
    CGRect launcherViewRightRect =[self centerRectForLauncherView:self.launcherViewRight parentRect:rightHalfRect];
    [self.launcherViewRight setFrame:launcherViewRightRect];
    
}

- (CGRect) centerRectForLauncherView:(HMLauncherView*) launcherView parentRect:(CGRect) parentRect {
    CGSize buttonDimensionsInLauncherView = [launcherView.dataSource buttonDimensionsInLauncherView:launcherView];
    
    NSUInteger rows = [launcherView.dataSource numberOfRowsInLauncherView:launcherView];
    NSUInteger cols = [launcherView.dataSource numberOfColumnsInLauncherView:launcherView];
    
    CGRect launcherViewRect = CGRectMake(parentRect.origin.x,
                                         parentRect.origin.y, 
                                         cols * (buttonDimensionsInLauncherView.width + BUTTON_SPACER) ,
                                         (rows * buttonDimensionsInLauncherView.height) + PAGECONTROL_HEIGHT);
    
    CGRect centeredLauncherViewRect = launcherViewRect;
    centeredLauncherViewRect.origin.x = parentRect.origin.x + (parentRect.size.width / 2  - launcherViewRect.size.width / 2);
    centeredLauncherViewRect.origin.y = parentRect.origin.y + (parentRect.size.height / 2  - launcherViewRect.size.height / 2);    

    return centeredLauncherViewRect;
}



#pragma mark - lifecycle
- (id) initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
        _launcherViewLeft = [[HMLauncherView alloc] initWithFrame:CGRectZero];
        _launcherViewRight = [[HMLauncherView alloc] initWithFrame:CGRectZero];
        [self addSubview:_launcherViewLeft];
        [self addSubview:_launcherViewRight];
    }
    return self;
}


@end
