//
//  MDDetailListViewController.h
//  HQPageTransition
//
//  Created by huangqun on 2020/8/27.
//  Copyright © 2020 huangqun. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface MDDetailListViewController : UIViewController

/// 初始化控制器
/// @param thumbnail 缩略图，进入控制器时默认展示的图片（获取以后会扩展更多其他展示的默认数据），然后等等网络加载数据后进行更新
/// @param index 前需要展示的图片的索引
- (instancetype)initWithThumbnail:(UIImage *)thumbnail index:(NSInteger)index;

@property (nonatomic, copy) void(^pictureIndexChange)(NSInteger index);     /**<  浏览图片切换时回调图片的索引  */

@end

NS_ASSUME_NONNULL_END
