//
//  MDBaseTransition.h
//  HQPageTransition
//
//  Created by huangqun on 2020/8/27.
//  Copyright © 2020 huangqun. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface MDBaseTransition : NSObject <UIViewControllerAnimatedTransitioning>

/// 标记需要执行的动画是否是开始进入页面的过渡动画
@property (nonatomic, assign, readonly) BOOL isBegin;

/// 实例化
/// @param isBegin 是否是开始过渡
+ (instancetype _Nonnull)transition:(BOOL)isBegin;

/// 过渡动画持续时长
- (NSTimeInterval)transitionDuration:(nullable id <UIViewControllerContextTransitioning>)transitionContext;

/// 过渡动画实现（由子类实现）
- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext;

/// 进入页面时的过渡动画（由子类实现）
- (void)beginAnimateTransition:(id <UIViewControllerContextTransitioning>)transitionContext;

/// 页面返回的过渡动画（由子类实现）
- (void)endAnimateTransition:(id <UIViewControllerContextTransitioning>)transitionContext;

@end

NS_ASSUME_NONNULL_END
