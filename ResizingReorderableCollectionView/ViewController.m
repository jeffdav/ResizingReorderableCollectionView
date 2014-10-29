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
@property (nonatomic, assign) CGSize originalItemSize;

@end

@implementation ViewController

static const CGFloat kShrunkScale = 0.4;

static const BOOL kUpdateScaleByChangingExistingCollectionViewLayout = NO;
static const BOOL kUpdateScaleByCreatingNewCollectionViewLayout = NO;

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
    self.originalItemSize = reorderableLayout.itemSize;

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
    if (self.scale == kShrunkScale) {
        [self restore];
    } else {
        [self shrink];
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
    self.scale = kShrunkScale;
}

- (void)restore
{
    self.scale = 1;
}

- (void)setScale:(CGFloat)scale
{
    if (kUpdateScaleByChangingExistingCollectionViewLayout) {
        [self updateScaleByChangingExistingCollectionViewLayout:scale];
    } else if (kUpdateScaleByCreatingNewCollectionViewLayout) {
        [self updateScaleByCreatingNewCollectionViewLayout:scale];
    } else {
        [self updateScaleUsingTransform:scale];
    }
}

- (void)updateScaleUsingTransform:(CGFloat)scale
{
    const CGFloat oldScale = self.scale;

    _scale = scale;

    const CGPoint center = self.collectionView.center;
    const BOOL isZoomingIn = scale >= oldScale;

    [UIView animateWithDuration:0.25 animations:^{
        self.collectionView.transform = CGAffineTransformMakeScale(scale, scale);

        CGRect bounds = self.collectionView.bounds;
        if (isZoomingIn) {
            bounds.size.width = self.originalFrame.size.width / oldScale;
        } else {
            bounds.size.width = self.originalFrame.size.width / scale;
        }

        self.collectionView.bounds = bounds;
        self.collectionView.center = center;

        [self.collectionViewLayout invalidateLayoutWithContext:[self.collectionViewLayout invalidationContextForBoundsChange:bounds]];
    } completion:^(BOOL finished) {
        if (isZoomingIn) {
            CGRect bounds = self.collectionView.bounds;
            bounds.size.width = self.originalFrame.size.width * scale;
            self.collectionView.bounds = bounds;

            NSIndexPath *indexPath = [[self.collectionView indexPathsForSelectedItems] firstObject];
            [self.collectionView selectItemAtIndexPath:indexPath animated:NO scrollPosition:UICollectionViewScrollPositionCenteredHorizontally];
        }
    }];
}

// This method mostly works, but the animations are janky.
- (void)updateScaleByChangingExistingCollectionViewLayout:(CGFloat)scale
{
    _scale = scale;

    LXReorderableCollectionViewFlowLayout *collectionViewLayout = (id)self.collectionViewLayout;

    [self.collectionView performBatchUpdates:^{
        collectionViewLayout.itemSize = CGSizeMake(self.originalItemSize.width * scale, self.originalItemSize.height * scale);
    } completion:nil];
}

// This method doesn't work well due to the fact that LXReorderableCollectionViewFlowLayout has internal state that can't easily be copied to the new layout.
- (void)updateScaleByCreatingNewCollectionViewLayout:(CGFloat)scale
{
    _scale = scale;

    LXReorderableCollectionViewFlowLayout *originalLayout = (id)self.collectionViewLayout;

    LXReorderableCollectionViewFlowLayout *reorderableLayout = [[LXReorderableCollectionViewFlowLayout alloc] init];

    reorderableLayout.itemSize = CGSizeMake(self.originalItemSize.width * scale, self.originalItemSize.height * scale);
    reorderableLayout.scrollDirection = originalLayout.scrollDirection;
    reorderableLayout.headerReferenceSize = originalLayout.headerReferenceSize;
    reorderableLayout.footerReferenceSize = originalLayout.footerReferenceSize;
    reorderableLayout.minimumInteritemSpacing = originalLayout.minimumInteritemSpacing;
    reorderableLayout.minimumLineSpacing = originalLayout.minimumLineSpacing;
    reorderableLayout.sectionInset = originalLayout.sectionInset;
    reorderableLayout.scrollingSpeed = originalLayout.scrollingSpeed;
    reorderableLayout.scrollingTriggerEdgeInsets = originalLayout.scrollingTriggerEdgeInsets;

    [self.collectionView setCollectionViewLayout:reorderableLayout animated:YES];
}

@end
