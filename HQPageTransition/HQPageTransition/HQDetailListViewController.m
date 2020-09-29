//
//  MDDetailListViewController.m
//  HQPageTransition
//
//  Created by huangqun on 2020/8/27.
//  Copyright © 2020 huangqun. All rights reserved.
//

#import "MDDetailListViewController.h"

#import "UIImageView+WebCache.h"

#import "MDTransitionProtocol.h"

#define cellIdentifier  @"collectionViewCell"

@interface MDDetailListViewController () <UICollectionViewDelegate, UICollectionViewDataSource, MDTransitionProtocol>

@property (nonatomic, strong) UICollectionView *collectionView;

@property (nonatomic, strong) UIImage *defaultImage;    /**<  进入页面时默认要展示的图片  */
@property (nonatomic, assign) NSInteger index;          /**<  当前要显示的图片的索引  */
@property (nonatomic, copy) NSArray *dataList;          /**<  数据列表  */

// 记录当前播放的cell
@property (nonatomic, strong) UICollectionViewCell *recodeCell;


@end

@implementation MDDetailListViewController

- (void)dealloc {
    NSLog(@"%@  %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
}

/// 初始化控制器
/// @param thumbnail 缩略图，进入控制器时默认展示的图片（获取以后会扩展更多其他展示的默认数据），然后等等网络加载数据后进行更新
/// @param index 前需要展示的图片的索引
- (instancetype)initWithThumbnail:(UIImage *)thumbnail index:(NSInteger)index {
    self = [super init];
    if (self) {
        self.defaultImage = thumbnail;
        self.index = index;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title =  [NSString stringWithFormat:@"第%ld页", (long)self.index + 1];
    
    UICollectionViewFlowLayout *flowLayout = [UICollectionViewFlowLayout new];
    flowLayout.minimumLineSpacing = 0;
    flowLayout.itemSize = CGSizeMake(self.view.frame.size.width, self.view.frame.size.height-64);
    flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
    
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height-64) collectionViewLayout:flowLayout];
    self.collectionView.backgroundColor = UIColor.blackColor;
    self.collectionView.pagingEnabled = YES;
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:cellIdentifier];
    [self.view addSubview:self.collectionView];
    
    
//    // 自动滚动下一条播放
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        self.index++;
//        [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:self.index inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredVertically animated:YES];
//    });
    
    
    UIActivityIndicatorView *activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    activityIndicatorView.center = CGPointMake((self.view.bounds.size.width - 20) / 2, 50);
//    activityIndicatorView.backgroundColor = UIColor.redColor;
    [self.view addSubview:activityIndicatorView];
    [activityIndicatorView startAnimating];
    
    // 模拟延后获取网络数据进行更新
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [activityIndicatorView stopAnimating];
        [activityIndicatorView removeFromSuperview];
        [self dataList];
        [self.collectionView reloadData];

        // 直接显示到指定的位置
        [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:self.index inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredVertically animated:NO];
    });
}


- (NSArray *)dataList {
    if (_dataList == nil) {
        _dataList  = @[
            @"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1601274759652&di=a11d0332af43aa01462919d662b32ba3&imgtype=0&src=http%3A%2F%2F5b0988e595225.cdn.sohucs.com%2Fimages%2F20171117%2F6ddc173fc5e846f09f8a400f3284b2b4.jpeg",
            @"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1601274702431&di=71fabe2283c4546d1c36cb8991a1ca8e&imgtype=0&src=http%3A%2F%2Fstatic.cntonan.com%2Fuploadfile%2F2020%2F0317%2F202003171202330fnmwcmdsog.jpg",
            @"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1601288188242&di=aa79a02fdb30221b51f91e6fce1ef5b2&imgtype=0&src=http%3A%2F%2F5b0988e595225.cdn.sohucs.com%2Fq_70%2Cc_zoom%2Cw_640%2Fimages%2F20190112%2F9aff90a2111b49aea4e732a4e54dc341.gif",
            @"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1601288141654&di=9dcedc67dc4a418e666c46b0032154b5&imgtype=0&src=http%3A%2F%2Fphotocdn.sohu.com%2F20150805%2Fmp25877709_1438754591765_5.gif",
            @"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1601288063757&di=59b93d38dacf9b0ce1fc6406a2e780ac&imgtype=0&src=http%3A%2F%2Fp4.ssl.cdn.btime.com%2Ft014144600b04c90949.jpg",
            @"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1601274648386&di=7a056838001da5654cd69e11c928730d&imgtype=0&src=http%3A%2F%2Fcdn.duitang.com%2Fuploads%2Fitem%2F201501%2F05%2F20150105133334_vxQ8z.jpeg",
            @"https://ss1.bdstatic.com/70cFuXSh_Q1YnxGkpoWK1HF6hhy/it/u=3585337127,1473387508&fm=26&gp=0.jpg",
        ];
    }
    return _dataList;
}


#pragma mark
#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    // 计算当前页码(当网络数据没有加载下来时，不用计算，因为只有一个图片展示)
    if (_dataList) {
        CGFloat page = scrollView.contentOffset.y / scrollView.bounds.size.height;
        self.index = page;
        self.title =  [NSString stringWithFormat:@"第%ld页", (long)self.index + 1];
        
        if (self.pictureIndexChange) {
            self.pictureIndexChange(self.index);
        }
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
    return MAX(1, _dataList.count);
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    
    [cell.contentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    UIImageView *imageView = [[UIImageView alloc] init];
    imageView.backgroundColor = UIColor.clearColor;
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    imageView.frame = cell.contentView.frame;
    imageView.image = self.defaultImage;
    [cell.contentView addSubview:imageView];
    if (_dataList != nil) {
        [imageView sd_setImageWithURL:[NSURL URLWithString:_dataList[indexPath.row]] completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
        }];
    }
    CGSize cellSize = cell.contentView.frame.size;
    
    UIView *view1 = [[UIView alloc] initWithFrame:CGRectMake(cellSize.width - 70, cellSize.height - 360, 50, 60)];
    view1.backgroundColor = [UIColor.redColor colorWithAlphaComponent:0.7];
    view1.layer.cornerRadius = 4;
    [cell.contentView addSubview:view1];
    
    UIView *view2 = [[UIView alloc] initWithFrame:CGRectMake(cellSize.width - 70, cellSize.height - 280, 50, 60)];
    view2.backgroundColor = [UIColor.yellowColor colorWithAlphaComponent:0.7];
    view2.layer.cornerRadius = 4;
    [cell.contentView addSubview:view2];
    
    UILabel *view3 = [[UILabel alloc] initWithFrame:CGRectMake(20, cellSize.height - 200, cellSize.width - 40, 150)];
    view3.text = @"bala bala bala bala bala bala bala bala bala bala bala bala bala bala";
    view3.numberOfLines = 0;
    view3.backgroundColor = [UIColor.whiteColor colorWithAlphaComponent:0.5];
    view3.layer.cornerRadius = 8;
    view3.layer.masksToBounds = YES;
    [cell.contentView addSubview:view3];
    
    // 首次进入页面时，将当前要播放的cell记录下来
    if (self.index == indexPath.row && self.recodeCell == nil) { // 如果没有自动滚动播放
        self.recodeCell = cell;
    }
    
    return cell;
}


#pragma mark -
#pragma mark - HQTransitionProtocol
- (UIView *_Nonnull)md_transitionAnimationView:(BOOL)isEnter {
    return self.view;
}

@end
