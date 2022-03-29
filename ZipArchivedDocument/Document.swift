//
//  Document.swift
//  ZipArchivedDocument
//
//  Created by usagimaru on 2022/03/29.
//

import Cocoa
import ZIPFoundation

class Document: NSDocument {

	override init() {
	    super.init()
	}

	override class var autosavesInPlace: Bool {
		return true
	}

	override func makeWindowControllers() {
		// Returns the Storyboard that contains your Document window.
		let storyboard = NSStoryboard(name: NSStoryboard.Name("Main"), bundle: nil)
		let windowController = storyboard.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier("Document Window Controller")) as! NSWindowController
		self.addWindowController(windowController)
	}
	
	
	// MARK: - I/O
	
	private struct DocumentInfo {
		/// Define the document UTI (identifier) in the Info.plist
		static let documentUTI = "jp.usagimaru.archiveddocumentexample"
		
		/// Document content 1
		static let documentContent1 = "File1.dat"
		
		/// Document content 2
		static let documentContent2 = "File2.dat"
	}
	
	
	/// Make the temporary unique URL
	private func makeUniqueTempURL() -> URL {
		// More uniqueness
		URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(UUID().uuidString)
	}
	
	/// Read the document
	override func read(from url: URL, ofType typeName: String) throws {
		// Make new temporary directory
		let tempDirURL = makeUniqueTempURL()
		// Post process
		defer {
			try? FileManager.default.removeItem(at: tempDirURL)
		}
		
		do {
			// Unzip the document file, and read the content as a FileWrapper
			try FileManager.default.unzipItem(at: url, to: tempDirURL)
			try read(from: FileWrapper(url: tempDirURL, options: []), ofType: typeName)
		} catch {
			throw error
		}
	}
	
	private func loadDocumentContent(_ fileWrappers: [String : FileWrapper]) {
		if let file1 = fileWrappers[DocumentInfo.documentContent1]?.regularFileContents {
			let content = String(data: file1, encoding: .utf8)
			Swift.print(#function, "\(DocumentInfo.documentContent1)... \(String(describing: content))")
		}
		
		if let file2 = fileWrappers[DocumentInfo.documentContent2]?.regularFileContents {
			let content = String(data: file2, encoding: .utf8)
			Swift.print(#function, "\(DocumentInfo.documentContent2)... \(String(describing: content))")
		}
	}
	
	/// Read the document (from FileWrapper)
	override func read(from fileWrapper: FileWrapper, ofType typeName: String) throws {
#if DEBUG
		Swift.print(#function, "Loading FileWrapper `\(typeName)` ...: \(String(describing: fileWrapper.filename))")
#endif
		
		switch typeName {
			case DocumentInfo.documentUTI:
				guard let fileWrappers = fileWrapper.fileWrappers else {
					// Throw some error
					throw NSError(domain: NSOSStatusErrorDomain, code: 0, userInfo: nil)
				}
				
				loadDocumentContent(fileWrappers)
				
			case _:
				// Throw some error
				throw NSError(domain: NSOSStatusErrorDomain, code: 0, userInfo: nil)
		}
	}
	
	private func prepareFileWrapperToSave() -> FileWrapper {
		let documentFileWrapper = FileWrapper(directoryWithFileWrappers: [:])
		
		let contentData1 = "TEST".data(using: .utf8)!
		let filename1 = DocumentInfo.documentContent1
		documentFileWrapper.addRegularFile(withContents: contentData1, preferredFilename: filename1)
		
		let contentData2 = "ほげほげふがふが".data(using: .utf8)!
		let filename2 = DocumentInfo.documentContent2
		documentFileWrapper.addRegularFile(withContents: contentData2, preferredFilename: filename2)
		
		return documentFileWrapper
	}
	
	private func archivedData() throws -> Data {
		// Make new temporary directory
		let tempDirURL = makeUniqueTempURL()
		// Make another temporary directory (for archiving zip)
		let tempZipURL = makeUniqueTempURL()
		// Post processes
		defer {
			try? FileManager.default.removeItem(at: tempDirURL)
			try? FileManager.default.removeItem(at: tempZipURL)
		}
		
		// Prepare the document file wrapper (document contents)
		let documentFileWrapper = prepareFileWrapperToSave()
		
		do {
			// Write the documentFileWrapper temporary
			try documentFileWrapper.write(to: tempDirURL, options: [], originalContentsURL: nil)
			
			// Make the zip archive (or set the compression method)
			let compression: CompressionMethod = .none // .deflate
			try FileManager.default.zipItem(at: tempDirURL,
											to: tempZipURL,
											shouldKeepParent: false,
											compressionMethod: compression)
			
			// Make and return the data object from the zip file
			return try Data(contentsOf: tempZipURL)
			
		} catch {
			throw error
		}
	}
	
	/// Write the document to data
	override func data(ofType typeName: String) throws -> Data {
		// Insert code here to write your document to data of the specified type, throwing an error in case of failure.
		// Alternatively, you could remove this method and override fileWrapper(ofType:), write(to:ofType:), or write(to:ofType:for:originalContentsURL:) instead.
		//throw NSError(domain: NSOSStatusErrorDomain, code: unimpErr, userInfo: nil)
		
		switch typeName {
			case DocumentInfo.documentUTI:
				do {
					return try archivedData()
				} catch {
					throw error
				}
				
			case _:
				// Throw some error
				throw NSError(domain: NSOSStatusErrorDomain, code: 0, userInfo: nil)
		}
	}

}

