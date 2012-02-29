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

#import "HMLauncherView.h"
#import "HMLauncherItem.h"

static const CGFloat kShakeRadians = 3.0f;
static const NSTimeInterval kShakeTime = 0.15;
static const CGFloat kScrollingFraction = 0.25f;
static const NSTimeInterval kScrollTimerInterval = 0.7;
static const CGFloat kLongPressDuration = 0.3;


@implementation NSIndexPath(LauncherPath)
- (NSUInteger) pageIndex {
    return [self indexAtPosition:0];
}

- (NSUInteger) iconIndex {
    return [self indexAtPosition:1];    
}
@end

@interface HMLauncherView() {
    BOOL editing;    
}
- (void) enumeratePagesUsingBlock:(void (^) (NSUInteger page)) block;
- (void) enumerateIconsOfPage:(NSUInteger) page 
                   usingBlock:(void (^) (HMLauncherIcon* icon, NSUInteger idx)) block;


- (CGFloat) calculateIconSpacer:(NSUInteger) numberOfColumns buttonSize:(CGSize) buttonSize;
- (NSInteger) calculateSpringOffset:(HMLauncherIcon*) icon;
- (void) executeScroll:(NSTimer*) timer;

- (void) didLongPressIcon:(UILongPressGestureRecognizer*) sender withEvent:(UIEvent*) event;
- (void) didTapIcon:(UITapGestureRecognizer*) sender;
- (void) longPressBegan:(HMLauncherIcon*) icon 
                 sender:(UILongPressGestureRecognizer*) longPress;
- (void) longPressMoved:(HMLauncherIcon*) icon 
                toPoint:(CGPoint) newPosition 
                 sender:(UILongPressGestureRecognizer*) longPress;
- (void) longPressEnded:(HMLauncherIcon*) icon 
                 sender:(UILongPressGestureRecognizer*) longPress;
- (void) removeAllGestureRecognizers:(HMLauncherIcon*) icon;
- (UILongPressGestureRecognizer*) launcherIcon:(HMLauncherIcon*) icon 
     addLongPressGestureRecognizerWithDuration:(CGFloat) duration 
                requireGestureRecognizerToFail:(UIGestureRecognizer*) recognizerToFail;
- (UITapGestureRecognizer*) launcherIcon:(HMLauncherIcon*) icon
 addTapRecognizerWithNumberOfTapsRequred:(NSUInteger) tapsRequired;

- (NSIndexPath*) iconIndexForPoint:(CGPoint) center;
- (NSUInteger) pageIndexForPoint:(CGPoint) center;

- (void) makeIconDraggable:(HMLauncherIcon*) icon;
- (void) makeIconNonDraggable:(HMLauncherIcon*) icon
           sourceLauncherView:(HMLauncherView*) sourceLauncherView
           targetLauncherView:(HMLauncherView*) targetLauncherView
                   completion:(void (^) (void)) block;

- (void) startShaking;
- (void) stopShaking;

- (void) checkIfScrollingIsNeeded:(HMLauncherIcon*) launcherIcon;
- (void) startScrollTimerWithOffset:(NSInteger) offset;
- (void) stopScrollTimer;
- (void) executeScroll:(NSTimer *)timer;

- (void) updatePagerWithContentOffset:(CGPoint) contentOffset;
- (void) updateScrollViewContentSize;
- (void) updateDeleteButtons;
- (UIView*) keyView;

@property (nonatomic, retain) UIScrollView *scrollView;
@property (nonatomic, retain) UIPageControl *pageControl;
@property (nonatomic, assign) NSTimer *scrollTimer;
@property (nonatomic, assign) HMLauncherIcon *dragIcon;
@property (nonatomic, assign) HMLauncherIcon *closingIcon;
@end

@implementation HMLauncherView
@synthesize dataSource;
@synthesize delegate;
@synthesize pageControl;
@synthesize scrollView;
@synthesize scrollTimer;
@synthesize dragIcon;
@synthesize closingIcon;
@synthesize shouldLayoutDragButton;
@synthesize targetPath;
@synthesize persistKey;

- (void) reloadData {
    self.dragIcon = nil;
    self.targetPath = nil;
    NSUInteger numberOfPages = [self.dataSource numberOfPagesInLauncherView:self];
    [self.pageControl setNumberOfPages:numberOfPages];
    
    // Remove all previous stuff from ScrollView;
    [[scrollView subviews] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        UIView *subview = obj;
        [subview removeFromSuperview];
    }];
    
    // Add all buttons to ScrollView
    [self enumeratePagesUsingBlock:^(NSUInteger page) {
        [self enumerateIconsOfPage:page usingBlock:^(HMLauncherIcon *icon, NSUInteger idx) {
            [self removeAllGestureRecognizers:icon];
            [self addIcon:icon];
        }];
    }];
    [self setNeedsLayout];
}

- (void) addIcon:(HMLauncherIcon*) icon {
    NSAssert([self.dataSource launcherView:self contains:icon] == YES, @"Model is inconsistent with view");
    
    UITapGestureRecognizer *tapGestureRecognizer = nil;
    if (icon.canBeTapped) {
        tapGestureRecognizer = [self launcherIcon:icon addTapRecognizerWithNumberOfTapsRequred:1];
    } 
    if (icon.canBeDragged) {
        [self launcherIcon:icon addLongPressGestureRecognizerWithDuration:kLongPressDuration requireGestureRecognizerToFail:tapGestureRecognizer];
    }   
    [self.scrollView addSubview:icon];
}

- (void) removeIcon:(HMLauncherIcon *)icon {
    [icon removeFromSuperview];
    [self removeAllGestureRecognizers:icon];
}

- (void) removeIconAnimated:(HMLauncherIcon*) icon  
                 completion:(void (^)(void))block {
    NSAssert([self.dataSource launcherView:self contains:icon] == NO, @"Model is inconsistent with view");    
    [UIView animateWithDuration:0.25 animations:^{
        icon.transform = CGAffineTransformMakeScale(0.1, 0.1);
    } completion:^(BOOL finished) {
        NSLog(@"removeIconAnimated finished");
        [self removeIcon:icon];
        block();
    }];
}

- (BOOL) editing {
    return editing;
}

- (UIView *) keyView {
	UIWindow *w = [[UIApplication sharedApplication] keyWindow];
	if (w.subviews.count > 0) {
		return [w.subviews lastObject];
	} else {
		return w;
	}
}

- (CGFloat) calculateIconSpacer:(NSUInteger) numberOfColumns buttonSize:(CGSize) buttonSize {
    CGFloat contentWidth = CGRectGetWidth(self.bounds);
    CGFloat allIconsWidth = numberOfColumns * buttonSize.width;
    CGFloat iconSpacer = (contentWidth - allIconsWidth) / (numberOfColumns - 1);
    return iconSpacer;
}

- (void) layoutSubviews {
    [self.pageControl sizeToFit];
    CGFloat pageControlHeight = CGRectGetHeight(self.pageControl.bounds);
    CGFloat pageControlY = CGRectGetHeight(self.bounds) - pageControlHeight;
    [self.pageControl setFrame:CGRectMake(0, pageControlY, CGRectGetWidth(self.bounds), pageControlHeight)];
    CGRect scrollViewFrame = self.bounds;
    
    if (!CGRectEqualToRect(scrollViewFrame, self.scrollView.frame)) {
        // see http://openradar.appspot.com/8045239
        self.scrollView.frame = scrollViewFrame;       
    }
    [self updateScrollViewContentSize];
    [self layoutIcons];
}

- (void) layoutIconsAnimated {
    [UIView animateWithDuration:0.75
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionAllowUserInteraction
                     animations:^{
                         [self layoutIcons];
                     }            
                     completion:^(BOOL finished) {
                     }];
}

- (void) layoutIcons {
    BOOL targetSpacerNeeded = self.targetPath != nil;
    NSAssert((self.shouldLayoutDragButton && targetSpacerNeeded) == NO, 
             @"targetPath cannot be set, when dragButton should be layouted");
    
    NSUInteger numberOfColumns = [self.dataSource numberOfColumnsInLauncherView:self]; 
    NSUInteger numberOfRows    = [self.dataSource numberOfRowsInLauncherView:self];
    CGSize  iconSize           = [self.dataSource buttonDimensionsInLauncherView:self];
    CGFloat iconSpacer         = [self calculateIconSpacer:numberOfColumns buttonSize:iconSize];
    
    CGFloat pageWidth = CGRectGetWidth(self.scrollView.bounds);
    
    __block NSInteger columnIndexForNextPage = 0;
    
    [self enumeratePagesUsingBlock:^(NSUInteger pageIndex) {
        CGFloat pageX   = pageWidth * pageIndex;
        NSInteger iconY = 0;
        CGFloat iconXStart = pageX;
        NSInteger currentColumnIndex = columnIndexForNextPage;
        columnIndexForNextPage = 0;
        NSInteger currentRowIndex = 0;
        
        NSMutableArray *iconsWithSpacer = [NSMutableArray arrayWithCapacity:(numberOfColumns * numberOfRows) + 1];
        [self enumerateIconsOfPage:pageIndex usingBlock:^(HMLauncherIcon *icon, NSUInteger iconIndex) {
            if (icon != dragIcon || (icon == dragIcon && shouldLayoutDragButton)) {
                [iconsWithSpacer addObject:icon];
            } 
        }];
        
        if (targetSpacerNeeded) {
            if ([self.targetPath pageIndex] == pageIndex) {
                NSInteger iconIndex = [self.targetPath iconIndex];
                if ([iconsWithSpacer count] > 0 && iconIndex < [iconsWithSpacer count]) {
                    [iconsWithSpacer insertObject:[NSNull null] atIndex:iconIndex];
                } else {
                    [iconsWithSpacer addObject:[NSNull null]];
                }
            }
        }    
        for (NSObject *iconObj in iconsWithSpacer) {
            if (currentColumnIndex == numberOfColumns) {
                iconY += iconSize.height;
                currentColumnIndex = 0;
                currentRowIndex++;
            }
            
            if (currentRowIndex == numberOfRows) {
                currentRowIndex = 0;
                iconXStart += pageWidth;
                iconY = 0;
                columnIndexForNextPage++;
            }
            
            if ([iconObj isKindOfClass:[HMLauncherIcon class]]) {
                HMLauncherIcon *icon = (HMLauncherIcon*) iconObj;
                CGFloat iconX = iconXStart + (currentColumnIndex * (iconSize.width + iconSpacer));
                [icon setBounds:CGRectMake(0, 0, iconSize.width, iconSize.height)];
                CGPoint iconCenterInScrollView = CGPointMake(iconX + iconSize.width / 2, iconY + iconSize.height / 2);
                if (icon != dragIcon) {
                    [icon setCenter:iconCenterInScrollView];
                } else if (shouldLayoutDragButton) {
                    CGPoint iconCenterInKeyView = [self.scrollView convertPoint:iconCenterInScrollView 
                                                                         toView:icon.superview];
                    [icon setCenter:iconCenterInKeyView];           
                }
            }
            currentColumnIndex++;  
        }; 
    }];
}

- (void) removeAllGestureRecognizers:(HMLauncherIcon*) icon {
    NSArray *gestureRecognizers = [[icon gestureRecognizers] copy];
    for (UIGestureRecognizer *recognizer in gestureRecognizers) {
        [icon removeGestureRecognizer:recognizer];
    }
    [gestureRecognizers release];
}

- (UILongPressGestureRecognizer*) launcherIcon:(HMLauncherIcon*) icon 
     addLongPressGestureRecognizerWithDuration:(CGFloat) duration 
                requireGestureRecognizerToFail:(UIGestureRecognizer*) recognizerToFail {
    // LongPress gesture
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self 
                                                                                            action:@selector(didLongPressIcon:withEvent:)];
    [longPress setMinimumPressDuration:0.4];
    if (recognizerToFail != nil) {
        [longPress requireGestureRecognizerToFail:recognizerToFail];
    }
    
    [icon addGestureRecognizer:longPress];
    return [longPress autorelease];
}

- (UITapGestureRecognizer*) launcherIcon:(HMLauncherIcon*) icon 
 addTapRecognizerWithNumberOfTapsRequred:(NSUInteger) tapsRequired {
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapIcon:)];
    [tap setNumberOfTapsRequired:tapsRequired];
    [icon addGestureRecognizer:tap];
    return [tap autorelease];
}

# pragma mark - Gesture Actions
- (void) didTapIcon:(UITapGestureRecognizer*) sender {
    HMLauncherIcon *launcherIcon = (HMLauncherIcon*) sender.view;
    CGPoint locationInView = [sender locationOfTouch:0 inView:launcherIcon];
    if (self.editing && [launcherIcon hitCloseButton:locationInView]) {
        NSString *message = [NSString stringWithFormat:NSLocalizedString(@"HMLauncherView_ConfirmDelete", nil), launcherIcon.launcherItem.titleText];
        
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"HMLauncherView_Alert", nil) 
                                                            message:message
                                                           delegate:self 
                                                  cancelButtonTitle:NSLocalizedString(@"HMLauncherView_Cancel",nil)
                                                  otherButtonTitles:NSLocalizedString(@"HMLauncherView_Ok", nil), nil];
        self.closingIcon = launcherIcon;
        [alertView show];
        [alertView release];
    } else {
        [self.delegate launcherView:self didTapLauncherIcon:launcherIcon];
    }
}

- (void) didLongPressIcon:(UILongPressGestureRecognizer*) sender withEvent:(UIEvent*) event {
    if ([self.scrollView isDragging]) {
        return;
    }
    HMLauncherIcon *icon = (HMLauncherIcon*) sender.view;   
    if (sender.state == UIGestureRecognizerStateBegan) {
        [self longPressBegan:icon sender:sender];
    } else if (sender.state == UIGestureRecognizerStateChanged) {
        CGPoint iconPoint = [sender locationInView:self];
        [self longPressMoved:icon toPoint:iconPoint sender:sender];
    } else if (sender.state == UIGestureRecognizerStateEnded) {
        [self longPressEnded:icon sender:sender];
    } else if (sender.state == UIGestureRecognizerStateCancelled) {
        [self longPressEnded:icon sender:sender];
    }
}

- (void) longPressBegan:(HMLauncherIcon*) icon sender:(UILongPressGestureRecognizer*) longPress {
    NSLog(@"%@: longPressBegan", persistKey);
    if (!self.editing) {
        [self startEditing];
        [self.delegate launcherViewDidStartEditing:self];
    }
    NSIndexPath *originIndexPath = [self iconIndexForPoint:icon.center];
    [icon setOriginIndexPath:originIndexPath];
    [self makeIconDraggable:icon];
}

- (void) longPressMoved:(HMLauncherIcon*) icon toPoint:(CGPoint) newCenter sender:(UILongPressGestureRecognizer*) longPress {
    NSAssert(icon.originIndexPath != nil, @"originIndexPath must be set");
    
    CGPoint newCenterOnKeyView = [icon.superview convertPoint:newCenter 
                                                     fromView:self];
    [icon setCenter:newCenterOnKeyView];
    
    HMLauncherView *launcherView = [self.delegate targetLauncherViewForIcon:icon];
    CGPoint iconPositionInTarget = [launcherView.scrollView convertPoint:icon.center 
                                                                fromView:icon.superview];
    
    NSIndexPath *indexPath = [launcherView iconIndexForPoint:iconPositionInTarget];    
    [launcherView setTargetPath:indexPath];
    [launcherView setDragIcon:icon];
    [launcherView checkIfScrollingIsNeeded:icon];
    [launcherView layoutIconsAnimated];
}

- (void) longPressEnded:(HMLauncherIcon*) icon sender:(UILongPressGestureRecognizer*) longPress {
    NSLog(@"longPressEnded: %@", self);
    
    HMLauncherView *launcherView = [self.delegate targetLauncherViewForIcon:icon];
    NSLog(@"launcherView responsible: %@", launcherView);
    if (launcherView == nil) {
        launcherView = self;
        self.targetPath = nil;
    }
    
    BOOL shouldStopEditing = NO;
    if (launcherView != nil) {
        NSAssert(launcherView.dragIcon == self.dragIcon, @"launcherView.dragIcon != self.dragIcon");
        
        [launcherView stopScrollTimer];
        if (launcherView.targetPath != nil) {
            shouldStopEditing = YES;
            NSInteger pageIndex = [launcherView.targetPath pageIndex];
            NSInteger iconIndex = [launcherView.targetPath iconIndex];
            launcherView.targetPath = nil;
            if (launcherView == self) {
                [self.dataSource launcherView:self moveIcon:self.dragIcon
                                       toPage:pageIndex
                                      toIndex:iconIndex];
                
            } else {
                NSLog(@"removing icon: %@ from launcherView: %@", self.dragIcon, self);
                [self.dataSource launcherView:self removeIcon:self.dragIcon];
                [self.delegate launcherView:self didDeleteIcon:self.dragIcon];
                NSLog(@"adding icon: %@ to launcherView: %@", self.dragIcon, launcherView);
                [launcherView.delegate launcherView:launcherView willAddIcon:self.dragIcon];            
                [launcherView.dataSource launcherView:launcherView addIcon:self.dragIcon
                                            pageIndex:pageIndex
                                            iconIndex:iconIndex];                
            }
        }
    }
    
    [launcherView makeIconNonDraggable:launcherView.dragIcon 
                    sourceLauncherView:self
                    targetLauncherView:launcherView
                            completion:^{
                                // Restart wobbling, so that the ex-dragging icon
                                // will wobble as well.
                                [launcherView stopShaking];
                                [launcherView startShaking];
                                if (shouldStopEditing) {
                                    [launcherView stopEditing];
                                    [launcherView.delegate launcherViewDidStopEditing:self];
                                }
                                [icon setOriginIndexPath:nil];
                            }];
    
    if (launcherView != self) {
        self.dragIcon = nil;
        self.targetPath = nil;
        [self stopScrollTimer];
        [self layoutIconsAnimated];
    }
}

- (void) startEditing {
    if (editing == NO) {
        editing = YES;
        [self.dataSource removeEmptyPages:self];
        [self.dataSource addPageToLauncherView:self];
        [self updateDeleteButtons];
        [self updateScrollViewContentSize];        
        [self updatePagerWithContentOffset:self.scrollView.contentOffset];
        [self startShaking];
    } else {
        NSLog(@" %@: editing of was already started", persistKey);
    }
}

- (void) stopEditing {
    if (editing == YES) {
        editing = NO;
        [self stopShaking];
        [self updateDeleteButtons];
        [self.dataSource removeEmptyPages:self];
        [self updateScrollViewContentSize];    
        [self updatePagerWithContentOffset:self.scrollView.contentOffset];
        [self setTargetPath:nil];
        [self setDragIcon:nil];
        [self layoutIconsAnimated];
    } else {
        NSLog(@" %@: editing of was already stopped", persistKey);
    }
    
}

- (void) checkIfScrollingIsNeeded:(HMLauncherIcon*) launcherIcon {
    NSInteger springOffset = [self calculateSpringOffset:launcherIcon];
    [self startScrollTimerWithOffset:springOffset];
}

- (void) startScrollTimerWithOffset:(NSInteger) offset {
    NSNumber *springOffsetNumber = [NSNumber numberWithInteger:offset];
    if (self.scrollTimer != nil) {
        // check if previous timer heads the right way
        NSNumber *previousSetOffsetNumber = self.scrollTimer.userInfo;
        if (previousSetOffsetNumber.integerValue != springOffsetNumber.integerValue) {
            [self stopScrollTimer];
            // call method again with new direction  offset.
            [self startScrollTimerWithOffset:offset];
        }
    } else {
        self.scrollTimer = [NSTimer scheduledTimerWithTimeInterval:kScrollTimerInterval target:self selector:@selector(executeScroll:) userInfo:springOffsetNumber repeats:NO];        
    }
}

- (void) stopScrollTimer {
    [self.scrollTimer invalidate], scrollTimer = nil;
}

- (void) executeScroll:(NSTimer*) timer {
    self.scrollTimer = nil;    
    if ([self.delegate targetLauncherViewForIcon:self.dragIcon] != self) {
        return;
    }
    
    NSNumber *offsetNumber = timer.userInfo;
    NSInteger offset = [offsetNumber integerValue];
    CGFloat newPageX = self.scrollView.contentOffset.x + offset * self.scrollView.bounds.size.width;
    NSInteger numberOfPages = [self.dataSource numberOfPagesInLauncherView:self];
    NSUInteger currentPageIndex = [self pageIndexForPoint:self.scrollView.contentOffset];
    
    BOOL isOnLastPage = (currentPageIndex + 1) == numberOfPages;
    BOOL allowedToGoRight = offset > 0 && !isOnLastPage;
    BOOL allowedToGoLeft  = newPageX >= 0 && offset < 0;
    
    if (allowedToGoLeft || allowedToGoRight) {
        CGRect newPageRect = CGRectMake(newPageX, 0, self.scrollView.bounds.size.width, self.scrollView.bounds.size.height);
        [self.scrollView scrollRectToVisible:newPageRect animated:YES];
        [self updatePagerWithContentOffset:newPageRect.origin];
    }
}

- (NSInteger) calculateSpringOffset:(HMLauncherIcon*) icon {
    CGSize iconSize = [self.dataSource buttonDimensionsInLauncherView:self];
    CGFloat springWidth = iconSize.width * kScrollingFraction;
    CGRect iconRectInLauncherView = [self convertRect:icon.frame fromView:icon.superview];
    
    CGFloat centerX = CGRectGetMidX(iconRectInLauncherView);
    BOOL goToPreviousPage = centerX < springWidth;
    BOOL goToNextPage = centerX > self.scrollView.bounds.size.width - springWidth;
    if (goToNextPage) {
        return 1;
    } 
    if (goToPreviousPage) {
        return -1;
    } else {
        return 0;
    };
}

- (void) makeIconDraggable:(HMLauncherIcon*) icon {
    NSParameterAssert(self.dragIcon == nil);
    
    self.dragIcon = icon;
    self.shouldLayoutDragButton = NO;
    
    // add icon to the top most view, so that we can drag it anywhere.
    [[self keyView] addSubview:self.dragIcon];    
    CGPoint iconOutsideScrollView = [self.dragIcon.superview convertPoint:self.dragIcon.center 
                                                                 fromView:self.scrollView];
    [self.dragIcon setCenter:iconOutsideScrollView];
    
    [UIView animateWithDuration:0.25 animations:^{
        icon.transform = CGAffineTransformMakeScale(1.5, 1.5);
        icon.alpha = 0.9;
    }];
    [self.delegate launcherView:self didStartDragging:icon];
}

- (void) makeIconNonDraggable:(HMLauncherIcon*) icon 
           sourceLauncherView:(HMLauncherView*) sourceLauncherView
           targetLauncherView:(HMLauncherView*) targetLauncherView
                   completion:(void (^) (void)) block {
    NSParameterAssert(icon != nil);
    [UIView animateWithDuration:0.25 animations:^{
        icon.transform = CGAffineTransformIdentity;
        icon.alpha = 1.0;
        self.shouldLayoutDragButton = YES;
        [self layoutIcons];
        self.shouldLayoutDragButton = NO;
    } completion:^(BOOL finished) {
        sourceLauncherView.dragIcon = nil;
        targetLauncherView.dragIcon = nil;
        if (sourceLauncherView != targetLauncherView) {
            [sourceLauncherView removeIcon:icon];
        } 
        [targetLauncherView addIcon:icon];
        [self layoutIcons];
        
        block();
    }];
    [self.delegate launcherView:self didStopDragging:icon];
}

- (NSIndexPath*) iconIndexForPoint:(CGPoint) center {
    CGSize iconSize = [self.dataSource buttonDimensionsInLauncherView:self];
    CGPoint centerOutsideScrollView = [self convertPoint:center fromView:self.scrollView];;
    NSUInteger maxColumns = [self.dataSource numberOfColumnsInLauncherView:self];
    NSUInteger maxRows = [self.dataSource numberOfRowsInLauncherView:self];
    
    NSUInteger currentPageIndex = [self pageIndexForPoint:center];
    NSUInteger currentColumnIndex = centerOutsideScrollView.x / iconSize.width;
    NSUInteger currentRowIndex = (center.y / iconSize.height); 
    
    if (currentRowIndex >= maxRows) {
        currentRowIndex = maxRows - 1;
    }
    if (currentColumnIndex >= maxColumns) {
        currentColumnIndex = maxColumns - 1;
    }    
    
    NSUInteger currentButtonIndex = (currentRowIndex * maxColumns) + currentColumnIndex; 
    NSUInteger indexes[] = { currentPageIndex, currentButtonIndex } ;
    NSIndexPath *indexPath = [[[NSIndexPath alloc] initWithIndexes:indexes length:2]autorelease];
    return indexPath;
}

- (NSUInteger) pageIndexForPoint:(CGPoint) center {
    NSUInteger currentPageIndex = 0;
    if (self.scrollView.contentOffset.x > 0) {
        currentPageIndex = self.scrollView.contentOffset.x / self.scrollView.bounds.size.width; 
    }
    return currentPageIndex;
}

- (void) updateScrollViewContentSize {
    NSUInteger numberOfPages = [self.dataSource numberOfPagesInLauncherView:self];
    self.scrollView.contentSize = CGSizeMake(numberOfPages * CGRectGetWidth(self.scrollView.bounds),
                                             CGRectGetHeight(self.scrollView.bounds));
    
}

- (void) updateDeleteButtons {
    [self enumeratePagesUsingBlock:^(NSUInteger page) {
        [self enumerateIconsOfPage:page usingBlock:^(HMLauncherIcon *icon, NSUInteger idx) {
            if (icon.canBeDeleted) {
                BOOL hideDeleteImage = !self.editing;
                [icon setHideDeleteImage:hideDeleteImage];
                [icon setNeedsDisplay];
            }
        }];
    }];  
}

# pragma mark - enumeration
- (void) enumeratePagesUsingBlock:(void (^) (NSUInteger page)) block {
    NSUInteger numberOfPages = [self.dataSource numberOfPagesInLauncherView:self];    
    for (int page=0; page<numberOfPages;page++) {
        block(page);
    }
}

- (void) enumerateIconsOfPage:(NSUInteger) page usingBlock:(void (^) (HMLauncherIcon* icon, NSUInteger idx)) block {
    NSUInteger buttonsInPage = [self.dataSource launcherView:self numberOfIconsInPage:page];
    for (int i=0;i<buttonsInPage;i++) {
        HMLauncherIcon *icon = [self.dataSource launcherView:self iconForPage:page atIndex:i];
        block(icon,i);
    }
}

# pragma mark - shaking
- (void) startShaking {
    CGFloat rotation = (kShakeRadians * M_PI) / 180.0;
    CGAffineTransform wobbleLeft = CGAffineTransformMakeRotation(rotation);
    CGAffineTransform wobbleRight = CGAffineTransformMakeRotation(-rotation);
    
    __block NSInteger i = 0;
    __block NSInteger nWobblyIcons = 0;
    
    [UIView animateWithDuration:kShakeTime 
                          delay:0 
                        options:UIViewAnimationOptionAutoreverse | UIViewAnimationOptionRepeat | UIViewAnimationOptionAllowUserInteraction
                     animations:^{
                         [self enumeratePagesUsingBlock:^(NSUInteger page) {
                             [self enumerateIconsOfPage:page usingBlock:^(HMLauncherIcon *icon, NSUInteger idx) {
                                 if (icon != self.dragIcon && icon != self.closingIcon) {
                                     ++nWobblyIcons;
                                     if (i % 2) {
                                         icon.transform = wobbleRight;
                                     } else {
                                         icon.transform = wobbleLeft;
                                     }
                                 }
                                 ++i;
                             }];
                         }];   
                     } completion: ^(BOOL finished){
                         
                     }];
}

- (void) stopShaking {
    [self enumeratePagesUsingBlock:^(NSUInteger page) {
        [self enumerateIconsOfPage:page usingBlock:^(HMLauncherIcon *icon, NSUInteger idx) {
            [UIView animateWithDuration:kShakeTime 
                                  delay:0.0 
                                options:UIViewAnimationOptionAllowUserInteraction
                             animations:^{
                                 icon.transform = CGAffineTransformIdentity; 
                             } completion: ^(BOOL finished) {
                                 
                             }];
        }];
    }];
}

- (void)updatePagerWithContentOffset:(CGPoint) contentOffset {
    CGFloat pageWidth = self.scrollView.bounds.size.width;
    NSUInteger numberOfPages = [self.dataSource numberOfPagesInLauncherView:self];
    self.pageControl.numberOfPages = numberOfPages;
    self.pageControl.currentPage = floor((contentOffset.x - pageWidth / 2) / pageWidth) + 1;
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *) inScrollView{
    if (self.dragIcon != nil) {
        [self checkIfScrollingIsNeeded:self.dragIcon];
    }
    [self updatePagerWithContentOffset:inScrollView.contentOffset];
}

- (void) scrollViewDidEndDecelerating:(UIScrollView *) inScrollView {
    [self updatePagerWithContentOffset:inScrollView.contentOffset];    
}

- (NSString*) description {
    return [NSString stringWithFormat:@"%@", self.persistKey];
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger) buttonIndex {
    if (buttonIndex != alertView.cancelButtonIndex) {
        NSParameterAssert(self.closingIcon != nil);
        [self.dataSource launcherView:self removeIcon:self.closingIcon];
        [self removeIconAnimated:self.closingIcon 
                      completion:^{
                          self.closingIcon = nil;                          
                          [self stopEditing];
                          [self.delegate launcherViewDidStopEditing:self];
                      }];
    };
}

#pragma mark - lifecycle
- (id)initWithFrame:(CGRect) frame {
    if (self = [super initWithFrame:frame]) {
        [self setAutoresizingMask:UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth];
        self.scrollView = [[[UIScrollView alloc] initWithFrame:self.bounds] autorelease];
        [self.scrollView setDelegate:self];
        [self.scrollView setPagingEnabled:YES];
        [self.scrollView setShowsHorizontalScrollIndicator:NO]; 
        [self.scrollView setShowsVerticalScrollIndicator:NO];
        [self addSubview:self.scrollView];
        
        self.pageControl = [[[UIPageControl alloc] initWithFrame:
                             CGRectMake(0, 10, 10, 10)
                             ] autorelease];
        [self.pageControl setHidesForSinglePage:YES];
        [self addSubview:self.pageControl];

    }
    return self;
}

- (void) dealloc {  
    dataSource = nil;
    delegate = nil;
    [scrollTimer invalidate], scrollTimer = nil;
    [targetPath release], targetPath = nil;    
    [scrollView release], scrollView = nil;
    [pageControl release], pageControl = nil;
    [super dealloc];
}

@end
