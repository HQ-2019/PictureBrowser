//
//  MDPictureBrowserCell.h
//  HQPageTransition
//
//  Created by huangqun on 2020/9/23.
//  Copyright © 2020 huangqun. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol MDPictureBrowserCellDelegate <NSObject>

/// 图片下拉触发关闭视图事件
- (void)dismissView:(NSIndexPath *)indexPath;

/// 图片移动过程中，更新控制器的背景透明度
- (void)imageViewTouchMoveChangeAlpha:(CGFloat)alpha;

/// 图片长按触发事件
- (void)longPressImage:(UIImage *)image;

@end

@interface MDPictureBrowserCell : UICollectionViewCell

@property (nonatomic, strong, readonly) UIImageView *imageView;

@property (nonatomic, assign) id<MDPictureBrowserCellDelegate> delegate;

/// 设置图片数据
/// @param thumbnail 缩略图
/// @param imageUrl 原图地址
/// @param indexPath indexPath
- (void)setDataWithThumbnail:(UIImage *)thumbnail imageUrl:(NSString *)imageUrl indexPath:(NSIndexPath *)indexPath;

@end

NS_ASSUME_NONNULL_END
