//
//  pdfviewcontroller.swift
//  PDF
//
//  Created by Jialin Yang on 9/19/16.
//  Copyright © 2016 Jialin Yang. All rights reserved.
//
//
//


import Cocoa
import Quartz
import Foundation

class pdfviewcontroller: NSWindowController, NSTableViewDataSource, NSTableViewDelegate {
    

    
    override var windowNibName: String? {
        return "pdfviewcontroller"
    }
    
    // gui view
    
    
    /*The view host pdfview*/
    @IBOutlet weak var Content: NSView!
    
    /*The view host all the button&txtbox on the toolbar*/
    @IBOutlet weak var toolbar: NSView!
    
    
    /*pdf view host the content of pdffile*/
    @IBOutlet var pdfwindow: NSWindow!
    //pdf document and file name(include path) and pdfview
    @IBOutlet weak var pdfviewer: PDFView!
    var filename : String?
    var pdf : PDFDocument?
 
    
    
    // book mark scroll view
    @IBOutlet weak var BookmarkView: bookmarkview!
    var bookmarkarray : [String] = []
    
    //Jump to Page,specify the pagenum that it will jump to
    @IBOutlet weak var PageNumJ: NSTextField!
    
    
    //Add note to pdf file,host the notes for the current page
    @IBOutlet weak var NoteBox: NSTextField!
    /*Note array, dictionary : the key is page number, the value is the notes*/
    var NoteArray : [String : String] = [:]
    
    
    var stateflag = 0;
    
    
    override func windowDidLoad() {
        super.windowDidLoad()
        
        // Notification registration, for update sth when the page displayed on the pdfview has changed.
        // eg. window title(pdffile name ,page number), the current notes in the note box
        NSNotificationCenter.defaultCenter().postNotificationName(PDFViewPageChangedNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(pdfviewcontroller.updateGUI(_:)), name:PDFViewPageChangedNotification ,object: nil)
        
    }
    override func windowWillLoad() {
    }
    
    
    /* record the notes and update notes, and save changes to the disk
     * the notes is associated with page number, saved in a dictionary array
     */
    @IBAction func Note(sender: AnyObject) {
        
        let currentpage = pdfviewer.currentPage()
        let pagenum = currentpage.label()
        
        NoteArray.updateValue(NoteBox.stringValue, forKey: pagenum)
        savenotestodisk()
        
        
    }
    
    /* Read notes from the txt file.
     * Get the current pdffile name 
     * search the pdf file with the same filename and path(change the extension from pdf to txt)
     *
     * if txt file not exist report error,reset content of arry
     * if find the txt file, load the content of the file and udpate the content of notes array
     *  
     * Update the content of notearray and note box
     */
    func readnotesfromdisk(){
        
        let pdffile = filename!
        
        let txtfile = pdffile.stringByReplacingOccurrencesOfString("pdf", withString: "txt")
        
        let dir = txtfile
        
        let path = NSURL(fileURLWithPath: dir)
        var readfile : NSString?
    
   
        do {
            readfile = try NSString(contentsOfURL: path, encoding: NSUTF8StringEncoding)
            let pagenotearray = readfile!.componentsSeparatedByString("\n")
            NoteArray = [:]
            for str in pagenotearray {
                if( str != ""){
                    let info = str.componentsSeparatedByString(":")
                    NoteArray.updateValue(info[1], forKey: info[0])
                    
                    if(info[0] == "1") {
                        NoteBox.stringValue = info[1]
                    }
                }
            }
        
        }
        catch { NoteArray = [:]
                NoteBox.stringValue = ""
                print("fail to read note file or note file doesnot exist")}
        
        
    }
    
    /*  save a note file in the same path with the pdf file
     *  The note file share the same name as the pdf file,their difference is the extension.(pdf & txt)
     *  all the notes of the same page are in one line with the page number
     *  format:  Pagenum: notes
     *  Caution: The use of ":" in the note box would introduce errors when reading content from notes file
     *
     */
    func savenotestodisk(){
        
 
        
            let pdffile = filename!
        
            let txtfile = pdffile.stringByReplacingOccurrencesOfString("pdf", withString: "txt")
        
        
            let dir = txtfile
        
            let path = NSURL(fileURLWithPath: dir)
            var note = ""
            for (pagenum,notes) in NoteArray {
                 note  += pagenum + ":" + notes+"\n"
            }
    
        do{
            try note.writeToURL(path, atomically: true, encoding: NSUTF8StringEncoding)
        }
        catch{ print("fail to write to notes or illegal path")}
    
        
    }
    
    
    /*Book mark:
     *create book mark for the current page, the bookmark is a button with title(pagenumber)
     *
     *
    */
    @IBAction func BookMark(sender: AnyObject) {
        BookmarkView.pdf = pdf
        BookmarkView.pdfviewer = pdfviewer
    
        if(filename != nil) {
       
            
            let pdfpage = pdfviewer.currentPage()
            let page  = pdfpage.label()
            if bookmarkarray.contains(page) {
               print("there is already a button for the current page now")
                
            } else {
                
                bookmarkarray.append(page)
                BookmarkView.add(page)
            
                if stateflag == 1 {
                    savestatetodisk()
                }
            
            }
        }
        else {
        
            print("invalid pdf file")
        
        }
        
    }
    
    

    //zoom in current pdfview
    @IBAction func Zoomin(sender: AnyObject) {
        if pdfviewer.canZoomIn(){
            pdfviewer.zoomIn(sender)
        }
    }
    
    //zoom FIT current pdfview
    @IBAction func ZoomFit(sender: AnyObject) {
        
        
        pdfviewer.setAutoScales(true)
    }
    
    //zoom out current pdfview
    @IBAction func Zoomout(sender: AnyObject) {
        if pdfviewer.canZoomOut(){
            pdfviewer.zoomOut(sender)
        }
    }
    //Go to previous page of pdfview
    @IBAction func PreviousPage(sender: AnyObject) {
        
        if pdfviewer.canGoBack(){
            pdfviewer.goToPreviousPage(sender)
        }
    }
       //Go to nextpage of pdfview
    @IBAction func NextPage(sender: AnyObject) {
        if pdfviewer.canGoToNextPage(){
            pdfviewer.goToNextPage(sender)
        }
        
    }
    
    //Go to a specific page of pdfview
    @IBAction func JumpToPage(sender: AnyObject) {

        if filename != nil {
            if stateflag == 1 {
                savestatetodisk()}
            
        let pagenum = PageNumJ.integerValue - 1
        let max_page = pdf?.pageCount()
        
            if pagenum >= 0 && pagenum < max_page {
                    let dest_page = pdf?.pageAtIndex(pagenum)
                    pdfviewer.goToPage(dest_page)
            }
            else {
                print("invalid page number")
            
            }
        }
        else {
           // print("invalid pdf file,please open a pdf file")
        
        }
        
        
    }
    
    /*search key string */
    @IBOutlet weak var searchkey: NSSearchField!
    /*collection of searching result*/
    var searchresult : [PDFSelection] = []
    /*The current selection of search result*/
    var index = 0
    var search_update = 0
    
    /*search :
     * search the key string in the textbox
     * highlight all the searched items in the lists
     * Go to the first result
     */
    
    @IBAction func searchaction(sender: AnyObject) {
        
      
        
        if(search_update == 1) {
            for i in searchresult {
                i.setColor(NSColor(red: 1,green: 1,blue: 1,alpha: 1))
            }
        }
        
        pdfviewer.selectAll(sender)
        pdfviewer.clearSelection()
        if(filename != nil){
            if stateflag == 1 {
                savestatetodisk()}
            
            
        let key = searchkey.stringValue
            
            
        if(key != ""){
            
            search_update = 1
            searchresult = (pdf!.findString(key,withOptions: 1) as! [PDFSelection])
            for i in searchresult {
                i.setColor(NSColor(red: 1,green: 1,blue: 0,alpha: 1))
            }
            pdfviewer.setHighlightedSelections(searchresult)
            pdfviewer.goToSelection(searchresult[0])
            searchresult[0].setColor(NSColor(red: 0,green: 1,blue: 1,alpha: 1))
            }
        else {
               // print("invalid search")
                search_update = 0
                searchresult = []
            }
        }
        
    }
    
    /*go the the next items finded by search methods
     * set up scale factor to 110%
     * focus on the currrent selection
    */
    @IBAction func searchnavr(sender: AnyObject) {
        if search_update  != 0 {

        if(index <  ((searchresult.endIndex) - 1) ){
            index += 1
        }

   
       pdfviewer.setScaleFactor(CGFloat(1.1))
       
         
       pdfviewer.goToSelection(searchresult[index])

            for i in searchresult {
                if searchresult[index] != i {
                    i.setColor(NSColor(red: 1,green: 1,blue: 0,alpha: 1))
                }
                else {
                    i.setColor(NSColor(red: 0,green: 1,blue: 1,alpha: 1))
                    
                }
            }
            pdfviewer.selectAll(sender)
            pdfviewer.clearSelection()
        }
 
    }
    
    
    /* go to the previous items finded by search methods
     * set up scale factor to 110%
     * focus on the current selection
     */
    @IBAction func searchnavl(sender: AnyObject) {
        
        if search_update != 0 {

        if(index > 0) {
            index -= 1
        }

        
         pdfviewer.setScaleFactor(CGFloat(1.1))
       
         pdfviewer.goToSelection(searchresult[index])

  
            for i in searchresult {
                if searchresult[index] != i {
                    i.setColor(NSColor(red: 1,green: 1,blue: 0,alpha: 1))
                }
                else {
                    i.setColor(NSColor(red: 0,green: 1,blue: 1,alpha: 1))
                }
            }
            pdfviewer.selectAll(sender)
            pdfviewer.clearSelection()
        }

        
    }
    
    /*open a txt file and find its related pdf file
     * Then load the pdf file and the notes file
     */
    @IBAction func loadnotes(sender: AnyObject) {
        let dialog = NSOpenPanel();
        
        dialog.title                   = "Choose pdf file";
        dialog.showsResizeIndicator    = true;
        dialog.showsHiddenFiles        = false;
        dialog.canChooseDirectories    = true;
        dialog.allowsMultipleSelection = false;
        dialog.allowedFileTypes        = ["txt"];
        
        if (dialog.runModal() == NSModalResponseOK) {
            
            let result = dialog.URL // Pathname of the file
            let filepath = result!.absoluteString
            
            let start = filepath.rangeOfString("/home")
            let word = filepath.rangeOfString(".txt")
            //let file = filepath.substringWithRange(Range<String.Index>(start: start!.startIndex.advancedBy(0), end: word!.endIndex.advancedBy(0)))
            let file = filepath.substringWithRange(Range<String.Index>.init(start!.startIndex.advancedBy(0)..<word!.endIndex.advancedBy(0)))
            let pdffile = file.stringByReplacingOccurrencesOfString("txt", withString: "pdf")
        
            let newURL = NSURL(fileURLWithPath: pdffile)
            
            openfile(newURL)
            
        } else {
            // User clicked on "Cancel"
            return
        }
        
        
    }
    /* open a dialog panel, ask the user pick up pdf file
     */
    @IBAction func browseFile(sender: AnyObject) {
        
        let dialog = NSOpenPanel();
        
        dialog.title                   = "Choose pdf file";
        dialog.showsResizeIndicator    = true;
        dialog.showsHiddenFiles        = false;
        dialog.canChooseDirectories    = true;
        dialog.allowsMultipleSelection = false;
        dialog.allowedFileTypes        = ["pdf"];
        
        if (dialog.runModal() == NSModalResponseOK) {
            
            let result = dialog.URL // Pathname of the file
            openfile(result)
            
        } else {
            // User clicked on "Cancel"
          
            return
        }
        
    }
    /* open a pdf file
     * get filename(include path)
     * setup the pdfview and initialse the bookmark and notes, window title
     */
    func openfile(URL: NSURL?){
        
        let filepath = URL!.absoluteString
        
        
        let start = filepath.rangeOfString("/home")
        let word = filepath.rangeOfString(".pdf")
        filename = filepath.substringWithRange(Range<String.Index>.init(start!.startIndex.advancedBy(0)..<word!.endIndex.advancedBy(0)))
        
        
        if (URL != nil) {
            pdf = PDFDocument(URL:URL)
            
            if (pdf != nil ){
            
            pdfviewer.setDocument(pdf)
            pdfviewer.setAutoScales(false)
            
            BookmarkView.reset_doc();
            readnotesfromdisk();
            
            let currentPage = pdfviewer.currentPage()
            let pagenum = currentPage.label()
            pdfwindow.title = "\(filename!)"+"    Page: "+"\(pagenum)"
                
            readstatefromdisk()
                
            }
            else {
                print("fail to find file at \(URL)")
            }
        }
    
    }
    /* save and read the current state to disk
     *
     */
    func savestatetodisk(){
        
        let page = pdfviewer.currentPage().label()
        let scaleFactor = pdfviewer.scaleFactor().description

        let currentJumpPage = PageNumJ.stringValue
        let searchbox  = searchkey.stringValue
        
        var state_dic = [ "searchbox": searchbox,
                          "PageJump" : currentJumpPage,
                          "scale"    : scaleFactor,
                          "page"    : page
            
                ]
        for i in bookmarkarray {
        state_dic.updateValue( i , forKey: "bookmark "+i)
        }
        
        let stafile = filename!.stringByReplacingOccurrencesOfString("pdf", withString: "sta")
        
        
        let dir = stafile
        
        let path = NSURL(fileURLWithPath: dir)
        var note = ""
        for (key,value) in state_dic {
            note  += key + ":" + value+"\n"
        }
        
        do{
            try note.writeToURL(path, atomically: true, encoding: NSUTF8StringEncoding)
        }
        catch{ print("fail to write states to file")}

    
    }
    func readstatefromdisk(){
        
        let statefile = filename!.stringByReplacingOccurrencesOfString("pdf", withString: "sta")
        
        let path = NSURL(fileURLWithPath: statefile)
        var readfile : NSString?
        
        stateflag = 1
        
        do {
            readfile = try NSString(contentsOfURL: path, encoding: NSUTF8StringEncoding)
            let statearray = readfile!.componentsSeparatedByString("\n")
  
            BookmarkView.pdf = pdf
            BookmarkView.pdfviewer = pdfviewer
            bookmarkarray = []
            
            for str in statearray {
                
                if( str != ""){
                    let info = str.componentsSeparatedByString(":")
          
        
                 
                    
                    if(info[0] == "page") {
                        var page = Int(info[1])!
                        while(page>1){
                            pdfviewer.goToNextPage(self)
                            page = page - 1
                        }
                        
                    }
                    /*book mark restore failed */
                    
                    if info[0].rangeOfString("bookmark") != nil {
             
                           //  BookmarkView.add(info[1])
                             bookmarkarray.append(info[1])
                        
                        }
 
                    if(info[0] == "scale"){
                        let float = Float(info[1])
                        pdfviewer.setScaleFactor(CGFloat(float!))
                    }
                    if(info[0] == "searchbox"){
                        searchkey.stringValue = info[1]
                    }
                    if(info[0] == "PageJump"){
                        if info[1] != "" {
                        PageNumJ.integerValue = Int(info[1])!
                        }
                    }
                    
                    
                }
            }
            
        }
        catch {
            
            print("fail to read state file or state file doesnot exist")
        }
        
        
        /*layout the buttons in bookmark in asc order when read from sta file*/
        var tmp : [Int] = []
        for i in bookmarkarray{
            tmp.append(Int(i)!)
        }
        tmp = tmp.sort()
        
        for i in tmp{
            BookmarkView.add(i.description)
        }
         savestatetodisk()
        
        
    }
    /* update the window tile (page number and filename),update the notes in the notebox
     *
     */
    @objc func updateGUI(notification: NSNotification){
        
        if filename != nil {
            
        let currentPage = pdfviewer.currentPage()
        let pagenum = currentPage.label()
        pdfwindow.title = "\(filename!)"+"    Page: "+"\(pagenum)"
        
        if let oldnotes = NoteArray[pagenum]{
        NoteBox.stringValue = oldnotes
        }
        else {NoteBox.stringValue = ""}
            
            if( stateflag == 1){
                savestatetodisk()
            }
        }
    }
      
}
