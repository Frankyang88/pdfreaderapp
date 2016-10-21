//
//  bookmarkview.swift
//  PDF
//
//  Created by Jialin Yang on 9/29/16.
//  Copyright © 2016 Jialin Yang. All rights reserved.
//

import Cocoa
import Quartz
/*
  the view for book mark, for the moment the scrollview is a fixed size, which means it is able to host max 67 book marks
  I think this may be enough for a small pdf viewer.
 
 */
class bookmarkview: NSScrollView {
    
    /* pdfview and pdf are two reference to those in the pdfview controller.
     * the purpose is to implement jump to a specific pagenumber functionality
     */
    var pdfviewer :PDFView?
    var pdf :PDFDocument?
    
    
    /*count the number of button*/
    private var counter = 0
    
    /*setup the view for button  array*/
    private var documentview = NSView(frame: NSRect(x: 0,y:0,width:166,height: 6000));
    
    
    /* reset the bookmark field for the book mark
     * this method is used when a new pdf file is opened.
     */
    func reset_doc(){
        counter = 0;
        documentview = NSView(frame: NSRect(x: 0,y:0,width:166,height: 6000 ));
        self.documentView = documentview
        self.contentView.scrollPoint(NSPoint(x:10,y:1970))
        
    }
    
    /* add a button to the current bookmark view
     * counter: calculate the current button's position and indicate that the new button is drawn on the bottom
     * of previous one.
     *
     * create a new button,set its title as the current page number
     * and add itself to the current book mark view ,register the button's action(jump to current page).
     *
     * set the book mark view to focus on the current page every time there is a new bookmark added to the view(
     * otherwise, it will go to the bottom of the bookmarkview)
     */
    func add(pagenum:String?){
      
        
        let myButtonRect = CGRect(x: 30 , y: 5970 - counter*30, width: 80, height: 20)
        let myButton =  NSButton(frame: myButtonRect)
     
        documentview.addSubview(myButton)
        self.counter += 1
        
        myButton.target = self
        
        myButton.action = #selector(jumpto)
        
        myButton.title = pagenum!
        
     
        
        
        self.documentView = documentview
        
        self.contentView.scrollPoint(NSPoint(x:10,y:6000-counter*30))
        
    }
    
    /* jumpto:
     * button action, jump to the page stated in the button's title
     *
     */
    @objc func jumpto(sender:AnyObject?) {
        
        
        let page = sender?.title
        
        let dest = (Int(page!)! ) - 1
        let dest_page = pdf!.pageAtIndex( dest )
        pdfviewer!.goToPage(dest_page)
        
    }
    
    
    
    
}
