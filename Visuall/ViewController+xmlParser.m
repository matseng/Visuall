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
    NSString *fileName = @"defaultVisualizationSmall";
//    NSString *fileName = @"defaultVisualization1773";
    NSString* filePath = [[NSBundle mainBundle] pathForResource:fileName
                                                         ofType:@"xml"];
    
    __block NSString *result = @"test";  // https://developer.apple.com/library/ios/documentation/Cocoa/Conceptual/Blocks/Articles/bxVariables.html
    __block NSString *text;
    __block NSString *pointX;
    __block NSString *pointY;
    __block CGPoint point;
    __block int counter = 0;
    DDFileReader * reader = [[DDFileReader alloc] initWithFilePath: filePath];
    NSDate *methodStart = [NSDate date];
    [reader enumerateLinesUsingBlock:^(NSString * line, BOOL * stop) {
        result = [result stringByAppendingString: line];  // concatenate lines of XML
        
        /*
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
            NoteItem2 *newNote = [[NoteItem2 alloc] initNote: text withPoint: point];  // CGPointMake(-800, -900)
//            [self.visuallState setValueNote: newNote];  // DANGER may overwhelm Firebase
            [self addNoteToViewWithHandlers:newNote];
            [self calculateTotalBounds: newNote];
            result = @"";
            NSLog(@"\n Counter %d", counter++);
//            return;
         
        }  */
    }];
    NSDate *methodFinish = [NSDate date];
    NSTimeInterval executionTime = [methodFinish timeIntervalSinceDate:methodStart];
    NSLog(@"Done loading notes: executionTime = %f", executionTime);
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
