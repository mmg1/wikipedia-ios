import UIKit
import WMF

@objc (WMFArticlePeekPreviewViewController)
class ArticlePeekPreviewViewController: UIViewController {
    
    fileprivate let articleURL: URL
    fileprivate let dataStore: MWKDataStore
    fileprivate var theme: Theme

    @IBOutlet weak var leadImageView: UIImageView!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var textLabel: UILabel!
    
    @objc required init(articleURL: URL, dataStore: MWKDataStore, theme: Theme) {
        self.articleURL = articleURL
        self.dataStore = dataStore
        self.theme = theme
        super.init(nibName: "ArticlePeekPreviewViewController", bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        return nil
    }
    
    func fetchArticle() {
       let articleFetcher = WMFArticleFetcher(dataStore: dataStore)
        
        articleFetcher.fetchLatestVersionOfArticle(with: articleURL, forceDownload: false, saveToDisk: false, progress: nil, failure: { (error) in
            
            if let cashedFallback = (error as NSError).userInfo[WMFArticleFetcherErrorCachedFallbackArticleKey] as? MWKArticle {
                self.updateView(with: cashedFallback)
            }

        }) { (article) in
            self.updateView(with: article)
        }
        
    }
    
    func updateView(with article: MWKArticle) {
        guard let imageURL = article.imageURL, let url = URL(string: imageURL), let title = article.displaytitle, let description = article.entityDescription, let summary = article.summary else {
            return
        }
        
        self.leadImageView.wmf_setImage(with: url, detectFaces: true, onGPU: true, failure: { (error) in
            //handle error
        }, success: {
            //handle success
        })
        self.titleLabel.text = title
        self.descriptionLabel.text = description
        self.textLabel.text = summary
    }
    
    override func viewDidLoad() {
        fetchArticle()
        updateFonts()
        apply(theme: theme)
    }
    
    func updateFonts() {
        titleLabel.setFont(with: .georgia, style: .title1, traitCollection: traitCollection)
        descriptionLabel.setFont(with: .system, style: .subheadline, traitCollection: traitCollection)
        textLabel.setFont(with: .system, style: .subheadline, traitCollection: traitCollection)
        textLabel.lineBreakMode = .byTruncatingTail
        
        if #available(iOS 11.0, *) {
            leadImageView.accessibilityIgnoresInvertColors = true
        }
    }
}

extension ArticlePeekPreviewViewController: Themeable {
    func apply(theme: Theme) {
        self.theme = theme
        view.backgroundColor = theme.colors.paperBackground
        titleLabel.textColor = theme.colors.primaryText
        descriptionLabel.textColor = theme.colors.secondaryText
        headerView.backgroundColor = theme.colors.midBackground
        textLabel.textColor = theme.colors.primaryText
    }
}
