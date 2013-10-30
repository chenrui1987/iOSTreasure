//
//  ZJCustomLayout.m
//  CollectionsSample
//
//  Created by Zhu J on 10/23/13.
//  Copyright (c) 2013 Zhu J. All rights reserved.
//

#import "ZJCustomLayout.h"
#import "ZJCustomDefines.h"

#define INSET_TOP               (5)
#define INSET_LEFT              (5)
#define INSET_BOTTOM            (5)
#define INSET_RIGHT             (5)


#define CELL_WIDTH              (100)
#define CELL_HEIGHT             (50)
#define CELL_SEC_SPACE          (20)
#define CELL_ROW_SPACE          (10)



@implementation ZJCollectionViewLayoutAttributes

- (BOOL)isEqual:(id)object
{
    ZJCollectionViewLayoutAttributes *attribute = (ZJCollectionViewLayoutAttributes *)object;
    if ([self.children isEqualToArray:attribute.children])
    {
        return [super isEqual:object];
    }
    return NO;
}

@end


@interface ZJCustomLayout ()
{
    NSInteger numberOfColumn;//here in this Sample Column equals the section
}
@property (nonatomic) NSDictionary *layoutInformation;
@property (nonatomic) NSInteger maxNumRows;
@property (nonatomic) UIEdgeInsets insets;


@end


@implementation ZJCustomLayout

- (ZJCollectionViewLayoutAttributes *)attributesWithChildrenAtIndexPath:(NSIndexPath *)indexPath
{
    ZJCollectionViewLayoutAttributes *attribute = [ZJCollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
    if ([self.customDataSource respondsToSelector:@selector(childrenAtIndexPath:)])
    {
        attribute.children = [self.customDataSource childrenAtIndexPath:indexPath];
    }
    
    return attribute;
}

- (CGRect)frameForCellAtIndexPath:(NSIndexPath *)indexPath withHeight:(NSInteger)height
{
    CGRect rect = CGRectZero;
    rect.origin.x = (CELL_WIDTH + CELL_ROW_SPACE) * (indexPath.row)+ CELL_ROW_SPACE;;
    rect.origin.y = (CELL_HEIGHT + CELL_SEC_SPACE) *(indexPath.section) + CELL_SEC_SPACE;
    rect.size.width = CELL_WIDTH;
    rect.size.height = CELL_HEIGHT;
    
    return rect;
}

//- (void)adjustFramesOfChildrenAndConnectorsForClassAtIndexPath:(NSIndexPath *)indexPath withCurrentFrame:(CGRect)rect
//{
//    ZJCollectionViewLayoutAttributes *attributes = [self attributesWithChildrenAtIndexPath:indexPath];
//    
//    if (0 != indexPath.row)
//    {
//        NSIndexPath *previousIndexpath = [NSIndexPath indexPathForRow:indexPath.row - 1 inSection:indexPath.section];
//        ZJCollectionViewLayoutAttributes *previouseAttribute = [self attributesWithChildrenAtIndexPath:previousIndexpath];
//        if (previouseAttribute.children)
//        {
//            NSUInteger previousCount = previouseAttribute.children.count;
//            rect.origin.y += (previousCount - 1) * CELL_HEIGHT;
//            attributes.frame = rect;
//        }
//    }
//    
//    
//    NSArray *children = attributes.children;
//    if (!children)
//    {
//        return;
//    }
//    
//    NSUInteger count = [children count];
//    for (NSUInteger num = 0; num < count; num ++)
//    {
//        NSIndexPath *childIndexPath = [children objectAtIndex:num];
//        ZJCollectionViewLayoutAttributes *childAttribute = [self attributesWithChildrenAtIndexPath:childIndexPath];
//        CGRect childRect = childAttribute.frame;
//        childRect.origin.y = rect.origin.y + (num ) * CELL_HEIGHT;
//        childAttribute.frame = childRect;
//        
//        [self adjustFramesOfChildrenAndConnectorsForClassAtIndexPath:childIndexPath withCurrentFrame:childRect];
//        
//    }
//}

#pragma mark -
- (void)setUpAction
{
    self.insets = UIEdgeInsetsMake(INSET_TOP, INSET_LEFT, INSET_BOTTOM, INSET_RIGHT);
    

}
- (instancetype)init
{
    if (self = [super init])
    {
        [self setUpAction];
    }
    return self;
}

- (CGSize)collectionViewContentSize
{
    
    CGFloat width = self.collectionView.numberOfSections * (CELL_WIDTH + self.insets.left + self.insets.right);
    CGFloat height = self.maxNumRows * (CELL_HEIGHT + _insets.top + _insets.bottom);
    
    return CGSizeMake(height, width);
    
    return CGSizeZero;
}
- (void)prepareLayout
{
    //whole size preparation
    NSMutableDictionary *layoutInformation = [NSMutableDictionary dictionary];
    NSMutableDictionary *cellInformation = [NSMutableDictionary dictionary];
    NSIndexPath *indexPath;
    NSInteger numSections = [self.collectionView numberOfSections];
    numberOfColumn = numSections;
    for(NSInteger section = 0; section < numSections; section++)
    {
        NSInteger numItems = [self.collectionView numberOfItemsInSection:section];
        for(NSInteger item = 0; item < numItems; item++)
        {
            indexPath = [NSIndexPath indexPathForItem:item inSection:section];
            ZJCollectionViewLayoutAttributes *attributes = [self attributesWithChildrenAtIndexPath:indexPath];
            [cellInformation setObject:attributes forKey:indexPath];
        }
    }
    
    for(NSInteger section = numSections - 1; section >= 0; section--)
    {
        NSInteger numItems = [self.collectionView numberOfItemsInSection:section];
        NSInteger totalHeight = 0;
        for(NSInteger item = 0; item < numItems; item++)
        {
            indexPath = [NSIndexPath indexPathForItem:item inSection:section];
            ZJCollectionViewLayoutAttributes *attributes = [cellInformation objectForKey:indexPath];//1
            attributes.frame = [self frameForCellAtIndexPath:indexPath withHeight:totalHeight];
            
//            [self adjustFramesOfChildrenAndConnectorsForClassAtIndexPath:indexPath withCurrentFrame:attributes.frame];//2
            // begin adjust the frame and its children's frame
            if (item)
            {
                NSIndexPath *previousIndex = [NSIndexPath indexPathForRow:item - 1 inSection:section];
                ZJCollectionViewLayoutAttributes *previousAttribute = cellInformation[previousIndex];
                CGRect rect = attributes.frame;
                CGRect previousRect = previousAttribute.frame;
                rect.origin.x = previousRect.origin.x + previousRect.size.width + CELL_ROW_SPACE;
                if (previousAttribute.children)
                {
                    ZJCollectionViewLayoutAttributes *preLastChildAttri  = cellInformation[previousAttribute.children.lastObject];
                    CGRect preLastChildFrame = preLastChildAttri.frame;
                    rect.origin.x = preLastChildFrame.origin.x + preLastChildFrame.size.width + CELL_ROW_SPACE;
                    
                    
                    
//                    rect.origin.x += (CELL_WIDTH + CELL_ROW_SPACE) * (previousAttribute.children.count - 1);
                }
                attributes.frame = rect;
                
                if (attributes.children)
                {
                    NSUInteger childrenCount = attributes.children.count;
                    CGFloat baseOffset = rect.origin.x;
                    
                    for (NSUInteger count = 0; count < childrenCount; count ++)
                    {
                        NSIndexPath *childIndexpath = attributes.children[count];;
                        ZJCollectionViewLayoutAttributes *childAttri = cellInformation[childIndexpath];
                        CGRect childRect = childAttri.frame;
                        childRect.origin.x = baseOffset + count *(CELL_WIDTH + CELL_ROW_SPACE);
                        childAttri.frame = childRect;
                    }
                }
                
            }
            
            cellInformation[indexPath] = attributes;
//            totalHeight += [self.customDataSource numRowsForClassAndChildrenAtIndexPath:indexPath];//3
        }
                            
            if(section == 0)
            {
                self.maxNumRows = 15;//4
                
            }
                            
        }
    
    [layoutInformation setObject:cellInformation forKey:@"MyCellKind"];//5
    
    
    //frame for supplement view
    NSMutableDictionary *suppleDict = [NSMutableDictionary dictionary];
    for(NSInteger section = 0; section < numSections; section++)
    {
        NSInteger numItems = [self.collectionView numberOfItemsInSection:section];
        for(NSInteger item = 0; item < numItems; item++)
        {
            indexPath = [NSIndexPath indexPathForItem:item inSection:section];
            ZJCollectionSuppleLayoutAttributes *suppleAttri = [ZJCollectionSuppleLayoutAttributes layoutAttributesForSupplementaryViewOfKind:ZJSupplementKindDiagram withIndexPath:indexPath];
            
            
            ZJCollectionViewLayoutAttributes *cellAttribute = cellInformation[indexPath];
            NSArray *cellChildren = cellAttribute.children;
            if (cellChildren)
            {
                NSUInteger childrenCount = cellChildren.count;
                //calculate the frame
                CGRect cellFrame = cellAttribute.frame;
                CGRect suppleFrame = cellFrame;
                suppleFrame.origin.y = cellFrame.origin.y + cellFrame.size.height;
                suppleFrame.size.height = CELL_SEC_SPACE;
               

                NSMutableArray *mPointArray = [NSMutableArray arrayWithCapacity:childrenCount];
                for (NSUInteger childNum = 0; childNum < childrenCount; childNum ++)
                {
                    NSIndexPath *firstIndexPath = [cellChildren objectAtIndex:childNum];
                    ZJCollectionViewLayoutAttributes *firstChildAttri = cellInformation[firstIndexPath];
                    CGRect firstChildFrame = firstChildAttri.frame;
                    CGPoint firstPoint = CGPointMake(firstChildFrame.origin.x + firstChildFrame.size.width /2, firstChildFrame.origin.y + firstChildFrame.size.height /2);
                    
                    [mPointArray addObject:[NSValue valueWithCGPoint:firstPoint]];
                    
                    
                    if (childNum == childrenCount - 1)
                    {
                        suppleFrame.size.width = firstChildFrame.origin.x + firstChildFrame.size.width - suppleFrame.origin.x;
                    }
                }
                suppleAttri.frame = suppleFrame;
                suppleAttri.pointArray = mPointArray;
                
                
                
                
            }
            [suppleDict setObject:suppleAttri forKey:indexPath];
        }
    }
    
    [layoutInformation setObject:suppleDict forKey:ZJSupplementKindDiagram];
    self.layoutInformation = layoutInformation;
}


//basically size,position
- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    ZJCollectionViewLayoutAttributes *attribute = self.layoutInformation[@"MyCellKind"][indexPath];
    return attribute;

}

- (UICollectionViewLayoutAttributes *)layoutAttributesForSupplementaryViewOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    if ([kind isEqualToString:ZJSupplementKindDiagram])
    {
        ZJCollectionSuppleLayoutAttributes *suppleAttri = self.layoutInformation[ZJSupplementKindDiagram][indexPath];
        return suppleAttri;
    }
    return nil;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForDecorationViewOfKind:(NSString *)decorationViewKind atIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect
{
    NSMutableArray *myAttributes = [NSMutableArray arrayWithCapacity:self.layoutInformation.count];
    for (NSString *key  in self.layoutInformation)
    {
        NSDictionary *attributesDict = [self.layoutInformation objectForKey:key];
        for (NSIndexPath *indexPath  in attributesDict)
        {
            ZJCollectionViewLayoutAttributes *attributes = [attributesDict objectForKey:indexPath];
            if (CGRectIntersectsRect(rect, attributes.frame))
            {
                [myAttributes addObject:attributes];
            }
        }
    }
    
    return myAttributes;

}
@end


@implementation ZJCollectionSuppleLayoutAttributes
+ (instancetype)layoutAttributesForSupplementaryViewOfKind:(NSString *)elementKind withIndexPath:(NSIndexPath *)indexPath
{
    return [super layoutAttributesForSupplementaryViewOfKind:elementKind withIndexPath:indexPath];
}


@end
