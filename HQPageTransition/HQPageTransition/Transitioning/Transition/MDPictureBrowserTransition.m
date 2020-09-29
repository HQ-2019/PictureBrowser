//
//  MDPictureBrowserTransition.m
//  HQPageTransition
//
//  Created by huangqun on 2020/9/24.
//  Copyright © 2020 huangqun. All rights reserved.
//

#import "MDPictureBrowserTransition.h"
#import "MDTransitionProtocol.h"

@implementation MDPictureBrowserTransition

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
    
    UIView *toView = toVC.view;
    UIView *fromView = fromVC.view;
    UIView *containerView = [transitionContext containerView];
    [containerView addSubview:toView];
    
    // 判断是否实现了协议
    if (![self respondsToSelector:toVC fromeVC:fromVC]) {
        [transitionContext completeTransition:YES];
        return;
    }
    
    // 动画转场开始的视图(多数为点击触发页面转场的图片视图)
//    UIImageView *startView = (UIImageView *)[fromVC hq_animationViewForMotionTransition:YES];
//    CGRect startViewFrame = [containerView convertRect:startView.frame fromView:startView.superview];
    
    UIView *tempView = [fromVC md_transitionAnimationView:YES];
    UIImageView *startView;
    if ([tempView isKindOfClass:[UIImageView class]]) {
        startView = (UIImageView *)tempView;
    } else {
        UIImage *image = [self convertViewToImage:tempView];
        startView = [[UIImageView alloc] initWithImage:image];
    }
    CGRect startViewFrame = [containerView convertRect:tempView.frame fromView:tempView.superview];
    
    UIView *endView = [toVC md_transitionAnimationView:YES];
    
    // 读取视图失败则不执行自定义的过渡动画
    if (!startView || !endView) {
        [transitionContext completeTransition:YES];
        return;
    }
    
    // 用户呈现过渡动画的主要图片视图
    UIImageView * imageView = [self imageViewWithFrame:startViewFrame image:startView.image];
    [toView addSubview:imageView];
    
    // 计算imageView最终展示的frame
    CGFloat imageW = startView.image ? startView.image.size.width : startView.bounds.size.width;
    CGFloat imageH = startView.image ? startView.image.size.height : startView.bounds.size.height;
    CGRect imageViewFinalFrame;
    CGFloat H = endView.frame.size.width * imageH/imageW;
    if (imageH/imageW > endView.frame.size.height/endView.frame.size.width) {
        //长图 指图片宽度方大为屏幕宽度时，高度超过屏幕高度
        imageViewFinalFrame = CGRectMake(0, 0, endView.frame.size.width, H);
    } else {
        //非长图
        imageViewFinalFrame = CGRectMake(0, endView.frame.size.height/2 - H/2, endView.frame.size.width, H);
    }

    if ([toVC respondsToSelector:@selector(md_transitionHideSubView:)]) {
        [toVC md_transitionHideSubView:YES];
    }
    
    toView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.0];
    [UIView animateWithDuration:[self transitionDuration:transitionContext] delay:0.0f usingSpringWithDamping:0.8f initialSpringVelocity:1.0f options:UIViewAnimationOptionCurveLinear animations:^{
        imageView.frame = imageViewFinalFrame;
        toView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:1.0];
    } completion:^(BOOL finished) {
        [imageView removeFromSuperview];
        //通知页面跳转动画是否已完成(是否被取消)
        [transitionContext completeTransition:!transitionContext.transitionWasCancelled];
        if ([toVC respondsToSelector:@selector(md_transitionHideSubView:)]) {
            [toVC md_transitionHideSubView:NO];
        }
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
    
    UIView *toView = toVC.view;
    UIView *fromView = fromVC.view;
    UIView *containerView = [transitionContext containerView];
    
    // 判断是否实现了协议
    if (![self respondsToSelector:toVC fromeVC:fromVC]) {
        [transitionContext completeTransition:YES];
        return;
    }
    
    // 动画转场开始的视图(多数为点击触发页面转场的图片视图,如果不是图片，则将获取到的视图转换成图片)
    UIView *tempView = [fromVC md_transitionAnimationView:NO];
    UIImageView *startView;
    if ([tempView isKindOfClass:[UIImageView class]]) {
        startView = (UIImageView *)tempView;
    } else {
        UIImage *image = [self convertViewToImage:tempView];
        startView = [[UIImageView alloc] initWithImage:image];
    }
    CGRect startViewFrame = [containerView convertRect:tempView.frame fromView:tempView.superview];
    
    UIView *endView = [toVC md_transitionAnimationView:NO];
    
    // 读取视图失败则不执行自定义的过渡动画
    if (!startView || !endView) {
        [transitionContext completeTransition:YES];
        return;
    }
    
    // 用户呈现过渡动画的主要图片视图
    UIImageView * imageView = [self imageViewWithFrame:startViewFrame image:startView.image];
    [fromView addSubview:imageView];
    
    CGRect imageViewFinalFrame = [containerView convertRect:endView.frame fromView:endView.superview];
    if ([fromVC respondsToSelector:@selector(md_transitionHideSubView:)]) {
        [fromVC md_transitionHideSubView:YES];
    }
    endView.hidden = YES;
    // 不需要重复设置黑色背景的透明图，如果设置了会在图片下拉触发页面返回时出现拉下过程中原本已经设置的透明度在这里被重置为1，变现为背景出现闪一下的现象
    // fromView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:1.0];
    [UIView animateWithDuration:[self transitionDuration:transitionContext] delay:0.0f usingSpringWithDamping:0.8f initialSpringVelocity:1.0f options:UIViewAnimationOptionCurveLinear animations:^{
        imageView.frame = imageViewFinalFrame;
        fromView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.0];
    } completion:^(BOOL finished) {
        endView.hidden = NO;
        [imageView removeFromSuperview];
        // 通知页面跳转动画是否已完成(是否被取消)
        [transitionContext completeTransition:!transitionContext.transitionWasCancelled];
    }];
}

- (UIImageView *)imageViewWithFrame:(CGRect)frame image:(UIImage *)image {
    UIImageView * imageView = [[UIImageView alloc] initWithFrame:frame];
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    imageView.clipsToBounds = YES;
    imageView.image = image;
    return imageView;
}

/// 将UIView转化成UIImage
/// @param view 要转换的view
- (UIImage*)convertViewToImage:(UIView*)view {
    UIImage *image = [[UIImage alloc] init];
    UIGraphicsBeginImageContextWithOptions(view.frame.size, YES, [UIScreen mainScreen].scale);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    image =UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

- (BOOL)respondsToSelector:(UIViewController *)toVC fromeVC:(UIViewController *)fromVC {
    return toVC && fromVC && [toVC respondsToSelector:@selector(md_transitionAnimationView:)] && [fromVC respondsToSelector:@selector(md_transitionAnimationView:)];
}

@end
