//
//  MDPercentDrivenInteractiveTransition.m
//  HQPageTransition
//
//  Created by huangqun on 2020/9/27.
//  Copyright © 2020 huangqun. All rights reserved.
//

#import "MDPercentDrivenInteractiveTransition.h"

@interface MDPercentDrivenInteractiveTransition ()

#define dSCREEN_WIDTH   ([UIScreen mainScreen].bounds.size.width)
#define dSCREEN_HEIGHT  ([UIScreen mainScreen].bounds.size.height)

@property (nonatomic, strong) UIViewController *controller;

@end

@implementation MDPercentDrivenInteractiveTransition

+ (instancetype _Nonnull)interactiveTransition:(UIViewController *)controller {
    MDPercentDrivenInteractiveTransition *transtion = [self new];
    transtion.controller = controller;
    [transtion addGestureRecognizer];
    return transtion;
}

#pragma mark -
#pragma mark - 给新退出的视图添加手势识别
- (void)addGestureRecognizer {
    //手势识别为屏幕左侧边缘 如需全屏幕识别侧使用UIPanGestureRecognizer手势
//    if (self.gesture) {
//        [_presentedVC.view removeGestureRecognizer:self.gesture];
//    }
//    UIScreenEdgePanGestureRecognizer *gesture = [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self action:@selector(gestureRecognizerAction:)];
//    gesture.edges = UIRectEdgeLeft;
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(gestureRecognizerAction:)];
    [self.controller.view addGestureRecognizer:panGesture];
}

#pragma mark -
#pragma mark -  手势识别事件
- (void)gestureRecognizerAction:(UIPanGestureRecognizer *)panGesture {
    
    CGPoint translation = [panGesture translationInView:panGesture.view];
    // 计算手势平移在整个屏幕宽度上的百分比 (0 ~ 1)
    CGFloat percent = translation.x / panGesture.view.bounds.size.width / 3;
    
    switch (panGesture.state) {
        case UIGestureRecognizerStateBegan:{
            self.interacting =  YES;
            // 判断当前视图时push还是present方式推出的，返回也采用对应的方式
            if (self.controller.navigationController.viewControllers.count > 1) {
                [self.controller.navigationController popViewControllerAnimated:YES];
            } else {
                [self.controller dismissViewControllerAnimated:YES completion:nil];
            }
            break;
        }
        case UIGestureRecognizerStateChanged:{
            self.interacting = NO;
            [self updateInteractiveTransition:percent];
            break;
        }
            
        case UIGestureRecognizerStateEnded:{
            self.interacting = NO;
            if (percent > 0.2) {
                [self finishInteractiveTransition];
            } else {
                [self cancelInteractiveTransition];
            }
            
            break;
        }
            
        default:
            break;
    }
}

@end
