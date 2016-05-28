//
//  Document.swift
//  Notes
//
//  Created by Chris Ritter on 25/05/2016.
//  Copyright © 2016 Ridaste Software Enterprises. All rights reserved.
//

import Cocoa

extension NSFileWrapper {
    
    dynamic var fileExtension : String? {
        return self.preferredFilename?.componentsSeparatedByString(".").last
    }
    
    dynamic var thumbnailImage : NSImage {
        if let fileExtension = self.fileExtension {
            return NSWorkspace.sharedWorkspace().iconForFileType(fileExtension)
        } else {
            return NSWorkspace.sharedWorkspace().iconForFileType("")
        }
    }
    
    func conformsToType(type: CFString) -> Bool {
        guard let fileExtension = self.fileExtension else {
            return false
        }
        guard let fileType = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, fileExtension, nil)?.takeRetainedValue() else {
            return false
        }
        return UTTypeConformsTo(fileType, type)
    }
}

enum NoteDocumentFileNames : String {
    // Names of files/directories in the package
    case TextFile = "Text.rtf"
    case AttachmentsDirectory = "Attachments"
}

enum ErrorCode : Int {
    /// We couldn't find the document at all.
    case CannotAccessDocument
    /// We couldn't access any file wrappers inside this document.
    case CannotLoadFileWrappers
    /// We couldn't load the Text.rtf file.
    case CannotLoadText
    /// We couldn't access the Attachments folder.
    case CannotAccessAttachments
    /// We couldn't save the Text.rtf file.
    case CannotSaveText
    /// We couldn't save an attachment.
    case CannotSaveAttachment
}

let ErrorDomain = "NotesErrorDomain"

func err(code: ErrorCode, _ userInfo: [NSObject:AnyObject]? = nil) -> NSError {
    // Generate an NSError object, using ErrorDomain and whatever value we were passed.
    return NSError(domain: ErrorDomain, code: code.rawValue, userInfo: userInfo)
}

class Document: NSDocument {

    var text : NSAttributedString = NSAttributedString()
    var documentFileWrapper = NSFileWrapper(directoryWithFileWrappers: [:])
    
    private var attachmentsDirectoryWrapper : NSFileWrapper? {
        
        guard let fileWrappers = self.documentFileWrapper.fileWrappers else {
            NSLog("Attempting to access document's contents, but none found!")
            return nil
        }
        
        var attachmentsDirectoryWrapper = fileWrappers[NoteDocumentFileNames.AttachmentsDirectory.rawValue]
        
        if attachmentsDirectoryWrapper == nil {
            attachmentsDirectoryWrapper = NSFileWrapper(directoryWithFileWrappers: [:])
            attachmentsDirectoryWrapper?.preferredFilename = NoteDocumentFileNames.AttachmentsDirectory.rawValue
            self.documentFileWrapper.addFileWrapper(attachmentsDirectoryWrapper!)
        }
        
        return attachmentsDirectoryWrapper
    }
    
    dynamic var attachedFiles : [NSFileWrapper]? {
        
        if let attachmentsFileWrappers = self.attachmentsDirectoryWrapper?.fileWrappers {
            let attachments = Array(attachmentsFileWrappers.values)
            
            return attachments
            
        } else {
            return nil
        }
    }
    
    var popover : NSPopover?
    
    @IBOutlet var attachmentsList: NSCollectionView!
    
    override init() {
        super.init()
        // Add your subclass-specific initialization here.
    }
    
    override func fileWrapperOfType(typeName: String) throws -> NSFileWrapper {
        let textRTFData = try self.text.dataFromRange(NSRange(0..<self.text.length), documentAttributes: [NSDocumentTypeDocumentAttribute: NSRTFTextDocumentType])
        if let oldTextFileWrapper = self.documentFileWrapper.fileWrappers?[NoteDocumentFileNames.TextFile.rawValue] {
            self.documentFileWrapper.removeFileWrapper(oldTextFileWrapper)
        }
        self.documentFileWrapper.addRegularFileWithContents(textRTFData, preferredFilename: NoteDocumentFileNames.TextFile.rawValue)
        return self.documentFileWrapper
    }
    
    override func readFromFileWrapper(fileWrapper: NSFileWrapper, ofType typeName: String) throws {
        guard let fileWrappers = fileWrapper.fileWrappers else {
            throw err(.CannotLoadFileWrappers)
        }
        guard let documentTextData = fileWrappers[NoteDocumentFileNames.TextFile.rawValue]?.regularFileContents else {
            throw err(.CannotLoadText)
        }
        guard let documentText = NSAttributedString(RTF: documentTextData, documentAttributes: nil) else {
            throw err(.CannotLoadText)
        }
        self.documentFileWrapper = fileWrapper
        self.text = documentText
    }
    
    func addAttachmentAtURL(url:NSURL) throws {
        
        guard attachmentsDirectoryWrapper != nil else {
            throw err(.CannotAccessAttachments)
        }
        
        self.willChangeValueForKey("attachedFiles")
        
        let newAttachment = try NSFileWrapper(URL: url, options: NSFileWrapperReadingOptions.Immediate)
        
        attachmentsDirectoryWrapper?.addFileWrapper(newAttachment)
        self.updateChangeCount(.ChangeDone)
        self.didChangeValueForKey("attachedFiles")
    }

    override class func autosavesInPlace() -> Bool {
        return true
    }

    @IBAction func addAttachment(sender: NSButton) {
        
        if let viewController = AddAttachmentViewController(nibName: "AddAttachmentViewController", bundle: NSBundle.mainBundle()) {
            self.popover = NSPopover()
            self.popover?.behavior = .Transient
            self.popover?.contentViewController = viewController
            self.popover?.showRelativeToRect(sender.bounds, ofView: sender, preferredEdge: NSRectEdge.MaxY)
        }
    }
    
    override var windowNibName: String? {
        // Returns the nib file name of the document
        // If you need to use a subclass of NSWindowController or if your document supports multiple NSWindowControllers, you should remove this property and override -makeWindowControllers instead.
        return "Document"
    }

    override func dataOfType(typeName: String) throws -> NSData {
        // Insert code here to write your document to data of the specified type. If outError != nil, ensure that you create and set an appropriate error when returning nil.
        // You can also choose to override fileWrapperOfType:error:, writeToURL:ofType:error:, or writeToURL:ofType:forSaveOperation:originalContentsURL:error: instead.
        throw NSError(domain: NSOSStatusErrorDomain, code: unimpErr, userInfo: nil)
    }

    override func readFromData(data: NSData, ofType typeName: String) throws {
        // Insert code here to read your document from the given data of the specified type. If outError != nil, ensure that you create and set an appropriate error when returning false.
        // You can also choose to override readFromFileWrapper:ofType:error: or readFromURL:ofType:error: instead.
        // If you override either of these, you should also override -isEntireFileLoaded to return false if the contents are lazily loaded.
        throw NSError(domain: NSOSStatusErrorDomain, code: unimpErr, userInfo: nil)
    }


}

