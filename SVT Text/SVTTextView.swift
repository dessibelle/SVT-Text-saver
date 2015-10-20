import Foundation
import ScreenSaver
import WebKit


class SVTTextView : ScreenSaverView, WebFrameLoadDelegate {
    
    static let externalURL: NSString = "https://github.com/dessibelle/SVT-Text-saver"
    
    @IBOutlet var configSheet: NSWindow?
    @IBOutlet var intervalSlider: NSSlider?
    
    let urlFormat: String = "http://www.svt.se/svttext/tv/pages/%d.html"
    
    var reloadIntervalString: String {
        if self.intervalSlider != nil {
            let value: Int32 = self.intervalSlider!.intValue
            return String(format: "every %d second%@", value, value == 1 ? "" : "s")
        }
        
        return ""
    }
    
    var sliderValue: NSNumber? {
        willSet {
            self.willChangeValueForKey("reloadIntervalString")
        }
        didSet {
            self.didChangeValueForKey("reloadIntervalString")
        }
    }
    
    var defaults: ScreenSaverDefaults?
    var bundleIdentifier: String?
    
    var pageIsLoaded: Bool = false
    var reloadInterval: NSNumber = 5.0
    var webView: WebView = {
        WebView()
    }()
    
    func setUp(frame: NSRect) {
        
        self.defaults = ScreenSaverDefaults(forModuleWithName:"se.dessibelle.SVTTextSaver")!

        if self.defaults != nil {
            self.defaults!.registerDefaults(["ReloadInterval": 5.0])
            self.reloadInterval = self.defaults!.floatForKey("ReloadInterval")
        }
        
        if let bundleID:String = NSBundle(forClass: self.dynamicType).objectForInfoDictionaryKey("CFBundleIdentifier") as? String {
            self.bundleIdentifier = bundleID
        }
        
        self.window?.backgroundColor = NSColor.blackColor()
        
        self.webView = WebView(frame: frame)
        self.webView.frameLoadDelegate = self
        self.webView.drawsBackground = false
        self.webView.alphaValue = 0.0
        self.addSubview(self.webView)
        
        self.autoresizesSubviews = true
        self.webView.autoresizingMask = ([NSAutoresizingMaskOptions.ViewHeightSizable, NSAutoresizingMaskOptions.ViewWidthSizable, NSAutoresizingMaskOptions.ViewMinXMargin, NSAutoresizingMaskOptions.ViewMaxXMargin, NSAutoresizingMaskOptions.ViewMinYMargin, NSAutoresizingMaskOptions.ViewMaxYMargin])
    }
        
    override init?(frame: NSRect, isPreview: Bool) {
        super.init(frame: frame, isPreview: isPreview)
        
        setUp(frame)
        self.animationTimeInterval = NSTimeInterval(self.reloadInterval.floatValue)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setUp(NSZeroRect)
    }
    
    func randInRange(range: Range<UInt32>) -> UInt32 {
        return range.startIndex + arc4random_uniform(range.endIndex - range.startIndex + 1)
    }
    
    func loadPageByNumber(pageNumber: UInt32) {
        self.loadURL(self.getPageUrl(pageNumber)!)
    }
    
    func getPageUrl(pageNumber: UInt32) -> NSURL? {
        return NSURL(string: String(format: self.urlFormat, pageNumber))
    }
    
    func loadURL(url: NSURL) {
        self.pageIsLoaded = false
        self.webView.alphaValue = 0.0
        
        self.webView.mainFrame.loadRequest(NSURLRequest(URL: url))
    }
    
    func webView(sender: WebView!, didFinishLoadForFrame frame: WebFrame!) {
        if let doc: DOMDocument = self.webView.mainFrame.DOMDocument {
            if let oldBody: DOMElement = doc.querySelector("body") {
                let body: DOMElement = doc.createElement("body")
                
                if let container: DOMElement = doc.createElement("div") {
                    if let content: DOMElement = doc.querySelector("pre.root") {
                        container.setAttribute("class", value: "container")
                        container.appendChild(content)
                        body.appendChild(container)
                    }
                }
                
                if let html: DOMElement = doc.querySelector("html") {
                    html.replaceChild(body, oldChild: oldBody)
                }
                
                if let stylesheetURL: NSURL? = NSBundle(identifier: self.bundleIdentifier!)?.resourceURL?.URLByAppendingPathComponent("stylesheet").URLByAppendingPathExtension("css") {
                    
                    let link: DOMElement = doc.createElement("link")
                    
                    link.setAttribute("rel", value: "stylesheet")
                    link.setAttribute("type", value: "text/css")
                    link.setAttribute("href", value: stylesheetURL!.absoluteString)
                    
                    let head: DOMElement = doc.querySelector("head")
                    head.appendChild(link)
                }
            }
        }

        self.pageIsLoaded = true
        self.webView.alphaValue = 1.0
    }
    
    override func startAnimation() {
        super.startAnimation()
    }
    
    override func stopAnimation() {
        super.stopAnimation()
    }

    override func animateOneFrame() {
        self.loadPageByNumber(self.randInRange(100..<999))
    }
    
    override func hasConfigureSheet() -> Bool {
        return true
    }
    
    override func configureSheet() -> NSWindow? {
        if self.configSheet == nil {
            let bundle: NSBundle = NSBundle(forClass: self.dynamicType)
            let topLevelObjects: AutoreleasingUnsafeMutablePointer<NSArray?> = nil
            bundle.loadNibNamed("ConfigureSheet", owner: self, topLevelObjects: topLevelObjects)
        }
        
        self.willChangeValueForKey("reloadIntervalString")
        self.intervalSlider?.floatValue = self.reloadInterval.floatValue
        self.didChangeValueForKey("reloadIntervalString")
        
        return self.configSheet
    }
    
    @IBAction func configSheetCancelAction(sender: NSButton) {
        if let _: Void = self.configSheet?.sheetParent?.endSheet(self.configSheet!, returnCode: NSModalResponseCancel) {
            self.configSheet?.sheetParent?.endSheet(self.configSheet!, returnCode: NSModalResponseCancel)
        } else {
            NSApplication.sharedApplication().endSheet(self.configSheet!)
        }
    }
    
    @IBAction func configSheetOKAction(sender: NSButton) {
        self.reloadInterval = self.intervalSlider!.floatValue
        self.defaults!.setFloat(self.reloadInterval.floatValue, forKey: "ReloadInterval")
        self.defaults!.synchronize()
        self.animationTimeInterval = NSTimeInterval(self.reloadInterval.floatValue)
        
        self.configSheetCancelAction(sender)
    }
    
    @IBAction func configSheetGotoURLAction(sender: NSButton) {
        NSWorkspace.sharedWorkspace().openURL(NSURL(string: SVTTextView.externalURL as String)!)
    }

}
