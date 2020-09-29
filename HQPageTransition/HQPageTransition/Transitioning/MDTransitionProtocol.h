//
//  MDTransitionProtocol.h
//  HQPageTransition
//
//  Created by huangqun on 2020/8/27.
//  Copyright © 2020 huangqun. All rights reserved.
//
//  某些特殊动画需要controller实现代理，过渡动画中可通过代理获取一些特定的数据或视图
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol MDTransitionProtocol <NSObject>

@required;

/// 获取交互的视图，（动画起始位置的视图或者是动画结束对标的视图）
/// @param isEnter  YES是进入页面、NO是离开页面
- (UIView *_Nonnull)md_transitionAnimationView:(BOOL)isEnter;

@optional
/// 页面过渡中是否需要隐藏页面上的子视图
/// @param hide YES:隐藏
- (void)md_transitionHideSubView:(BOOL)hide;

@end

NS_ASSUME_NONNULL_END
