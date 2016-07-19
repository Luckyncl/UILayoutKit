//
//  TextView.m
//  UILayoutKit
//
//  Created by Tom Quist on 22.07.12.
//  Copyright (c) 2012 Tom Quist. All rights reserved.
//

#import "ULKTextView.h"
#import "UIView+ULK_Layout.h"
#import "UILabel+ULK_View.h"
#import "UIView+ULKDrawable.h"

@implementation ULKTextView

- (void)ulk_onMeasureWithWidthMeasureSpec:(ULKLayoutMeasureSpec)widthMeasureSpec heightMeasureSpec:(ULKLayoutMeasureSpec)heightMeasureSpec {
    ULKLayoutMeasureSpecMode widthMode = widthMeasureSpec.mode;
    ULKLayoutMeasureSpecMode heightMode = heightMeasureSpec.mode;
    CGFloat widthSize = widthMeasureSpec.size;
    CGFloat heightSize = heightMeasureSpec.size;
    
    ULKLayoutMeasuredSize measuredSize;
    measuredSize.width.state = ULKLayoutMeasuredStateNone;
    measuredSize.height.state = ULKLayoutMeasuredStateNone;
    UIEdgeInsets padding = self.ulk_padding;
    
    
    if (widthMode == ULKLayoutMeasureSpecModeExactly) {
        measuredSize.width.size = widthSize;
    } else {
        CGSize size;
        if ([self respondsToSelector:@selector(attributedText)]) {
            size = [self.attributedText boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX)
                                         options:NSStringDrawingUsesLineFragmentOrigin
                                         context:nil].size;
        } else {
            [self.text sizeWithFont:self.font];
        }
        measuredSize.width.size = ceilf(size.width) + padding.left + padding.right;
        if (widthMode == ULKLayoutMeasureSpecModeAtMost) {
            measuredSize.width.size = MIN(measuredSize.width.size, widthSize);
        }
    }
    CGSize minSize = self.ulk_minSize;
    measuredSize.width.size = MAX(measuredSize.width.size, minSize.width);
    
    if (heightMode == ULKLayoutMeasureSpecModeExactly) {
        measuredSize.height.size = heightSize;
    } else {
        CGSize size;
        if ([self respondsToSelector:@selector(attributedText)]) {
            size = [self.text boundingRectWithSize:CGSizeMake(measuredSize.width.size - padding.left - padding.right, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: self.font} context:nil].size;
        } else {
            size = [self.text sizeWithFont:self.font constrainedToSize:CGSizeMake(measuredSize.width.size - padding.left - padding.right, CGFLOAT_MAX) lineBreakMode:self.lineBreakMode];
        }
        measuredSize.height.size = MAX(ceilf(size.height), self.numberOfLines * self.font.lineHeight) + padding.top + padding.bottom;
        if (heightMode == ULKLayoutMeasureSpecModeAtMost) {
            measuredSize.height.size = MIN(measuredSize.height.size, heightSize);
        }
    }
    measuredSize.height.size = MAX(measuredSize.height.size, minSize.height);
    
    [self ulk_setMeasuredDimensionSize:measuredSize];
}

- (void)setUlk_gravity:(ULKViewContentGravity)gravity {
    [super setUlk_gravity:gravity];
    if ((gravity & ULKViewContentGravityTop) == ULKViewContentGravityTop) {
        self.contentVerticalAlignment = UIControlContentVerticalAlignmentTop;
    } else if ((gravity & ULKViewContentGravityBottom) == ULKViewContentGravityBottom) {
        self.contentVerticalAlignment = UIControlContentVerticalAlignmentBottom;
    } else if ((gravity & ULKViewContentGravityFillVertical) == ULKViewContentGravityFillVertical) {
        self.contentVerticalAlignment = UIControlContentVerticalAlignmentFill;
    }
}

- (ULKViewContentGravity)ulk_gravity {
    ULKViewContentGravity ret = [super ulk_gravity];
    switch (self.contentVerticalAlignment) {
        case UIControlContentVerticalAlignmentTop:
            ret |= ULKViewContentGravityTop;
            break;
        case UIControlContentVerticalAlignmentBottom:
            ret |= ULKViewContentGravityBottom;
            break;
        case UIControlContentVerticalAlignmentCenter:
            ret |= ULKViewContentGravityCenterVertical;
            break;
        case UIControlContentVerticalAlignmentFill:
            ret |= ULKViewContentGravityFillVertical;
            break;
    }
    return ret;
}

- (void)setContentVerticalAlignment:(UIControlContentVerticalAlignment)contentVerticalAlignment {
    _contentVerticalAlignment = contentVerticalAlignment;
    [self setNeedsDisplay];
}

- (CGRect)textRectForBounds:(CGRect)bounds limitedToNumberOfLines:(NSInteger)numberOfLines {
    CGRect rect = [super textRectForBounds:bounds limitedToNumberOfLines:numberOfLines];
    CGRect result;
    switch (_contentVerticalAlignment)
    {
        case UIControlContentVerticalAlignmentTop:
            result = CGRectMake(rect.origin.x, bounds.origin.y, rect.size.width, rect.size.height);
            break;
        case UIControlContentVerticalAlignmentCenter:
            result = CGRectMake(rect.origin.x, bounds.origin.y + (bounds.size.height - rect.size.height) / 2, rect.size.width, rect.size.height);
            break;
        case UIControlContentVerticalAlignmentBottom:
            result = CGRectMake(rect.origin.x, bounds.origin.y + (bounds.size.height - rect.size.height), rect.size.width, rect.size.height);
            break;
        default:
            result = bounds;
            break;
    }
    return result;
}

- (void)drawTextInRect:(CGRect)rect {
    
    if ([self respondsToSelector:@selector(sizeThatFits:)]) {
        rect = UIEdgeInsetsInsetRect(rect, self.ulk_padding);
        CGRect result;
        CGSize sizeThatFits = [self sizeThatFits:rect.size];
        switch (_contentVerticalAlignment)
        {
            case UIControlContentVerticalAlignmentTop:
                result = CGRectMake(rect.origin.x, rect.origin.y, rect.size.width, sizeThatFits.height);
                break;
            case UIControlContentVerticalAlignmentBottom:
                result = CGRectMake(rect.origin.x, rect.origin.y + (rect.size.height - sizeThatFits.height), rect.size.width, sizeThatFits.height);
                break;
            default:
                result = rect;
                break;
        }
        [super drawTextInRect:result];
    } else {
        CGRect r = [self textRectForBounds:rect limitedToNumberOfLines:self.numberOfLines];
        [super drawTextInRect:r];
    }
}

- (void)setText:(NSString *)text {
    [super setText:text];
    [self ulk_requestLayout];
}

- (void)setFont:(UIFont *)font {
    [super setFont:font];
    [self ulk_requestLayout];
}

- (void)setLineBreakMode:(NSLineBreakMode)lineBreakMode {
    [super setLineBreakMode:lineBreakMode];
    [self ulk_requestLayout];
}

@end
