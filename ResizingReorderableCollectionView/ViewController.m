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

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.data = [NSMutableArray array];

    for (int i = 0; i < [self collectionView:self.collectionView numberOfItemsInSection:0]; ++i) {
        [self.data addObject:@(i)];
    }

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

    reorderableLayout.scrollingSpeed = 2400;
    reorderableLayout.scrollingTriggerEdgeInsets = UIEdgeInsetsMake(100, 100, 100, 100);

    self.scale = 0.4;
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
    cell.numberLabel.text = [NSString stringWithFormat:@"%@", self.data[indexPath.item]];
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

- (void)collectionView:(UICollectionView *)collectionView itemAtIndexPath:(NSIndexPath *)fromIndexPath willMoveToIndexPath:(NSIndexPath *)toIndexPath
{
    NSNumber *number = self.data[fromIndexPath.item];
    [self.data removeObjectAtIndex:fromIndexPath.item];
    [self.data insertObject:number atIndex:toIndexPath.item];
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
    const CGPoint center = self.collectionView.center;

    [UIView animateWithDuration:0.25 animations:^{
        self.collectionView.transform = CGAffineTransformIdentity;
        self.collectionView.frame = self.originalFrame;
        self.collectionView.center = center;
    }];
}

@end
