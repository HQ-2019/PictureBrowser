//
//  MDTransitionManager.h
//  HQPageTransition
//
//  Created by huangqun on 2020/8/27.
//  Copyright © 2020 huangqun. All rights reserved.
//
//  页面转场动画的主要分配者，通过传入的动画类型给转场过渡分配不同的动画对象和手势交互对象
//

#import <UIKit/UIKit.h>
#import "MDTransitionManager.h"
#import "MDPercentDrivenInteractiveTransition.h"

/**<  Push的自定义转场动画类型  */
typedef NS_ENUM(NSUInteger, MDPushType) {
    MDPushType_None = 0,        /**<  无子定义动画，使用系统默认  */
    MDPushType_Zoom,            /**<  缩放过渡效果（需要实现HQTransitionProtocol），如从一个局部视图过渡到新页面，返回时从一个页面过渡到之前的局部视图  */
};

/**<  Present的自定义转场动画类型  */
typedef NS_ENUM(NSUInteger, MDPresentType) {
    MDPresentType_None = 0,         /**<  无子定义动画，使用系统默认  */
    MDPresentType_PictureZoom,      /**<  图片缩放过渡效果（需要实现HQTransitionProtocol），新旧两个页面上的两个图片视图之间的过渡效果，图片浏览器常用  */
};

NS_ASSUME_NONNULL_BEGIN

@interface MDTransitionManager : NSObject <UIViewControllerTransitioningDelegate, UINavigationControllerDelegate>

@property (nonatomic, strong) MDPercentDrivenInteractiveTransition *interactive;    /**<  手势交互过渡处理类  */

@property (nonatomic, assign) MDPushType pushType;              /**<  push动画类型  */
@property (nonatomic, assign) MDPresentType presentType;        /**<  present动画类型  */

@end

NS_ASSUME_NONNULL_END
