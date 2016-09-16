//
//  ViewController+xmlParser.m
//  Visuall
//
//  Created by Michael Tseng MacBook on 9/1/16.
//  Copyright © 2016 Visuall. All rights reserved.
//

#import "ViewController+xmlParser.h"
#import "DDFileReader.h"
#import "RegExCategories.h"

@implementation ViewController (xmlParser)

- (void) loadAndUploadXML
{
    __block int n = 500;
//    NSString *fileName = @"defaultVisualizationSmall";
    NSString *fileName = @"defaultVisualization500";
//    NSString *fileName = @"defaultVisualization1773";
    NSString* filePath = [[NSBundle mainBundle] pathForResource:fileName
                                                         ofType:@"xml"];
    
    __block NSString *result = @"test";  // https://developer.apple.com/library/ios/documentation/Cocoa/Conceptual/Blocks/Articles/bxVariables.html
    __block NSString *text;
    __block NSString *pointX;
    __block NSString *pointY;
    __block CGPoint point;
    __block int counter = 0;
    __block float fontSize;
    __block NSString *nodeID;
    __block NSMutableDictionary *noteDict = [NSMutableDictionary new];
    __block NSArray *aggregateArray;
    __block NSMutableArray *aggregateArrayOfArrays = [[NSMutableArray alloc] initWithCapacity: n];
    __block NSString *aggregateString;
    DDFileReader * reader = [[DDFileReader alloc] initWithFilePath: filePath];
    NSDate *methodStart = [NSDate date];
    
//    return;  // TODO (Sep 2, 2016):
    
    [reader enumerateLinesUsingBlock:^(NSString * line, BOOL * stop) {
        result = [result stringByAppendingString: line];  // concatenate lines of XML
//        if ([result isMatch:RX(@"\\<node\\sid\\=\"(\\d)+\"\\>")] && [result isMatch:RX(@"\\<\\/node\\>")])  // determine if we have a complete node
        if ([line isMatch:RX(@"\\<\\/node\\>")])  // we reach an end node
        {
            text = [result firstMatch:RX(@"\\<data key\\=\"name\"\\>[\\s\\S]*?\\<\\/data>")];
            text = [text stringByReplacingOccurrencesOfString:@"<data key=\"name\">" withString:@""];
            text = [text stringByReplacingOccurrencesOfString:@"</data>" withString:@""];
//            NSLog(@"read text: \n %@", text);
            pointX = [self getValueFromXMLString: result forKey:@"X"];
//            NSLog(@"read text: \n %@", pointX);
            pointY = [self getValueFromXMLString: result forKey:@"Y"];
//            NSLog(@"read text: \n %@", pointY);
            point = CGPointMake([pointX floatValue], [pointY floatValue]);
            
            fontSize = [[self getValueFromXMLString: result forKey:@"font"] floatValue];
            
            aggregateString = [self getValueFromXMLString: result forKey:@"aggregate"];
            if (![@"null" isEqualToString: aggregateString]){
                NSLog(@"read text: \n aggregateString: %@", aggregateString);
                aggregateArray = [aggregateString componentsSeparatedByString:@" "];
                [aggregateArrayOfArrays addObject: [aggregateArray copy]];
            }

            NoteItem2 *newNote = [[NoteItem2 alloc] initNote: text withPoint: point];  //
            [newNote setFontSize: fontSize];
            [noteDict setObject: newNote forKey: [NSString stringWithFormat:@"%d", counter]];
//            [self.visuallState setValueNote: newNote];  // CAUTION may overwhelm Firebase
            [self addNoteToViewWithHandlers:newNote];
//            [self calculateTotalBounds: newNote];
            result = @"";
            NSLog(@"\n Counter %d", counter++);
            if ( counter == n)
            {
                NSLog(@"\n DONE READING XML");
                for (NSArray *arr in aggregateArrayOfArrays)
                {
                    [self addGroupFromAggregateArray: arr andDictionary: noteDict];
                }
            }
         
        } 
    }];
    NSDate *methodFinish = [NSDate date];
    NSTimeInterval executionTime = [methodFinish timeIntervalSinceDate:methodStart];
    NSLog(@"Done loading notes: executionTime = %f", executionTime);
}


- (void) addGroupFromAggregateArray: (NSArray *) arr andDictionary: (NSMutableDictionary *) dict
{
    CGRect rect = CGRectZero;
//    NSNumber *key;
    NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
    f.numberStyle = NSNumberFormatterDecimalStyle;
    for (NSString *key in arr) {
//        key = [f numberFromString: str];
        NoteItem2 *ni = dict[key];
        rect = CGRectUnion(rect, ni.frame);
    }
    NSLog(@"\n just made a rect");
    
}

- (NSString *) getValueFromXMLString: (NSString *) xmlString forKey: (NSString *) key
{
    // Find the value we're looking for
    NSString *result;
    NSString *regex = [@"\\<data key\\=\"" stringByAppendingString: key];
    regex = [regex stringByAppendingString:@"\"\\>[\\s\\S]*?\\<\\/data>"];
    result = [xmlString firstMatch:RX(regex)];
    
    // Remove surrounding XML tags
    NSString *regex2 = [@"<data key=\"" stringByAppendingString: key];
    regex2 = [regex2 stringByAppendingString:@"\">"];
    result = [result stringByReplacingOccurrencesOfString:regex2 withString:@""];
    result = [result stringByReplacingOccurrencesOfString:@"</data>" withString:@""];
    return result;
}


@end
