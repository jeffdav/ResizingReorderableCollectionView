//
//  ViewController.m
//  ResizingReorderableCollectionView
//
//  Created by Jeffrey Davis on 10/23/14.
//  Copyright (c) 2014 Appbindery LLC. All rights reserved.
//

#import "ViewController.h"

#import <LXReorderableCollectionViewFlowLayout/LXReorderableCollectionViewFlowLayout.h>

#import "CellOfLuvCollectionViewCell.h"

@interface ViewController () <LXReorderableCollectionViewDataSource, LXReorderableCollectionViewDelegateFlowLayout>

@property (nonatomic, strong) NSMutableArray *data;
@property (nonatomic, strong) NSNumber *movingDatum;

@property (nonatomic, assign) CGFloat scale;
@property (nonatomic, assign) CGRect originalFrame;

@end

@implementation ViewController

static const CGFloat ShrunkScale = 0.4;

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.data = [NSMutableArray array];

    for (int i = 0; i < [self collectionView:self.collectionView numberOfItemsInSection:0]; ++i) {
        [self.data addObject:@(i)];
    }

    LXReorderableCollectionViewFlowLayout *reorderableLayout = (id)self.collectionViewLayout;
    reorderableLayout.minimumInteritemSpacing = CGFLOAT_MAX;
    reorderableLayout.scrollingSpeed = 2400;
    reorderableLayout.scrollingTriggerEdgeInsets = UIEdgeInsetsMake(100, 100, 100, 100);

    self.originalFrame = self.collectionView.frame;

    _scale = 1;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return 23;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CellOfLuvCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"CellOfLuv" forIndexPath:indexPath];
    cell.numberLabel.text = [NSString stringWithFormat:@"%@", self.data[indexPath.item]];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.scale == 1) {
        [self shrink];
    } else {
        [self restore];
    }

    [collectionView selectItemAtIndexPath:indexPath animated:YES scrollPosition:UICollectionViewScrollPositionCenteredHorizontally];
}

- (void)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout willBeginDraggingItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (collectionViewLayout == self.collectionViewLayout) {
        [self shrink];
        [collectionView selectItemAtIndexPath:indexPath animated:YES scrollPosition:UICollectionViewScrollPositionCenteredHorizontally];
    }
}

- (void)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout didEndDraggingItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (collectionViewLayout == self.collectionViewLayout) {
        [self restore];
        [collectionView selectItemAtIndexPath:indexPath animated:YES scrollPosition:UICollectionViewScrollPositionCenteredHorizontally];
    }
}

- (void)collectionView:(UICollectionView *)collectionView itemAtIndexPath:(NSIndexPath *)fromIndexPath willMoveToIndexPath:(NSIndexPath *)toIndexPath
{
    NSNumber *number = self.data[fromIndexPath.item];
    [self.data removeObjectAtIndex:fromIndexPath.item];
    [self.data insertObject:number atIndex:toIndexPath.item];
}

- (void)shrink
{
    self.scale = ShrunkScale;
}

- (void)restore
{
    self.scale = 1;
}

- (void)setScale:(CGFloat)scale
{
    _scale = scale;

    const CGPoint center = self.collectionView.center;

    [UIView animateWithDuration:0.25 animations:^{
        self.collectionView.transform = CGAffineTransformMakeScale(scale, scale);

        CGRect bounds = self.collectionView.bounds;
        bounds.size.width = self.originalFrame.size.width / scale;

        self.collectionView.bounds = bounds;
        self.collectionView.center = center;

    } completion:nil];
}

@end
