//
//  SetCardView.m
//  Matchismo_3
//
//  Created by Corneliu on 4/5/13.
//
//

#import "SetCardView.h"

@implementation SetCardView

#pragma mark - Initialization

- (void)setup
{
    // do initialization here
}

- (void)awakeFromNib
{
    [self setup];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    [self setup];
    return self;
}


-(void) setShading:(NSString *)shading
{
    _shading = shading;
    [self setNeedsDisplay];
}
-(void) setColor:(NSString *)color
{
    _color = color;
    [self setNeedsDisplay];
}
-(void) setSymbol:(NSString *)symbol
{
    _symbol = symbol;
    [self setNeedsDisplay];
}
-(void) setRepeat:(NSNumber *)repeat
{
    _repeat = repeat;
    [self setNeedsDisplay];
}
- (void)setFaceUp:(BOOL)faceUp
{
    _faceUp = faceUp;
    [self setNeedsDisplay];
}

-(UIColor*) getUIColorForCardColor
{
    UIColor* result;
    if([self.color isEqualToString: @"Red"])
        result = [UIColor redColor];
    if([self.color isEqualToString: @"Blue"])
        result = [UIColor blueColor];
    if([self.color isEqualToString: @"Green"])
        result = [UIColor greenColor];
    return result;
}

- (void)pushContext
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
}

- (void)popContext
{
    CGContextRestoreGState(UIGraphicsGetCurrentContext());
}

#define CORNER_RADIUS 5.0
#define STROKE_LIKE_WIDTH 1
#define STRIPE_LINE_SPACING 2
#define SYMBOL_HEIGHT 10
#define SYMBOL_WIDTH 15
#define SYMBOL_SCALE_FACTOR 1
#define SYMBOL_INBETWEEN_MARGIN_WIDTH 5

- (void) shadeInsideShapePath:(UIBezierPath*) path
{
    if([self.shading isEqualToString: @"Open"])
        return;
    
    if([self.shading isEqualToString: @"Solid"])
    {
        [[self getUIColorForCardColor] setFill];
        [path fill];
    }
    
    if([self.shading isEqualToString: @"Stripped"])
    {
        [self pushContext];
        [path addClip];
        UIBezierPath* stripesPath = [[UIBezierPath alloc] init];
        CGPoint currentPoint      = path.bounds.origin;
        while(currentPoint.x < path.bounds.origin.x + path.bounds.size.width){
            [stripesPath moveToPoint:currentPoint];
            [stripesPath addLineToPoint:CGPointMake(currentPoint.x, currentPoint.y + path.bounds.size.height)];
            currentPoint.x += STRIPE_LINE_SPACING;
        }
        [self strokePath:stripesPath];
        [self popContext];
    }
    
}

- (void) strokePath:(UIBezierPath*) path
{
    path.lineWidth = STROKE_LIKE_WIDTH;
    [[self getUIColorForCardColor] setStroke];
    [path stroke];
}


- (void) drawSquiggleInRect:(CGRect) rect
{
    UIBezierPath *squigglePath = [[UIBezierPath alloc] init];
    CGPoint center = CGPointMake(rect.origin.x + rect.size.width/2.0,
                                 rect.origin.y + rect.size.height/2.0);
    
    CGFloat halfWidth  = rect.size.width/2.0;
    CGFloat halfHeight = rect.size.height/2.0;
    CGFloat dx = rect.size.width/6;
    CGFloat dy = rect.size.height/6;

    [squigglePath moveToPoint:CGPointMake(center.x - halfWidth, center.y)];
    [squigglePath addCurveToPoint:CGPointMake(center.x + halfWidth, center.y - halfHeight)
                 controlPoint1:CGPointMake(center.x, center.y - halfWidth)
                 controlPoint2:CGPointMake(center.x, center.y)];
    [squigglePath addQuadCurveToPoint:CGPointMake(center.x + dx, center.y + dy)
                         controlPoint:CGPointMake(center.x + halfWidth, center.y+halfHeight)];
    [squigglePath addCurveToPoint:CGPointMake(center.x - halfWidth, center.y + halfHeight)
                    controlPoint1:CGPointMake(center.x, center.y + dy)
                    controlPoint2:CGPointMake(center.x - dx, center.y)];
    [squigglePath addQuadCurveToPoint:CGPointMake(center.x - halfWidth, center.y)
                         controlPoint:CGPointMake(center.x - halfWidth, center.y+halfHeight)];

    [self shadeInsideShapePath:squigglePath];
    [self strokePath:squigglePath];
    
}

- (void) drawDiamondInRect:(CGRect) rect
{
    UIBezierPath *diamondPath = [[UIBezierPath alloc] init];
    CGPoint center = CGPointMake(rect.origin.x + rect.size.width/2.0,
                                 rect.origin.y + rect.size.height/2.0);
    //move to center point on left edge
    [diamondPath moveToPoint:CGPointMake(center.x - rect.size.width/2.0, center.y)];
    //draw up to mid point on top edge
    [diamondPath addLineToPoint:CGPointMake(center.x, center.y - rect.size.width/2.0)];
    //draw to center of right edge
    [diamondPath addLineToPoint:CGPointMake(center.x + rect.size.width/2.0, center.y)];
    //draw to mid of bottom edge 
    [diamondPath addLineToPoint:CGPointMake(center.x, center.y + rect.size.width/2.0)];
    //close path to begining
    [diamondPath closePath];
    [self shadeInsideShapePath:diamondPath];
    [self strokePath:diamondPath];

}

- (void) drawOvalInRect:(CGRect) rect
{

    UIBezierPath *roundedRect = [UIBezierPath bezierPathWithRoundedRect:rect
                                                           cornerRadius:rect.size.height/(SYMBOL_HEIGHT/3)];
    [self shadeInsideShapePath:roundedRect];
    [self strokePath:roundedRect];
}

- (void) drawSymbolInRect:(CGRect) rect
{
    if([self.symbol isEqualToString: @"Oval"])
        [self drawOvalInRect:rect];
    else if([self.symbol isEqualToString: @"Diamond"])
        [self drawDiamondInRect:rect];
    else if([self.symbol isEqualToString: @"Squiggle"])
        [self drawSquiggleInRect:rect];
}

- (void)drawRect:(CGRect)rect
{
    // Drawing code
    
    // Draw Background
    UIBezierPath *roundedRect = [UIBezierPath bezierPathWithRoundedRect:self.bounds
                                                           cornerRadius:CORNER_RADIUS];
    [roundedRect addClip];
    if (!self.faceUp){
        [[UIColor whiteColor] setFill];
    }
    else{
        [[UIColor blackColor] setFill];
    }
    UIRectFill(self.bounds);
    
    // Draw Symbols
    int numberOfMargins      = [self.repeat integerValue] - 1;
    int symbolContainerWidth = [self.repeat integerValue] * SYMBOL_WIDTH * SYMBOL_SCALE_FACTOR + numberOfMargins * SYMBOL_INBETWEEN_MARGIN_WIDTH;
    CGPoint innerCenter = CGPointMake(self.bounds.origin.x + self.bounds.size.width/2.0,
                                      self.bounds.origin.y + self.bounds.size.height/2.0);
    CGPoint symbolContainerOrigin = CGPointMake(innerCenter.x - symbolContainerWidth/2.0,
                                                innerCenter.y - SYMBOL_HEIGHT);

    CGPoint currentPoint = symbolContainerOrigin;
    for(int i = 0; i < [self.repeat integerValue]; i++)
    {
        CGRect symbolRect = CGRectMake(currentPoint.x,
                                       currentPoint.y,
                                       SYMBOL_WIDTH  * SYMBOL_SCALE_FACTOR,
                                       SYMBOL_HEIGHT * SYMBOL_SCALE_FACTOR);
        
        [self drawSymbolInRect: symbolRect];
        currentPoint.x += SYMBOL_WIDTH  * SYMBOL_SCALE_FACTOR;
        currentPoint.x += SYMBOL_INBETWEEN_MARGIN_WIDTH;
    }
    
}


@end
