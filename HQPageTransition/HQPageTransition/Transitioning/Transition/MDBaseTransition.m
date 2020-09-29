//
//  MDBaseTransition.m
//  HQPageTransition
//
//  Created by huangqun on 2020/8/27.
//  Copyright © 2020 huangqun. All rights reserved.
//

#import "MDBaseTransition.h"

@interface MDBaseTransition ()

/// 标记需要执行的动画是否是开始进入页面的过渡动画
@property (nonatomic, assign) BOOL isBegin;

@end


@implementation MDBaseTransition
/// 实例化
/// @param isBegin 是否是开始过渡
+ (instancetype _Nonnull)transition:(BOOL)isBegin {
    MDBaseTransition *transition = [self new];
    transition.isBegin = isBegin;
    return transition;
}

/// 过渡动画持续时长
- (NSTimeInterval)transitionDuration:(nullable id <UIViewControllerContextTransitioning>)transitionContext {
    return 0.5;
}

/// 过渡动画实现（由子类实现）
- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext {
    if (self.isBegin) {
        [self beginAnimateTransition:transitionContext];
    } else {
        [self endAnimateTransition:transitionContext];
    }
}

/// 进入页面时的过渡动画（由子类实现）
- (void)beginAnimateTransition:(id <UIViewControllerContextTransitioning>)transitionContext {
    UIView *toView = [transitionContext viewForKey:UITransitionContextToViewKey];
    toView.frame = [transitionContext containerView].bounds;
    [[transitionContext containerView] addSubview:toView];
    [transitionContext completeTransition:!transitionContext.transitionWasCancelled];
}

/// 页面返回的过渡动画（由子类实现）
- (void)endAnimateTransition:(id <UIViewControllerContextTransitioning>)transitionContext {
    [transitionContext completeTransition:!transitionContext.transitionWasCancelled];
}

@end
