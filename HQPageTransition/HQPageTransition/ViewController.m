//
//  ViewController.m
//  HQPageTransition
//
//  Created by huangqun on 2020/8/27.
//  Copyright © 2020 huangqun. All rights reserved.
//

#import "ViewController.h"
#import "MDDetailListViewController.h"
#import "MDPictureBrowserViewController.h"

#import "MDTransitionManager.h"
#import "MDZoomTransiton.h"
#import "MDPictureBrowserTransition.h"
#import "MDTransitionProtocol.h"

#import "UIViewController+MDTransition.h"
#import "MDPercentDrivenInteractiveTransition.h"

#import "UIImageView+WebCache.h"


@interface ViewController () <UICollectionViewDelegate, UICollectionViewDataSource, MDTransitionProtocol>

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) UICollectionViewCell *selectedCell;

@property (nonatomic, strong) MDPercentDrivenInteractiveTransition *percentInteractive;

@property (nonatomic, assign) NSInteger tagPictureIndex;    /**<  目标图片的索引（用于记录页面转场时动效需要落在哪张图片上）  */

@property (nonatomic, strong) NSArray *imageUrlList;
@property (nonatomic, strong) NSMutableArray *imageList;
@property (nonatomic, strong) NSMutableDictionary *imageDic;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    UICollectionViewFlowLayout *flowLayout = [UICollectionViewFlowLayout new];
    flowLayout.minimumLineSpacing = 10;
    flowLayout.minimumInteritemSpacing = 5;
    flowLayout.itemSize = CGSizeMake(self.view.frame.size.width / 2 - 10, self.view.frame.size.width / 2 - 10);
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height-64) collectionViewLayout:flowLayout];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.backgroundColor = UIColor.whiteColor;
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"cell"];
    [self.view addSubview:self.collectionView];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    
}

- (NSArray *)imageUrlList {
    if (_imageUrlList == nil) {
        _imageUrlList  = @[
            // 第一部分的数据
            @"https://ss1.bdstatic.com/70cFuXSh_Q1YnxGkpoWK1HF6hhy/it/u=3585337127,1473387508&fm=26&gp=0.jpg",
            @"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1601287250746&di=ed2bd5a9e50f33e0da59b77b89582b96&imgtype=0&src=http%3A%2F%2F5b0988e595225.cdn.sohucs.com%2Fimages%2F20190202%2F6d82c177b06f4fd6862bb8e0f5e708a6.gif",
            @"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1601274648386&di=7a056838001da5654cd69e11c928730d&imgtype=0&src=http%3A%2F%2Fcdn.duitang.com%2Fuploads%2Fitem%2F201501%2F05%2F20150105133334_vxQ8z.jpeg",
            @"https://ss0.bdstatic.com/70cFvHSh_Q1YnxGkpoWK1HF6hhy/it/u=3364791114,3601433002&fm=16&gp=0.jpg",
            @"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1601275130637&di=621683d32125ea96542be9ebf8712bb6&imgtype=0&src=http%3A%2F%2F5b0988e595225.cdn.sohucs.com%2Fimages%2F20190914%2Fbbf421ca4ebc4f288cd4e86bf7fe6462.jpeg",
            @"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1601286378815&di=a22eb65c66c2c8d2e8beef82661deb28&imgtype=0&src=http%3A%2F%2F5b0988e595225.cdn.sohucs.com%2Fimages%2F20180510%2F3fe2a43d31034aeca4593aec8959aed6.jpeg",
            
            // 第二部分的数据
            @"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1601274759652&di=a11d0332af43aa01462919d662b32ba3&imgtype=0&src=http%3A%2F%2F5b0988e595225.cdn.sohucs.com%2Fimages%2F20171117%2F6ddc173fc5e846f09f8a400f3284b2b4.jpeg",
            @"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1601274702431&di=71fabe2283c4546d1c36cb8991a1ca8e&imgtype=0&src=http%3A%2F%2Fstatic.cntonan.com%2Fuploadfile%2F2020%2F0317%2F202003171202330fnmwcmdsog.jpg",
            @"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1601288188242&di=aa79a02fdb30221b51f91e6fce1ef5b2&imgtype=0&src=http%3A%2F%2F5b0988e595225.cdn.sohucs.com%2Fq_70%2Cc_zoom%2Cw_640%2Fimages%2F20190112%2F9aff90a2111b49aea4e732a4e54dc341.gif",
            @"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1601288141654&di=9dcedc67dc4a418e666c46b0032154b5&imgtype=0&src=http%3A%2F%2Fphotocdn.sohu.com%2F20150805%2Fmp25877709_1438754591765_5.gif",
            @"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1601288063757&di=59b93d38dacf9b0ce1fc6406a2e780ac&imgtype=0&src=http%3A%2F%2Fp4.ssl.cdn.btime.com%2Ft014144600b04c90949.jpg",
            @"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1601274648386&di=7a056838001da5654cd69e11c928730d&imgtype=0&src=http%3A%2F%2Fcdn.duitang.com%2Fuploads%2Fitem%2F201501%2F05%2F20150105133334_vxQ8z.jpeg",
            @"https://ss1.bdstatic.com/70cFuXSh_Q1YnxGkpoWK1HF6hhy/it/u=3585337127,1473387508&fm=26&gp=0.jpg",
        ];
    }
    return  _imageUrlList;
}

- (NSMutableArray *)imageList {
    if (_imageList == nil) {
        _imageList = @[].mutableCopy;
    }
    return _imageList;
}

- (NSMutableDictionary *)imageDic {
    if (_imageDic == nil) {
        _imageDic = @{}.mutableCopy;
    }
    return _imageDic;
}

#pragma mark -
#pragma mark - UICollectionViewDataSource / UICollectionViewDelegate
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.imageUrlList.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    
    [cell.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"image"]];
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    imageView.clipsToBounds = YES;
    imageView.frame = cell.bounds;
    [cell addSubview:imageView];
    NSURL *url = [NSURL URLWithString:self.imageUrlList[indexPath.row]];
    
    NSString *key = [NSString stringWithFormat:@"%ld", (long)indexPath.row];
    if (imageView.image) {
        self.imageDic[key] = imageView.image;
    }
    [imageView sd_setImageWithURL:url completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
        if (image) {
            self.imageDic[key] = image;
        }
        
        if (image && ![self.imageList containsObject:image]) {
            [self.imageList addObject:image];
        }
    }];
    
    UILabel *label = [UILabel new];
    label.text = indexPath.row < 6 ? @"Present\n图到图转场" : @"Push\n图到页面转场";
    label.textColor = UIColor.whiteColor;
    label.font = [UIFont boldSystemFontOfSize:14];
    label.textAlignment = NSTextAlignmentCenter;
    label.numberOfLines = 0;
    label.frame = cell.bounds;
    [cell addSubview:label];
    
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row < 6) {
        CGFloat width = (self.view.frame.size.width - 10*3) / 3;
        return CGSizeMake(width, width + 10);
    }
    
    return CGSizeMake(self.view.frame.size.width / 2 - 15, self.view.frame.size.width / 2 + 40);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(0, 10, 0, 10);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
    self.selectedCell = cell;
    
    if (indexPath.row < 6) {
        MDPictureBrowserViewController *controller = [[MDPictureBrowserViewController alloc] initWithThumbnails:[self.imageList subarrayWithRange:NSMakeRange(0, 6)] imageUrls:[self.imageUrlList subarrayWithRange:NSMakeRange(0, 6)] index:indexPath.row];
        self.tagPictureIndex = indexPath.row;
        controller.pictureIndexChange = ^(NSInteger index) {
            self.tagPictureIndex = index;
        };
        [self hq_persentViewController:controller presentType:MDPresentType_PictureZoom completion:nil];
        
        return;
    }
    
    NSString *key = [NSString stringWithFormat:@"%ld", (long)indexPath.row];
    MDDetailListViewController *controller = [[MDDetailListViewController alloc] initWithThumbnail:self.imageDic[key] index:indexPath.row - 6];
    self.tagPictureIndex = indexPath.row;
    controller.pictureIndexChange = ^(NSInteger index) {
        self.tagPictureIndex = index + 6;
    };
    [self.navigationController hq_pushViewController:controller pushType:MDPushType_Zoom];
}



#pragma mark -
#pragma mark - HQTransitionProtocol
/// 页面转场时需要读取的图片
/// @param isEnter YES为进入页面的动画，NO为离开页面的动画
- (UIView *_Nonnull)md_transitionAnimationView:(BOOL)isEnter {
    // 该方法取视图有一个问题就是如果对应tagPictureIndex索引的cell并不在当前屏幕上展示时会出问题
//    UICollectionViewCell *cell = [self.collectionView.visibleCells objectAtIndex:self.tagPictureIndex];
    
    __block UIView *obj = self.selectedCell;
    // 从当前视图上可见的cell的indexPath中查找有没有和tagPictureIndex匹配的，如果有就返回对应的视图，如果没有就返回点击最开始点击的转场视图
    [self.collectionView.indexPathsForVisibleItems enumerateObjectsUsingBlock:^(NSIndexPath * _Nonnull indexPath, NSUInteger idx, BOOL * _Nonnull stop) {
        if (indexPath.row == self.tagPictureIndex) {
            obj = [self.collectionView cellForItemAtIndexPath:indexPath];
            *stop = YES;
        }
    }];
    
    if (self.tagPictureIndex > 5) {
        // 直接返回cell
        return obj;
    }
    
    // 查找cell上的图片
    [obj.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull subView, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([subView isKindOfClass:[UIImageView class]]) {
            obj = subView;
        }
    }];
    
    return obj;
}


@end
