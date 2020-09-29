//
//  HQPictureBrowserViewController.m
//  HQPageTransition
//
//  Created by huangqun on 2020/9/23.
//  Copyright © 2020 huangqun. All rights reserved.
//

#import "HQPictureBrowserViewController.h"
#import "HQTransitionProtocol.h"

@interface HQPictureBrowserViewController ()

#define cellIdentifier  @"collectionViewCell"

<UICollectionViewDelegate, UICollectionViewDataSource, HQTransitionProtocol, UIScrollViewDelegate>

@property (nonatomic, strong) UICollectionView *collectionView;

// 记录当前播放的cell
@property (nonatomic, strong) UICollectionViewCell *recodeCell;

@property (nonatomic, assign) NSInteger dataCount;

@end

@implementation HQPictureBrowserViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.dataCount = -1;
    
    UICollectionViewFlowLayout *flowLayout = [UICollectionViewFlowLayout new];
    flowLayout.minimumLineSpacing = 0;
    flowLayout.itemSize = CGSizeMake(self.view.frame.size.width, self.view.frame.size.height-64);
    flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height-64) collectionViewLayout:flowLayout];
    self.collectionView.backgroundColor = UIColor.blackColor;
    self.collectionView.pagingEnabled = YES;
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:cellIdentifier];
    [self.view addSubview:self.collectionView];
    
    // 直接显示到指定的位置
    [self.collectionView layoutIfNeeded];
    [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:self.dataCount > 0 ? self.index : 0 inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredVertically animated:NO];
    
//    // 自动滚动下一条播放
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        self.index++;
//        [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:self.index inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredVertically animated:YES];
//    });
    
    // 延后更新数据
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.dataCount = MAX(10, self.index);
        [self.collectionView reloadData];
    });
}



#pragma mark
#pragma mark - UIScrollViewDelegate

// 自动滚动结束时,即调用scrollToItemAtIndexPath:atScrollPosition:animated并且animated为YES时
- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    if (scrollView.tag == 100) {
        return;
    }
    [self scrollViewDidEnd:scrollView];
}

// 手指拖动引起的滚动结束时
-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (scrollView.tag == 100) {
        return;
    }
    [self scrollViewDidEnd:scrollView];
}

// 滚动结束时(不管哪种情况触发的滚动，结束后都调这个方法统一处理)
- (void)scrollViewDidEnd:(UIScrollView *)scrollView {
    if (scrollView.tag == 100) {
        return;
    }
    NSIndexPath *indexpath = [self.collectionView indexPathForItemAtPoint:scrollView.contentOffset];
    UICollectionViewCell *cell = (UICollectionViewCell *)[self.collectionView cellForItemAtIndexPath:indexpath];
    
    // 列表没有翻页时直接返回
    if (self.recodeCell == cell) {
        return;
    }
    
    // 对上一次记录的cell做操作(比如停止播放)
    self.recodeCell.backgroundColor = UIColor.purpleColor;
    
    // 对这一次要展示的cell做操作(比如开始播放)
    cell.backgroundColor = UIColor.redColor;
    
    // 更加当前cell的记录
    self.recodeCell = cell;
    self.index++;
}

//返回需要缩放的视图控件 缩放过程中
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    if (scrollView.tag != 100) {
        return nil;
    }
    UIImageView *imageView;
    for (UIView *subView in scrollView.subviews) {
        if ([subView isKindOfClass:[UIImageView class]]) {
            imageView = (UIImageView *)subView;
        }
    }
    return imageView;
}

//开始缩放
- (void)scrollViewWillBeginZooming:(UIScrollView *)scrollView withView:(UIView *)view{
    NSLog(@"开始缩放");
}
//结束缩放
- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale{
    NSLog(@"结束缩放");
}

//缩放中
- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    if (scrollView.tag != 100) {
        return;
    }
    // 延中心点缩放
//    CGFloat imageScaleWidth = scrollView.zoomScale * self.imageNormalWidth;
//    CGFloat imageScaleHeight = scrollView.zoomScale * self.imageNormalHeight;
//
//    CGFloat imageX = 0;
//    CGFloat imageY = 0;
//     imageX = floorf((self.frame.size.width - imageScaleWidth) / 2.0);
//     imageY = floorf((self.frame.size.height - imageScaleHeight) / 2.0);
//     self.imageView.frame = CGRectMake(imageX, imageY, imageScaleWidth, imageScaleHeight);
    
}

#pragma mark -
#pragma mark - UICollectionViewDataSource / UICollectionViewDelegate
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return MAX(1, self.dataCount);
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    
    [cell.contentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    // 如果有长图，可使用scrollView（宽固定，长不固定）
    UIScrollView *bgScrollView = [UIScrollView new];
    bgScrollView.tag = 100;
    bgScrollView.delegate = self;
    bgScrollView.backgroundColor = UIColor.grayColor;
    bgScrollView.frame = cell.contentView.frame;
    [cell.contentView addSubview:bgScrollView];
    
    // 设置缩放
    bgScrollView.maximumZoomScale = 4.0;
    bgScrollView.minimumZoomScale = 1.0;
    
    UIImage *image = [UIImage imageNamed:@"image"];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    imageView.backgroundColor = UIColor.clearColor;
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    imageView.userInteractionEnabled = YES;
    imageView.frame = cell.contentView.frame;
    [bgScrollView addSubview:imageView];

    UILabel *label = [[UILabel alloc] init];
    label.frame = CGRectMake(20, imageView.frame.size.height - 100, 100, 20);
    label.text = [NSString stringWithFormat:@"第 %ld 张图", self.dataCount > 0 ? (long)indexPath.row + 1 : self.index];
    label.font = [UIFont boldSystemFontOfSize:20];
    label.textColor = UIColor.whiteColor;
    [bgScrollView addSubview:label];
    
    
    bgScrollView.contentSize = image.size;

    // 首次进入页面时，将当前要播放的cell记录下来
    if (self.index == indexPath.row && self.recodeCell == nil) { // 如果没有自动滚动播放
        self.recodeCell = cell;
    }
    
    return cell;
}


#pragma mark -
#pragma mark - HQTransitionProtocol
- (UIView *_Nonnull)hq_animationViewForMotionTransition {
    return self.collectionView;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    NSLog(@"xxxxxxxxxxxxxxxxxxxxxxxxx");
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    NSLog(@"yyyyyyyyyyyyyyyyyyyyyyyyy");
}

@end
