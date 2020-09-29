//
//  MDTransitionManager.m
//  HQPageTransition
//
//  Created by huangqun on 2020/8/27.
//  Copyright © 2020 huangqun. All rights reserved.
//

#import "MDTransitionManager.h"
#import "MDZoomTransiton.h"
#import "MDPictureBrowserTransition.h"

@interface MDTransitionManager ()

@end

@implementation MDTransitionManager

#pragma mark -
#pragma mark - UIViewControllerTransitioningDelegate (present/dismiss)
- (nullable id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented
                                                                            presentingController:(UIViewController *)presenting
                                                                                sourceController:(UIViewController *)source {
    // precent的过渡处理对象
    switch (self.presentType) {
        case MDPresentType_PictureZoom:
            return [MDPictureBrowserTransition transition:YES];
        default:
            return nil;
    }
}

- (nullable id <UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    // dismiss的过渡处理对象
    switch (self.presentType) {
        case MDPresentType_PictureZoom:
            return [MDPictureBrowserTransition transition:NO];
        default:
            return nil;
    }
}

- (nullable id <UIViewControllerInteractiveTransitioning>)interactionControllerForPresentation:(id <UIViewControllerAnimatedTransitioning>)animator {
    return nil;
}

- (nullable id <UIViewControllerInteractiveTransitioning>)interactionControllerForDismissal:(id <UIViewControllerAnimatedTransitioning>)animator {
    return self.interactive.interacting ? self.interactive : nil;
}

- (nullable UIPresentationController *)presentationControllerForPresentedViewController:(UIViewController *)presented
                                                               presentingViewController:(nullable UIViewController *)presenting
                                                                   sourceViewController:(UIViewController *)source API_AVAILABLE(ios(8.0)) {
    return nil;
}

#pragma mark -
#pragma mark - UINavigationControllerDelegate (push/pop)

- (nullable id <UIViewControllerInteractiveTransitioning>)navigationController:(UINavigationController *)navigationController
                                   interactionControllerForAnimationController:(id <UIViewControllerAnimatedTransitioning>) animationController {
    // 返回上级页面的手势交互处理
    return self.interactive.interacting ? self.interactive : nil;
}

- (nullable id <UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController
                                            animationControllerForOperation:(UINavigationControllerOperation)operation
                                                         fromViewController:(UIViewController *)fromVC
                                                           toViewController:(UIViewController *)toVC {
    if (operation == UINavigationControllerOperationPush) {
        switch (self.pushType) {
            case MDPushType_Zoom:
                return [MDZoomTransiton transition:YES];
            default:
                return Nil;
        }
    }
        
    if (operation == UINavigationControllerOperationPop) {
        switch (self.pushType) {
            case MDPushType_Zoom:
                return [MDZoomTransiton transition:NO];
            default:
                return Nil;
        }
    }
    
    return nil;
}

@end
