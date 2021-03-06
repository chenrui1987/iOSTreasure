//
//  ZJPendulumBehavior.h
//  AdvancedDynamic
//
//  Created by Zhu J on 10/22/13.
//  Copyright (c) 2013 Zhu J. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ZJPendulumBehavior : UIDynamicBehavior
- (instancetype)initWithWeight:(id<UIDynamicItem>)item AndPoint:(CGPoint)point;
- (void)beginDragToPoint:(CGPoint)point;
- (void)dragWeightToPoint:(CGPoint)point;
- (void)endDragToPoint:(CGPoint)point;
@end
