import Foundation
import ScreenSaver
import WebKit


class SVTTextView : ScreenSaverView {
    
    static let externalURL: NSString = "https://github.com/dessibelle/SVT-Text-saver"
    
    @IBOutlet var configSheet: NSWindow?
    @IBOutlet var intervalSlider: NSSlider?
    
    let urlFormat: String = "http://www.svt.se/svttext/tv/pages/%d.html"
    
    var reloadIntervalString: String {
        if self.intervalSlider != nil {
            var value: Int32 = self.intervalSlider!.intValue
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
    
    var defaults: ScreenSaverDefaults
    
    var pageIsLoaded: Bool = false
    var reloadInterval: NSNumber = 5.0
    var webView: WebView = {
        WebView()
    }()
    
    func setUp(frame: NSRect) {
        self.defaults.registerDefaults(["ReloadInterval": 5.0])
        self.reloadInterval = self.defaults.floatForKey("ReloadInterval")
        
        self.window?.backgroundColor = NSColor.blackColor()
        
        self.webView = WebView(frame: frame)
        self.webView.frameLoadDelegate = self
        self.webView.drawsBackground = false
        self.webView.alphaValue = 0.0
        self.addSubview(self.webView)
        
        self.autoresizesSubviews = true
        self.webView.autoresizingMask = (NSAutoresizingMaskOptions.ViewHeightSizable|NSAutoresizingMaskOptions.ViewWidthSizable|NSAutoresizingMaskOptions.ViewMinXMargin|NSAutoresizingMaskOptions.ViewMaxXMargin|NSAutoresizingMaskOptions.ViewMinYMargin|NSAutoresizingMaskOptions.ViewMaxYMargin)
    }
    
    convenience init() {
        self.init(frame: CGRectZero, isPreview: false)
    }
    
    override init(frame: NSRect, isPreview: Bool) {
        self.defaults = ScreenSaverDefaults.defaultsForModuleWithName("SVTTextSaver") as! ScreenSaverDefaults
        super.init(frame: frame, isPreview: isPreview)
        
        setUp(frame)
        setAnimationTimeInterval(NSTimeInterval(self.reloadInterval.floatValue))
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.defaults = ScreenSaverDefaults.defaultsForModuleWithName("SVTTextSaver") as! ScreenSaverDefaults
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
    
    override func webView(sender: WebView!, didFinishLoadForFrame frame: WebFrame!) {
        var doc: DOMDocument = self.webView.mainFrame.DOMDocument
        var content: DOMElement = doc.querySelector("pre.root")
        
        var oldBody: DOMElement = doc.querySelector("body")
        var body: DOMElement = doc.createElement("body")
        var container: DOMElement = doc.createElement("div")
        container.setAttribute("class", value: "container")
        
        container.appendChild(content)
        body.appendChild(container)
        
        var html: DOMElement = doc.querySelector("html")
        html.replaceChild(body, oldChild: oldBody)
        
        var bundleIdentifier: String = NSBundle(forClass: self.dynamicType).objectForInfoDictionaryKey("CFBundleIdentifier") as! String
        
        var stylesheetURL: NSURL? = NSBundle(identifier: bundleIdentifier)?.resourceURL?.URLByAppendingPathComponent("stylesheet").URLByAppendingPathExtension("css")
        
        if stylesheetURL != nil {
            var link: DOMElement = doc.createElement("link")
            
            link.setAttribute("rel", value: "stylesheet")
            link.setAttribute("type", value: "text/css")
            link.setAttribute("href", value: stylesheetURL!.absoluteString!)

            var head: DOMElement = doc.querySelector("head")
            head.appendChild(link)
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
            var bundle: NSBundle = NSBundle(forClass: self.dynamicType)
            var topLevelObjects: AutoreleasingUnsafeMutablePointer<NSArray?> = nil
            var loadStatus: Bool = bundle.loadNibNamed("ConfigureSheet", owner: self, topLevelObjects: topLevelObjects)
        }
        
        self.willChangeValueForKey("reloadIntervalString")
        self.intervalSlider?.floatValue = self.reloadInterval.floatValue
        self.didChangeValueForKey("reloadIntervalString")
        
        return self.configSheet
    }
    
    @IBAction func configSheetCancelAction(sender: NSButton) {
        if let result: Void = self.configSheet?.sheetParent?.endSheet(self.configSheet!, returnCode: NSModalResponseCancel) {
            self.configSheet?.sheetParent?.endSheet(self.configSheet!, returnCode: NSModalResponseCancel)
        } else {
            NSApplication.sharedApplication().endSheet(self.configSheet!)
        }
    }
    
    @IBAction func configSheetOKAction(sender: NSButton) {
        self.reloadInterval = self.intervalSlider!.floatValue
        self.defaults.setFloat(self.reloadInterval.floatValue, forKey: "ReloadInterval")
        self.defaults.synchronize()
        setAnimationTimeInterval(NSTimeInterval(self.reloadInterval.floatValue))
        
        self.configSheetCancelAction(sender)
    }
    
    @IBAction func configSheetGotoURLAction(sender: NSButton) {
        NSWorkspace.sharedWorkspace().openURL(NSURL(string: SVTTextView.externalURL as String)!)
    }

}
