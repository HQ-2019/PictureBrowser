//
//  UIViewController+MDTransitionProperty.h
//  HQPageTransition
//
//  Created by huangqun on 2020/9/27.
//  Copyright © 2020 huangqun. All rights reserved.
//
//  页面转场时需要设置的通用属性
//

#import <UIKit/UIKit.h>
#import "MDTransitionManager.h"
#import "MDPercentDrivenInteractiveTransition.h"

NS_ASSUME_NONNULL_BEGIN

@interface UIViewController (MDTransitionProperty)

@property (nonatomic, strong, readwrite) MDTransitionManager *transiton;
//@property (nonatomic, strong) HQPercentDrivenInteractiveTransition *interactive;

@end

NS_ASSUME_NONNULL_END
