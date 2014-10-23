//
//  ViewController.m
//  ResizingReorderableCollectionView
//
//  Created by Jeffrey Davis on 10/23/14.
//  Copyright (c) 2014 Appbindery LLC. All rights reserved.
//

#import "ViewController.h"

#import "CellOfLuvCollectionViewCell.h"

@interface ViewController () <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (nonatomic, assign) CGFloat scale;
@property (nonatomic, assign) CGRect originalFrame;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

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
    const CGFloat scale = self.scale;
    const CGPoint center = collectionView.center;

    [UIView animateWithDuration:0.25 animations:^{
        if (CGAffineTransformIsIdentity(collectionView.transform)) {
            CGRect frame = collectionView.frame;
            frame.size.width *= 1 / scale;
            collectionView.frame = frame;
            collectionView.center = center;
            collectionView.transform = CGAffineTransformMakeScale(scale, scale);
        } else {
            collectionView.transform = CGAffineTransformIdentity;
            collectionView.frame = self.originalFrame;
            collectionView.center = center;
        }
    }];

    [collectionView selectItemAtIndexPath:indexPath animated:YES scrollPosition:UICollectionViewScrollPositionCenteredHorizontally];
}

@end
