//
//  MDPictureBrowserViewController.h
//  HQPageTransition
//
//  Created by huangqun on 2020/9/23.
//  Copyright © 2020 huangqun. All rights reserved.
//
//  图片浏览器
//

/* 待完善功能
 ~ 配置是否自动播放下一张
 ~ 配置是否可以循环播放
 */

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN


@interface MDPictureBrowserViewController : UIViewController

/// 创建图片浏览器
/// @param thumbnails 缩略图（缩略图和原图链接要一一对应）
/// @param imageUrls 原图链接
/// @param index 当前需要展示的图片的索引
- (instancetype)initWithThumbnails:(NSArray<UIImage *> *)thumbnails imageUrls:(nullable NSArray<NSString *> *)imageUrls index:(NSInteger)index;

@property (nonatomic, copy) void(^pictureIndexChange)(NSInteger index);     /**<  浏览图片切换时回调图片的索引  */

@end

NS_ASSUME_NONNULL_END
