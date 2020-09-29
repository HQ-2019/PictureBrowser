//
//  UIViewController+MDTransitionProperty.m
//  HQPageTransition
//
//  Created by huangqun on 2020/9/27.
//  Copyright © 2020 huangqun. All rights reserved.
//

#import "UIViewController+MDTransitionProperty.h"
#import <objc/runtime.h>

static char * const kTransition = "kTransition";
//static char * const kInteractive = "kInteractive";

@implementation UIViewController (MDTransitionProperty)

- (void)setTransiton:(MDTransitionManager *)transitonManager {
    objc_setAssociatedObject(self, kTransition, transitonManager, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (MDTransitionManager *)transiton {
    return objc_getAssociatedObject(self, kTransition);
}


//- (void)setInteractive:(HQPercentDrivenInteractiveTransition *)interactive {
//    objc_setAssociatedObject(self, kInteractive, interactive, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
//}
//
//- (HQPercentDrivenInteractiveTransition *)interactive {
//    return objc_getAssociatedObject(self, kInteractive);
//}

@end
