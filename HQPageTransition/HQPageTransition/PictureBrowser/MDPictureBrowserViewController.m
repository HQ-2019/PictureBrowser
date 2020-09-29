//
//  MDPictureBrowserViewController.m
//  HQPageTransition
//
//  Created by huangqun on 2020/9/23.
//  Copyright © 2020 huangqun. All rights reserved.
//

#import "MDPictureBrowserViewController.h"

#import "MDPictureBrowserCell.h"
#import "MDPictureBrowserViewLayout.h"

#import "MDTransitionProtocol.h"

#import <Photos/Photos.h>

@interface MDPictureBrowserViewController () <UICollectionViewDelegate, UICollectionViewDataSource, MDTransitionProtocol, UIScrollViewDelegate, MDPictureBrowserCellDelegate>

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) UILabel *pageLabel;

// 记录当前播放的cell
@property (nonatomic, strong) UICollectionViewCell *recodeCell;

@property (nonatomic, assign) NSInteger index;                              /**<  当前要显示的图片的索引  */
@property (nonatomic, copy) NSArray<UIImage *> *thumbnails;                 /**<  缩略图 列表 */
@property (nonatomic, copy) NSArray<NSString *> *imageUrls;                 /**<  原图地址列表  */

@end

@implementation MDPictureBrowserViewController

- (void)dealloc {
    NSLog(@"%@  %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    }
    return self;
}

/// 创建图片浏览器
/// @param thumbnails 缩略图（缩略图和原图链接要一一对应）
/// @param imageUrls 原图链接
/// @param index 当前需要展示的图片的索引
- (instancetype)initWithThumbnails:(NSArray<UIImage *> *)thumbnails imageUrls:(nullable NSArray<NSString *> *)imageUrls index:(NSInteger)index {
    self = [super init];
    if (self) {
        self.index = index;
        self.thumbnails = thumbnails;
        self.imageUrls = imageUrls;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:1.0];
    
    
    MDPictureBrowserViewLayout *flowLayout = [MDPictureBrowserViewLayout new];
    
    self.collectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:flowLayout];
    self.collectionView.backgroundColor = UIColor.clearColor;
    self.collectionView.pagingEnabled = YES;
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.decelerationRate = UIScrollViewDecelerationRateFast;
    
    Class cell = [MDPictureBrowserCell class];
    [self.collectionView registerClass:cell forCellWithReuseIdentifier:NSStringFromClass(cell)];
    [self.view addSubview:self.collectionView];
    
    
    // 直接显示到指定的位置
    [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:self.index inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:NO];
    
    // 设置页码
    self.pageLabel = [[UILabel alloc] init];
    self.pageLabel.frame = CGRectMake((self.view.bounds.size.width - 150) / 2, 100, 150, 20);
    self.pageLabel.textAlignment = NSTextAlignmentCenter;
    self.pageLabel.text = [NSString stringWithFormat:@"%ld / %ld", (long)self.index + 1, (long)self.thumbnails.count];
    self.pageLabel.font = [UIFont boldSystemFontOfSize:17];
    self.pageLabel.textColor = UIColor.whiteColor;
    [self.view addSubview:self.pageLabel];
    
//    // 自动滚动下一条播放
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        self.index++;
//        [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:self.index inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredVertically animated:YES];
//    });
}

#pragma mark
#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    // 计算当前页码
    CGFloat page = scrollView.contentOffset.x / scrollView.bounds.size.width;
    self.index = page;
    self.pageLabel.text = [NSString stringWithFormat:@"%ld / %ld", self.index + 1, self.thumbnails.count];
    
    if (self.pictureIndexChange) {
        self.pictureIndexChange(self.index);
    }
}

// 自动滚动结束时,即调用scrollToItemAtIndexPath:atScrollPosition:animated并且animated为YES时
- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    [self scrollViewDidEnd:scrollView];
}

// 手指拖动引起的滚动结束时
-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self scrollViewDidEnd:scrollView];
}

// 滚动结束时(不管哪种情况触发的滚动，结束后都调这个方法统一处理)
- (void)scrollViewDidEnd:(UIScrollView *)scrollView {
    NSLog(@"collectionView 滚动了");
    NSIndexPath *indexpath = [self.collectionView indexPathForItemAtPoint:scrollView.contentOffset];
    UICollectionViewCell *cell = (UICollectionViewCell *)[self.collectionView cellForItemAtIndexPath:indexpath];
    
    // 列表没有翻页时直接返回
    if (self.recodeCell == cell) {
        return;
    }
    
    // 对上一次记录的cell做操作(比如停止播放)
//    self.recodeCell.backgroundColor = UIColor.purpleColor;
    
    // 对这一次要展示的cell做操作(比如开始播放)
//    cell.backgroundColor = UIColor.redColor;
    
    // 更加当前cell的记录
    self.recodeCell = cell;
}

#pragma mark -
#pragma mark - UICollectionViewDataSource / UICollectionViewDelegate
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.thumbnails.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    MDPictureBrowserCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([MDPictureBrowserCell class]) forIndexPath:indexPath];

    cell.delegate = self;
    NSString *url = nil;
    if (self.imageUrls.count && self.imageUrls.count > indexPath.row) {
        url = self.imageUrls[indexPath.row];
    }
    [cell setDataWithThumbnail:self.thumbnails[indexPath.row] imageUrl:url indexPath:indexPath];

    // 首次进入页面时，将当前要播放的cell记录下来
    if (self.index == indexPath.row && self.recodeCell == nil) { // 如果没有自动滚动播放
        self.recodeCell = cell;
    }
    return cell;
}

#pragma mark -
#pragma mark - HQPictureBrowserCellDelegate

- (void)imageViewTouchMoveChangeAlpha:(CGFloat)alpha {
    self.view.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:alpha];
}

- (void)dismissView:(NSIndexPath *)indexPath {
    if (self.navigationController.viewControllers > 0) {
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)longPressImage:(UIImage *)image {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    [alert addAction:cancel];
    UIAlertAction *alertT = [UIAlertAction actionWithTitle:@"保存图片到相册" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self canOpenAlbum:^(BOOL canOpen) {
            if (canOpen) {
                [self saveImage:image];
            } else {
                // 提示用户去授权相册访问
                dispatch_async(dispatch_get_main_queue(), ^{
                    UIAlertController *alerSetting = [UIAlertController alertControllerWithTitle:nil message:@"保存图片需要访问您的相册，请前往 \"设置 -> 照片\"进行设置" preferredStyle:UIAlertControllerStyleAlert];
                    UIAlertAction *go = [UIAlertAction actionWithTitle:@"前往设置" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                        [self openSetting];
                    }];
                    [alerSetting addAction:go];
                    [alerSetting addAction:cancel];
                    [self presentViewController:alerSetting animated:YES completion:nil];
                });
            }
        }];
    }];

    [alert addAction:alertT];
    [self presentViewController:alert animated:YES completion:nil];
}


#pragma mark -
#pragma mark - HQTransitionProtocol

/// 页面转场时需要读取的图片
/// @param isEnter YES为进入页面的动画，NO为离开页面的动画
- (UIView *_Nonnull)md_transitionAnimationView:(BOOL)isEnter {
    CGFloat page = self.collectionView.contentOffset.x / self.collectionView.bounds.size.width;
    MDPictureBrowserCell *cell = (MDPictureBrowserCell *)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:page inSection:0]];
    if (cell == nil) {
        // 如果没能获取到cell，就将当前列表视图返回
        return self.collectionView;
    }
    
    return cell.imageView ?: self.collectionView;
}

/// 页面交互转场过程中对一些视图的隐藏设置
- (void)md_transitionHideSubView:(BOOL)hide {
    [UIView animateWithDuration:0.3 animations:^{
        self.collectionView.hidden = hide;
        self.pageLabel.hidden = hide;
    }];
}

#pragma mark -
#pragma mark - 保存图片到相册
- (void)saveImage:(UIImage *)image {
    UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), (__bridge void *)self);
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    NSLog(@"image = %@, error = %@, contextInfo = %@", image, error, contextInfo);
    if (error) {
        // 保存失败
        return;
    }
    
    // 保存成功
}

#pragma mark -
#pragma mark - 查询相册授权情况

/// 是否开启相册服务
- (void)canOpenAlbum:(void(^)(BOOL canOpen))callback {
    // [PHPhotoLibrary authorizationStatus]判断在iOS11之后是异步执行，所以会出现用户拒绝后返回的却是PHAuthorizationStatusNotDetermined的情况
    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
        if (callback) {
            // 只有没有明确被拒绝访问的情况，都默认可以打开相册
            callback(status != PHAuthorizationStatusDenied && status != PHAuthorizationStatusRestricted);
        }
    }];
}

/// 打开系统设置
- (void)openSetting {
    // 无权限 引导去开启
    NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
    if ([[UIApplication sharedApplication] canOpenURL:url]) {
        [[UIApplication sharedApplication] openURL:url];
    }
}

@end
