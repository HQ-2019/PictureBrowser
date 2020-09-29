//
//  UIViewController+MDTransition.m
//  HQPageTransition
//
//  Created by huangqun on 2020/9/27.
//  Copyright © 2020 huangqun. All rights reserved.
//

#import "UIViewController+MDTransition.h"

#import "MDPercentDrivenInteractiveTransition.h"


@implementation UIViewController (MDTransition)

/// present方式推出控制器，默认为系统动画
/// @param controller 控制器
/// @param completion 结束时的回调
- (void)hq_persentViewController:(UIViewController *)controller
                      completion:(void (^__nullable)(void))completion {
    [self hq_persentViewController:controller presentType:MDPresentType_None completion:completion];
}

/// 指定动画类型的present，默认启用手势交互
/// @param controller 控制器
/// @param presentType 动画类型
/// @param completion 结束时的回调
- (void)hq_persentViewController:(UIViewController *)controller
                     presentType:(MDPresentType)presentType
                      completion:(void (^__nullable)(void))completion {
    [self hq_persentViewController:controller presentType:presentType useInteractive:YES completion:completion];
}

/// 指定动画类型的present
/// @param controller 控制器
/// @param presentType 动画类型
/// @param useInteractive 是否启用手势交互，YES为启用
/// @param completion 结束时的回调
- (void)hq_persentViewController:(UIViewController *)controller
                     presentType:(MDPresentType)presentType
                  useInteractive:(BOOL)useInteractive
                      completion:(void (^__nullable)(void))completion {
    controller.transiton = [MDTransitionManager new];
    controller.transiton.presentType = presentType;
    if (presentType != MDPresentType_None && useInteractive) {
        controller.transiton.interactive = [MDPercentDrivenInteractiveTransition interactiveTransition:controller];
    }
    controller.transitioningDelegate = controller.transiton;
    controller.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    [self presentViewController:controller animated:YES completion:completion];
}

@end


@implementation UINavigationController (HQTransition)

/// push一个控制器（默认为系统动画效果）
/// @param controller 控制器
- (void)hq_pushViewController:(UIViewController *)controller {
    [self hq_pushViewController:controller pushType:MDPushType_None];
}

/// 指定动画l类型的push， 默认启用手势交互
/// @param controller 控制器
/// @param pushType 动画类型
- (void)hq_pushViewController:(UIViewController *)controller
                     pushType:(MDPushType)pushType {
    [self hq_pushViewController:controller pushType:pushType useInteractive:YES];
}

/// 指定动画类型的push
/// @param controller 控制器
/// @param pushType 动画类型
/// @param useInteractive 是否启用手势过渡动画的交互，YES为启用
- (void)hq_pushViewController:(UIViewController *)controller
                     pushType:(MDPushType)pushType
               useInteractive:(BOOL)useInteractive {
    controller.transiton = [MDTransitionManager new];
    controller.transiton.pushType = pushType;
    if (pushType != MDPushType_None && useInteractive) {
        controller.transiton.interactive = [MDPercentDrivenInteractiveTransition interactiveTransition:controller];
    }
    self.delegate = controller.transiton;
    [self pushViewController:controller animated:YES];
}

@end
