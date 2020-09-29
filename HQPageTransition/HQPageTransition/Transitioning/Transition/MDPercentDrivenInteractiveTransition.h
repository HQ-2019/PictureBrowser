//
//  MDPercentDrivenInteractiveTransition.h
//  HQPageTransition
//
//  Created by huangqun on 2020/9/27.
//  Copyright © 2020 huangqun. All rights reserved.
//
// 手势控制动画执行的百分比
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface MDPercentDrivenInteractiveTransition : UIPercentDrivenInteractiveTransition

@property(nonatomic, assign) BOOL interacting;              /**< 当前的手势是否作用到视图交互效果上 */

+ (instancetype _Nonnull)interactiveTransition:(UIViewController *)controller;

@end

NS_ASSUME_NONNULL_END
