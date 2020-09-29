//
//  MDPictureBrowserViewLayout.m
//  HQPageTransition
//
//  Created by huangqun on 2020/9/25.
//  Copyright © 2020 huangqun. All rights reserved.
//

#import "MDPictureBrowserViewLayout.h"

@implementation MDPictureBrowserViewLayout

- (instancetype)init {
    self = [super init];
    if (self) {
        self.minimumLineSpacing = 0;
        self.minimumInteritemSpacing = 0;
        self.sectionInset = UIEdgeInsetsZero;
        self.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        _pageSpacing = 10;
    }
    return self;
}
 
- (void)prepareLayout {
    [super prepareLayout];
    self.itemSize = self.collectionView.bounds.size;
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds {
    return YES;
}

- (NSArray<UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect {
    NSArray<UICollectionViewLayoutAttributes *> *layoutAttributes = [[NSArray alloc] initWithArray:[super layoutAttributesForElementsInRect:rect] copyItems:YES];
    CGFloat halfWidth = self.collectionView.bounds.size.width / 2.0;
    CGFloat contentOffsetCenterX = self.collectionView.contentOffset.x + halfWidth;
    [layoutAttributes enumerateObjectsUsingBlock:^(UICollectionViewLayoutAttributes * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        CGFloat centerX = obj.center.x + (obj.center.x - contentOffsetCenterX) / halfWidth * self.pageSpacing / 2;
        CGFloat centerY = obj.center.y;
        obj.center = CGPointMake(centerX, centerY);
    }];
    return layoutAttributes;
}

@end
