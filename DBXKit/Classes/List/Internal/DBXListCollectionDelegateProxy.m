//
//  DBXListCollectionDelegateProxy.m
//  DBXKit
//
//  Created by 调包侠 on 2025/7/28.
//  Copyright © 2025 DBX. All rights reserved.
//

#import "DBXListCollectionDelegateProxy.h"

static BOOL isAdapterSelector(SEL sel) {
    return (
            // UIScrollViewDelegate
//            sel == @selector(scrollViewDidScroll:) ||
//            sel == @selector(scrollViewWillBeginDragging:) ||
//            sel == @selector(scrollViewDidEndDragging:willDecelerate:) ||
//            sel == @selector(scrollViewDidEndDecelerating:) ||
            // UICollectionViewDelegate
            sel == @selector(collectionView:willDisplayCell:forItemAtIndexPath:) ||
            sel == @selector(collectionView:didEndDisplayingCell:forItemAtIndexPath:) ||
            sel == @selector(collectionView:shouldSelectItemAtIndexPath:) ||
            sel == @selector(collectionView:didSelectItemAtIndexPath:) ||
            sel == @selector(collectionView:shouldDeselectItemAtIndexPath:) ||
            sel == @selector(collectionView:didDeselectItemAtIndexPath:) ||
            sel == @selector(collectionView:didHighlightItemAtIndexPath:) ||
            sel == @selector(collectionView:didUnhighlightItemAtIndexPath:) ||
//             UICollectionViewDelegateFlowLayout
            sel == @selector(collectionView:layout:sizeForItemAtIndexPath:) ||
            sel == @selector(collectionView:layout:insetForSectionAtIndex:) ||
            sel == @selector(collectionView:layout:minimumInteritemSpacingForSectionAtIndex:) ||
            sel == @selector(collectionView:layout:minimumLineSpacingForSectionAtIndex:) ||
            sel == @selector(collectionView:layout:referenceSizeForFooterInSection:) ||
            sel == @selector(collectionView:layout:referenceSizeForHeaderInSection:) //||

            // DBXListCollectionViewDelegateLayout
//            sel == @selector(collectionView:layout:customizedInitialLayoutAttributes:atIndexPath:) ||
//            sel == @selector(collectionView:layout:customizedFinalLayoutAttributes:atIndexPath:)
            );
}

@interface DBXListCollectionDelegateProxy () {
    __weak id _collectionViewTarget;
    __weak id _scrollViewTarget;
    __weak DBXListAdapter *_adapter;
}

@end

@implementation DBXListCollectionDelegateProxy

- (instancetype)initWithCollectionViewTarget:(nullable id<UICollectionViewDelegate>)collectionViewTarget scrollViewTarget:(nullable id<UIScrollViewDelegate>)scrollViewTarget listAdapter:(DBXListAdapter *)adapter
{
    if (self) {
        _collectionViewTarget = collectionViewTarget;
        _scrollViewTarget = scrollViewTarget;
        _adapter = adapter;
    }
    return self;
}

- (BOOL)respondsToSelector:(SEL)aSelector {
    return isAdapterSelector(aSelector) || [_collectionViewTarget respondsToSelector:aSelector] || [_scrollViewTarget respondsToSelector:aSelector];
}

- (id)forwardingTargetForSelector:(SEL)aSelector {
    if (isAdapterSelector(aSelector)) {
        return _adapter;
    }
    return [_scrollViewTarget respondsToSelector:aSelector] ? _scrollViewTarget : _collectionViewTarget;
}

- (void)forwardInvocation:(NSInvocation *)invocation {
    void *nullPointer = NULL;
    [invocation setReturnValue:&nullPointer];
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)selector {
    return [NSObject instanceMethodSignatureForSelector:@selector(init)];
}

@end
