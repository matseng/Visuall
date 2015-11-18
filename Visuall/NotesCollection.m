//
//  NotesCollection.m
//  Visuall
//
//  Created by Michael Tseng MacBook on 11/10/15.
//  Copyright © 2015 Visuall. All rights reserved.
//

#import "NotesCollection.h"
#import "Note.h"
#import "NoteItem.h"

@interface NotesCollection () <UIGestureRecognizerDelegate>
@end


@implementation NotesCollection


- (void) initializeNotes
{
    self.Notes = [[NSMutableArray alloc] init];
    Note *hw0 = [[Note alloc]initWithString:@"Hello World 5" andCenterX:20.0 andCenterY:20.0];
    Note *hw1 = [[Note alloc]initWithString:@"Hello World 6" andCenterX:60.0 andCenterY:260.0];
    
//    NoteView *nv0 = (NoteView *)[[UITextField alloc] init];
    NoteItem *utf = [[NoteItem alloc] initWithFrame:CGRectMake(100, 100, 300, 25)];
    utf.text = @"Hello World 7";
    
//    
//    NoteView *nv1 = (NoteView *)[[UITextField alloc] init];
//    nv1.note = hw1;
    
    [self.Notes addObject:utf];
//    [self.Notes addObject:nv1];
}

//- (NSMutableArray *) getNoteViews
//{
//    NSMutableArray *viewsArray = [[NSMutableArray alloc] init];
//    for (Note* note in self.Notes) {
//        UITextField *utf = [note getView];
//        [viewsArray addObject: utf];
//    }
//    return viewsArray;
//}


@end
