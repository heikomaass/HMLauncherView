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

@implementation HMLauncherIcon
@synthesize canBeDeleted;
@synthesize canBeDragged;
@synthesize canBeTapped;
@synthesize hideDeleteImage;
@synthesize iconImage;
@synthesize closeImage;
@synthesize identifier;
@synthesize originIndexPath;
@synthesize launcherItem;
@synthesize closeRect;


@interface HMLauncherIcon(private) 
- (void) setIconImageFromIconPath:(NSString *)iconPath;
- (UIImage*) mergeBackgroundImage:(UIImage*) bottomImage withTopImage:(UIImage*) image;
@end

- (BOOL) hitCloseButton:(CGPoint)point {
    return (CGRectContainsPoint(self.closeRect, point));
}
- (void) drawRect:(CGRect) rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGFloat availableWidth = self.iconImage.size.width;
    
    // Icon
    CGFloat x = floor((self.bounds.size.width - availableWidth) / 2);
    CGFloat y = 10;
    CGRect buttonRect = CGRectMake(x, y, self.iconImage.size.width, self.iconImage.size.height);
    
    // Highlighted
    // FIXME:
    
//    if (self.highlighted && (self.canBeTapped || self.canBeDragged)) {
//        [[UIColor darkGrayColor] setFill];
//        CGMutablePathRef outerPath = createRoundedRectForRect(buttonRect, 11.0);
//        CGContextSaveGState(context);
//        CGContextAddPath(context, outerPath);
//        CGContextFillPath(context);
//        CGContextRestoreGState(context);
//        CGPathRelease(outerPath);
//        
//    }
    CGFloat alpha = 1.0;
//    if (self.canBeDragged == NO) {
//        alpha = 0.3;
//    }
    [self.iconImage drawInRect:buttonRect blendMode:kCGBlendModeOverlay alpha:alpha];
    
    // Close Button
//    if (!self.hideDeleteImage) {
//        [[UIColor gsYellow] setFill];
//        CGContextFillEllipseInRect(context, self.closeRect);
//        [self.closeImage drawInRect:self.closeRect];
//    } else if (!self.hideStarImage) {
//        // Star Image
//        [self.starImage drawInRect:self.starRect];
//    }
    
    // Text
//    y += buttonRect.size.height + 3;
//    UIFont *font = [UIFont fontForCellSmall];
//    [[UIColor blackColor] setFill];
//    
//    NSString *text = self.item.titleText;
//    if (self.item.titleTextWithDelimiter != nil) {
//        text = self.item.titleTextWithDelimiter;
//    }
//    
//    CGSize maxTextSize = CGSizeMake(availableWidth, self.bounds.size.height - y);
//    CGSize textSize = [text sizeWithFont:font 
//                       constrainedToSize:maxTextSize 
//                           lineBreakMode:UILineBreakModeWordWrap];
//    
//    x = floor((self.bounds.size.width - textSize.width) / 2);
//    CGRect textRect = CGRectMake(x, y, textSize.width, textSize.height);
//    CGContextSetAlpha(context, alpha);
//    [text drawInRect:textRect withFont:[UIFont fontForCellSmall] lineBreakMode:UILineBreakModeWordWrap alignment:UITextAlignmentCenter];
}

- (void) setHighlighted:(BOOL)highlighted {
    [super setHighlighted:highlighted];
    [self setNeedsDisplay];
}

- (NSString*) description {
    return [NSString stringWithFormat:@"%@ identifier:%@", launcherItem.titleText, self.identifier];
}

#pragma mark - lifecycle
- (id) initWithLauncherItem: (HMLauncherItem*) inLauncherItem {
    if (self = [super initWithFrame:CGRectZero]) {
        [self setContentMode:UIViewContentModeRedraw];
        [self setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
        closeRect = CGRectMake(0, 5, 20, 20);
        self.launcherItem = inLauncherItem;
        self.identifier = inLauncherItem.identifier;
        self.hideDeleteImage = YES;
        
        self.closeImage = [UIImage imageNamed:@"schnellsuche_close.png"];
        
        [self setIconImageFromIconPath:self.launcherItem.iconPath];
        [self setClipsToBounds:NO];
        NSParameterAssert(self.iconImage != nil);
        [self setBackgroundColor:[UIColor clearColor]];
    }
    return self;
}

- (void) setIconImageFromIconPath:(NSString *)iconPath {
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    NSString *imagePath = [bundle pathForResource:self.launcherItem.iconPath ofType:nil];
    UIImage *aIconImage = [UIImage imageWithContentsOfFile:imagePath];
    
    
    
//    UIImage *aIconImage = [UIImage imageNamed:self.launcherItem.iconPath];
// UIImage *aBackgroundImage = [UIImage imageNamed:self.launcherItem.iconBackgroundPath];
    NSString *aBackgroundImagePath = [bundle pathForResource:self.launcherItem.iconBackgroundPath ofType:nil];
    UIImage *aBackgroundImage = [UIImage imageWithContentsOfFile:aBackgroundImagePath];
    
    
    
    NSParameterAssert(aIconImage != nil); // Für den Namen des Icons muss es ein Bild geben.
    self.iconImage = [self mergeBackgroundImage:aBackgroundImage  withTopImage:aIconImage];
}

- (UIImage*) mergeBackgroundImage:(UIImage*) bottomImage withTopImage:(UIImage*) image {
    CGSize newSize = bottomImage.size;    
    UIGraphicsBeginImageContext( newSize );
    
    [bottomImage drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    int x = (int)((bottomImage.size.width - image.size.width) / 2);
    int y = (int)((bottomImage.size.height- image.size.height) / 2);
    
    [image drawInRect:CGRectMake(x, y, image.size.width, image.size.height) blendMode:kCGBlendModeNormal alpha:1.0];
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

-(void) dealloc {
    [originIndexPath release], originIndexPath = nil;
    [identifier release], identifier = nil;
    [iconImage release], iconImage = nil;
    [closeImage release], closeImage = nil;
    [launcherItem release], launcherItem = nil;
    [super dealloc];
}
@end
