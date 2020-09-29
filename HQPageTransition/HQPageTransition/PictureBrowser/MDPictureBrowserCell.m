//
//  MDPictureBrowserCell.m
//  HQPageTransition
//
//  Created by huangqun on 2020/9/23.
//  Copyright © 2020 huangqun. All rights reserved.
//

#import "MDPictureBrowserCell.h"

#import "UIImageView+WebCache.h"

#define dVIEW_WIDTH   self.bounds.size.width
#define dVIEW_HEIGHT  self.bounds.size.height

@interface MDPictureBrowserCell () <UIScrollViewDelegate>

@property (nonatomic, strong) UIScrollView *bgScrollView;                   /**<  缩放容器  */
@property (nonatomic, strong) UIImageView *imageView;                       /**<  图片视图  */
@property (nonatomic, strong) UIActivityIndicatorView *indicatorView;       /**<  图片加载指示器  */

@property (nonatomic, assign) NSInteger touchFingerNumber;              /**<  记录当前接触屏幕的手指数  */

@property (nonatomic, strong) NSIndexPath *indexPath;


@end

@implementation MDPictureBrowserCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initSubViews];
    }
    return self;
}

#pragma mark -
#pragma mark - 初始化子视图

- (UIActivityIndicatorView *)indicatorView {
    if (_indicatorView == nil) {
        _indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        _indicatorView.center = self.center;
        [self addSubview:_indicatorView];
    }
    return _indicatorView;
}

- (void)initSubViews {
    
    // 滚动视图，主要用于图片的缩放
    _bgScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, dVIEW_WIDTH, dVIEW_HEIGHT)];
    _bgScrollView.delegate = self;
    _bgScrollView.bouncesZoom = YES;
    _bgScrollView.maximumZoomScale = 5; // 最大放大倍数
    _bgScrollView.minimumZoomScale = 1; // 最小缩小倍数
    _bgScrollView.multipleTouchEnabled = YES;
    _bgScrollView.scrollsToTop = NO;
    _bgScrollView.contentSize = CGSizeMake(self.bounds.size.width, self.bounds.size.height);
    _bgScrollView.userInteractionEnabled = YES;
    _bgScrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _bgScrollView.delaysContentTouches = NO;  //默认YES, 设置NO则无论手指移动的多么快，始终都会将触摸事件传递给内部控件；
    _bgScrollView.canCancelContentTouches = NO;
    _bgScrollView.alwaysBounceVertical = YES; //设置上下回弹
    _bgScrollView.showsVerticalScrollIndicator = NO;
    _bgScrollView.showsHorizontalScrollIndicator = NO;
    if (@available(iOS 11.0, *)) {
        _bgScrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    [self.contentView addSubview:_bgScrollView];
    
    // 图片视图
    _imageView = [UIImageView new];
    _imageView.userInteractionEnabled = YES;
    _imageView.contentMode = UIViewContentModeScaleAspectFit;
    [_bgScrollView addSubview:_imageView];
    
    // 给视图添加单击手势（单击退出图片浏览器）
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapAction:)];
    [self addGestureRecognizer:singleTap];
    
    // 给视图添加双击手势（双击放大或缩小图片）
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTapAction:)];
    doubleTap.numberOfTapsRequired = 2;
    [singleTap requireGestureRecognizerToFail:doubleTap]; // 设置手势依赖(即如果是双击时让单击失效)
    [self addGestureRecognizer:doubleTap];
    
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressAction:)];
    [self addGestureRecognizer:longPress];
    
}

#pragma mark -
#pragma mark - 设置数据
/// 设置图片数据
/// @param thumbnail 缩略图
/// @param imageUrl 原图地址
/// @param indexPath indexPath
- (void)setDataWithThumbnail:(UIImage *)thumbnail imageUrl:(NSString *)imageUrl indexPath:(NSIndexPath *)indexPath {
    self.imageView.image = thumbnail;
    self.indexPath = indexPath;
    
    // 加载URL图片， 加载成功后还需更新布局数据
    if (imageUrl != nil && imageUrl.length > 0) {
        [self.indicatorView startAnimating];
        [self.imageView sd_setImageWithURL:[NSURL URLWithString:imageUrl] completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
            [self.indicatorView stopAnimating];
            if (image) {
                [self updateLayout];
            }
        }];
    }
    
    // 更新布局数据
    [self updateLayout];
}


/// 设置数据后要更新布局数据
- (void)updateLayout {
    [self.bgScrollView setZoomScale:1.0 animated:NO];
    
    CGFloat imageW = self.imageView.image.size.width;
    CGFloat imageH = self.imageView.image.size.height;
    CGFloat height =  dVIEW_WIDTH * imageH / imageW;

    if (imageH / imageW > dVIEW_HEIGHT / dVIEW_WIDTH) {
        // 竖长图
        self.imageView.frame =CGRectMake(0, 0, dVIEW_WIDTH, height);
    } else {
        self.imageView.frame = CGRectMake(0, dVIEW_HEIGHT / 2 - height / 2, dVIEW_WIDTH, height);
    }
    
    self.bgScrollView.contentSize = CGSizeMake(dVIEW_WIDTH, height);
}

#pragma mark -
#pragma mark - 点击手势

/// 单击 退出图片浏览器
- (void)singleTapAction:(UITapGestureRecognizer *)tap {
    // 将事件传递给控制器
    if ([self.delegate respondsToSelector:@selector(dismissView:)]) {
        [self.delegate dismissView:self.indexPath];
    }
}

/// 双击 放大或缩小图片
- (void)doubleTapAction:(UITapGestureRecognizer *)tap {
    /*
     1、当前图片已放大时，将图片缩小到正常大小
     2、当前图片时正常大小时，将图片放大，以当前点击点为中心（当然，边界适应优先）
     */
    
    if (self.bgScrollView.zoomScale > 1.0) {
        // 恢复到正常大小
        [self.bgScrollView setZoomScale:1.0 animated:YES];
        return;
    }
    
    // 放大(倍数为scrollView设置的最大缩放倍数)
    CGPoint tapPoint= [tap locationInView:self.imageView];
    CGFloat maximumZoomScale = self.bgScrollView.maximumZoomScale;
    CGFloat width = self.frame.size.width / maximumZoomScale;
    CGFloat height = self.frame.size.height / maximumZoomScale;
    CGRect zoomRect = CGRectMake(tapPoint.x - width / 2, tapPoint.y - height / 2, width, height);
    [self.bgScrollView zoomToRect:zoomRect animated:YES];
}

/// 长按事件
- (void)longPressAction:(UILongPressGestureRecognizer *)longPress {
    if (self.delegate && [self.delegate respondsToSelector:@selector(longPressImage:)]) {
        [self.delegate longPressImage:self.imageView.image];
    }
}

#pragma mark -
#pragma mark - UIScrollViewDelegate
// 返回需要缩放的视图控件 缩放过程中
- (nullable UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.imageView;
}

//缩放中
- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    // 延触摸中心点缩放
    CGSize size = scrollView.frame.size;
    CGSize contentSize = scrollView.contentSize;
    CGFloat offsetX = (size.width > contentSize.width) ? (size.width - contentSize.width) * 0.5 : 0.0;
    CGFloat offsetY = (size.height > contentSize.height) ? (size.height - contentSize.height) * 0.5 : 0.0;
    self.imageView.center = CGPointMake(contentSize.width * 0.5 + offsetX, contentSize.height * 0.5 + offsetY);
}

/// 开始拖动时记录手指个数
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    self.bgScrollView.clipsToBounds = NO;
    self.touchFingerNumber = [scrollView panGestureRecognizer].numberOfTouches;
}

// 拖动中
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {

    UIPanGestureRecognizer *pan = scrollView.panGestureRecognizer;
    
    // 注意：这里需要转换到cell或者controller.view上的坐标点(如果取self.bgScrollView会导致计算偏差)
    CGPoint point = [pan translationInView:self.superview];
    
    // 只处理单根手指向下拖动时的行为
    if (scrollView.contentOffset.y < 0 && self.touchFingerNumber == 1) {
        [self changedContentOffset:point];
    }
}

// 拖动结束时触发
- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
    CGFloat contentOffsetY = scrollView.contentOffset.y;
    
    if ((contentOffsetY < 0 && self.touchFingerNumber == 1) && (velocity.y < 0 && fabs(velocity.y) > fabs(velocity.x)) && fabs(contentOffsetY) > 100) {
        // 如果是向下滑动才触发消失的操作。
        NSLog(@"向下拖动达到退出浏览器的条件");
        if ([self.delegate respondsToSelector:@selector(dismissView:)]) {
            [self.delegate dismissView:self.indexPath];
        }
    } else {
        [self changedContentOffset:CGPointZero];
    }
    self.touchFingerNumber = 0;
    self.bgScrollView.clipsToBounds = YES;
}

- (void)changedContentOffset:(CGPoint)point {
    CGPoint center = CGPointMake(dVIEW_WIDTH / 2, dVIEW_HEIGHT / 2);
    CGFloat scale = 1 - (point.y / dVIEW_HEIGHT);
    scale = scale < 0 ? 0 : scale;
    scale = scale > 1 ? 1 : scale;
    self.bgScrollView.transform = CGAffineTransformMakeScale(scale, scale);
    self.bgScrollView.center = CGPointMake(center.x + point.x * scale, center.y + point.y);
    
    if ([self.delegate respondsToSelector:@selector(imageViewTouchMoveChangeAlpha:)]) {
        [self.delegate imageViewTouchMoveChangeAlpha:scale];
    }
}

@end
