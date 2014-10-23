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

@interface ViewController () <UICollectionViewDataSource, LXReorderableCollectionViewDelegateFlowLayout>

@property (nonatomic, assign) CGFloat scale;
@property (nonatomic, assign) CGRect originalFrame;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    UICollectionView *collectionView = self.collectionView;
    UICollectionViewFlowLayout *originalLayout = (id)collectionView.collectionViewLayout;
    LXReorderableCollectionViewFlowLayout* reorderableLayout = [[LXReorderableCollectionViewFlowLayout alloc] init];

    reorderableLayout.itemSize = originalLayout.itemSize;
    reorderableLayout.scrollDirection = originalLayout.scrollDirection;
    reorderableLayout.headerReferenceSize = originalLayout.headerReferenceSize;
    reorderableLayout.footerReferenceSize = originalLayout.footerReferenceSize;
    reorderableLayout.minimumInteritemSpacing = originalLayout.minimumInteritemSpacing;
    reorderableLayout.minimumLineSpacing = originalLayout.minimumLineSpacing;
    reorderableLayout.sectionInset = originalLayout.sectionInset;
    collectionView.collectionViewLayout = reorderableLayout;

    self.scale = 0.5;
    self.originalFrame = self.collectionView.frame;
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
    cell.numberLabel.text = [NSString stringWithFormat:@"%@", @(indexPath.item)];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (CGAffineTransformIsIdentity(collectionView.transform)) {
        [self shrink];
    } else {
        [self restore];
    }

    [collectionView selectItemAtIndexPath:indexPath animated:YES scrollPosition:UICollectionViewScrollPositionCenteredHorizontally];
}

- (void)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout willBeginDraggingItemAtIndexPath:(NSIndexPath *)indexPath
{
    [self shrink];

    [collectionView selectItemAtIndexPath:indexPath animated:YES scrollPosition:UICollectionViewScrollPositionCenteredHorizontally];
}

- (void)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout didEndDraggingItemAtIndexPath:(NSIndexPath *)indexPath
{
    [self restore];

    [collectionView selectItemAtIndexPath:indexPath animated:YES scrollPosition:UICollectionViewScrollPositionCenteredHorizontally];
}

- (void)shrink
{
    const CGFloat scale = self.scale;
    const CGPoint center = self.collectionView.center;

    [UIView animateWithDuration:0.25 animations:^{
        CGRect frame = self.collectionView.frame;
        frame.size.width *= 1 / scale;
        self.collectionView.frame = frame;
        self.collectionView.center = center;
        self.collectionView.transform = CGAffineTransformMakeScale(scale, scale);
    }];
}

- (void)restore
{
    const CGFloat scale = self.scale;
    const CGPoint center = self.collectionView.center;

    [UIView animateWithDuration:0.25 animations:^{
        self.collectionView.transform = CGAffineTransformIdentity;
        self.collectionView.frame = self.originalFrame;
        self.collectionView.center = center;
    }];
}

@end
