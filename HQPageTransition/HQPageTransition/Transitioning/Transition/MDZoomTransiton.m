//
//  MDZoomTransiton.m
//  HQPageTransition
//
//  Created by huangqun on 2020/8/27.
//  Copyright © 2020 huangqun. All rights reserved.
//

#import "MDZoomTransiton.h"
#import "MDTransitionProtocol.h"

@interface MDZoomTransiton ()

@property (nonatomic, assign) CGRect beginFrame;

@end

@implementation MDZoomTransiton

/// 进入页面时的过渡动画（由子类实现）
- (void)beginAnimateTransition:(id <UIViewControllerContextTransitioning>)transitionContext {
    UIViewController<MDTransitionProtocol> *toVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIViewController<MDTransitionProtocol> *fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    
    if ([fromVC isKindOfClass:[UINavigationController class]]) {
        UINavigationController *navc = (UINavigationController *)fromVC;
        fromVC = navc.viewControllers.firstObject;
    }
    
    if ([toVC isKindOfClass:[UINavigationController class]]) {
        UINavigationController *navc = (UINavigationController *)toVC;
        toVC = navc.viewControllers.firstObject;
    }
    
    // 判断控制器是否null,和是否都实现了代理
    if (![self respondsToSelector:toVC fromeVC:fromVC]) {
        [transitionContext completeTransition:YES];
        return;
    }
    
    UIView *toView = toVC.view;
    UIView *fromView = fromVC.view;
    UIView *containerView = [transitionContext containerView];
    
    UIView *startView = [fromVC md_transitionAnimationView:YES];
    UIView *endView = [toVC md_transitionAnimationView:YES];
    if (!startView || !endView) {
        [transitionContext completeTransition:YES];
        return;
    }
    
    CGPoint startViewPoint = [startView convertPoint:CGPointZero toView:nil];
    CGPoint endViewPoint = [endView convertPoint:CGPointZero toView:nil];
    
    //增加黑色透明层在fromView上
    UIView * shadow = [[UIView alloc]initWithFrame:fromView.frame];
    shadow.backgroundColor = [UIColor blackColor];
    shadow.alpha = 0;
    
    // 点击视图的快照
    UIView *startViewSnapShot = [startView snapshotViewAfterScreenUpdates:NO];
    startViewSnapShot.frame = CGRectMake(startViewPoint.x, startViewPoint.y, startViewSnapShot.frame.size.width, startViewSnapShot.frame.size.height);
   
    [containerView addSubview:shadow];
    [containerView addSubview:startViewSnapShot];
    [containerView addSubview:toView];
    
    
    // 设置缩放比例值
    CGFloat endViewHeightScale = startView.frame.size.height / endView.frame.size.height;
    CGFloat endViewWidthScale = startView.frame.size.width / endView.frame.size.width;
    
    // toView最终的frame
    CGRect toViewFinalFrame = toView.frame;
    // 动画开始前toView缩放后和startView重叠在一起
    toView.transform = CGAffineTransformMakeScale(endViewWidthScale, endViewHeightScale);
    toView.center = startViewSnapShot.center;
    toView.alpha = 0;

    [UIView animateWithDuration:[self transitionDuration:transitionContext] delay:0.0f usingSpringWithDamping:0.8f initialSpringVelocity:1.0f options:UIViewAnimationOptionCurveLinear animations:^{
        shadow.alpha = 0.8;
        toView.alpha = 1;
        toView.transform = CGAffineTransformMakeScale(1, 1);
        toView.frame = toViewFinalFrame;
        startViewSnapShot.frame = toView.frame;
    } completion:^(BOOL finished) {
        [shadow removeFromSuperview];
        [startViewSnapShot removeFromSuperview];
        
        //恢复视图的缩放
        toView.transform = CGAffineTransformIdentity;
        
        //通知页面跳转动画是否已完成(是否被取消)
        [transitionContext completeTransition:!transitionContext.transitionWasCancelled];
    }];
}

/// 页面返回的过渡动画（由子类实现）
- (void)endAnimateTransition:(id <UIViewControllerContextTransitioning>)transitionContext {
    UIViewController<MDTransitionProtocol> *toVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIViewController<MDTransitionProtocol> *fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    
    if ([fromVC isKindOfClass:[UINavigationController class]]) {
        UINavigationController *navc = (UINavigationController *)fromVC;
        fromVC = navc.viewControllers.firstObject;
    }
    
    if ([toVC isKindOfClass:[UINavigationController class]]) {
        UINavigationController *navc = (UINavigationController *)toVC;
        toVC = navc.viewControllers.firstObject;
    }
    
    
    // 判断是否实现了协议
    if (![self respondsToSelector:toVC fromeVC:fromVC]) {
        [transitionContext completeTransition:YES];
        return;
    }

    UIView *toView = toVC.view;
    UIView *fromView = fromVC.view;
    UIView *containerView = [transitionContext containerView];
    [containerView addSubview:toView];

    UIView *startView = [fromVC md_transitionAnimationView:NO];
    UIView *endView = [toVC md_transitionAnimationView:NO];
    if (!startView || !endView) {
        [transitionContext completeTransition:YES];
        return;
    }
    
    CGPoint startViewPoint = [startView convertPoint:CGPointZero toView:nil];
    CGPoint endViewPoint = [endView convertPoint:CGPointZero toView:nil];

    //增加黑色透明层在toView上
    UIView * shadow = [[UIView alloc] initWithFrame:toView.frame];
    shadow.backgroundColor = [UIColor blackColor];
    shadow.alpha = 0.5;
    [containerView addSubview:shadow];
    
    // 目标视图截图
    UIView *endViewSnapShot = [endView snapshotViewAfterScreenUpdates:NO];
    // 动画开始前目标视图的截图缩放后和fromView重叠在一起
    endViewSnapShot.frame = fromView.frame;
    if (!transitionContext.isInteractive) {
        [containerView addSubview:endViewSnapShot];
    }

    // endViewSnapShot最终的frame
    CGRect endViewSnapShotFinalFrame = [containerView convertRect:endView.frame fromView:endView.superview];
    
    // 设置缩放比例值
    CGFloat startViewHeightScale = endView.frame.size.height / startView.frame.size.height;
    CGFloat endViewWidthScale = endView.frame.size.width / startView.frame.size.width;
    
    // 将fromView展示在最上层
    [containerView bringSubviewToFront:fromView];
    endView.hidden = YES;
    if (transitionContext.isInteractive) {
        endViewSnapShot.frame = endViewSnapShotFinalFrame;
    }
    
    [UIView animateWithDuration:[self transitionDuration:transitionContext] delay:0.0f usingSpringWithDamping:0.8f initialSpringVelocity:1.0f options:UIViewAnimationOptionCurveLinear animations:^{
        shadow.alpha = 0;
        if (!transitionContext.isInteractive) {
            endViewSnapShot.frame = endViewSnapShotFinalFrame;
            fromView.alpha = 0;
        }
        fromView.transform =  CGAffineTransformMakeScale(endViewWidthScale, startViewHeightScale);
        fromView.frame = CGRectMake(endViewPoint.x, endViewPoint.y, fromView.frame.size.width, fromView.frame.size.height);
    } completion:^(BOOL finished) {
        endView.hidden = NO;
        [shadow removeFromSuperview];
        [endViewSnapShot removeFromSuperview];

        // 通知页面跳转动画是否已完成(是否被取消)
        [transitionContext completeTransition:!transitionContext.transitionWasCancelled];
        
    }];
}

- (BOOL)respondsToSelector:(UIViewController *)toVC fromeVC:(UIViewController *)fromVC {
    return toVC && fromVC && [toVC respondsToSelector:@selector(md_transitionAnimationView:)] && [fromVC respondsToSelector:@selector(md_transitionAnimationView:)];
}

@end
