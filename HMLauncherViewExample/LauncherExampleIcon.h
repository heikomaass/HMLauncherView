//
//  LauncherExampleIcon.h
//  HMLauncherViewExample
//
//  Created by Heiko Maaß on 29.02.12.
//  Copyright (c) 2012 Heiko Maass. All rights reserved.
//

#import "HMLauncherIcon.h"

@interface LauncherExampleIcon : HMLauncherIcon
@property (nonatomic, strong) UIImage *iconImage;
@property (nonatomic, strong) UIImage *closeImage;
@property (nonatomic, assign) CGRect closeRect;

@end
