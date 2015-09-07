import Foundation
import ScreenSaver
import WebKit


class SVTTextView : ScreenSaverView {
    
    let urlFormat: String = "http://www.svt.se/svttext/tv/pages/%d.html"
    
    var pageIsLoaded: Bool = false
    var webView: WebView = {
        WebView()
    }()
    
    func setUp(frame: NSRect) {
        self.webView = WebView(frame: frame)
        self.webView.frameLoadDelegate = self
        self.webView.alphaValue = 0.0
        self.addSubview(self.webView)
        
        self.autoresizesSubviews = true
        self.webView.autoresizingMask = (NSAutoresizingMaskOptions.ViewHeightSizable|NSAutoresizingMaskOptions.ViewWidthSizable|NSAutoresizingMaskOptions.ViewMinXMargin|NSAutoresizingMaskOptions.ViewMaxXMargin|NSAutoresizingMaskOptions.ViewMinYMargin|NSAutoresizingMaskOptions.ViewMaxYMargin)
    }
    
    convenience init() {
        self.init(frame: CGRectZero, isPreview: false)
    }
    
    override init(frame: NSRect, isPreview: Bool) {
        super.init(frame: frame, isPreview: isPreview)
        
        setUp(frame)
        setAnimationTimeInterval(5.0)
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
        
        if (stylesheetURL != nil) {
            var link: DOMElement = doc.createElement("link")
            
            link.setAttribute("rel", value: "stylesheet")
            link.setAttribute("type", value: "text/css")
            link.setAttribute("href", value: stylesheetURL!.absoluteString!)

            var head: DOMElement = doc.querySelector("head")
            head.appendChild(link)
        }
        
        self.pageIsLoaded = true
        self.webView.alphaValue = 1.0
        
        self.needsDisplay = true
    }
    
    override func startAnimation() {
        super.startAnimation()
    }
    
    override func stopAnimation() {
        super.stopAnimation()
    }
    
    override func drawRect(rect: NSRect) {
        if (self.webView.frame == NSZeroRect) {
            self.webView.frame = rect
        }
        
//        if (!self.pageIsLoaded) {
//            NSColor.blackColor().set()
//            NSRectFill(rect)
//        }
        
        super.drawRect(rect)
    }
    
    override func animateOneFrame() {
        self.loadPageByNumber(self.randInRange(100..<999))
    }
    
    override func hasConfigureSheet() -> Bool {
        return false
    }
    
    override func configureSheet() -> NSWindow? {
        return nil
    }
}
