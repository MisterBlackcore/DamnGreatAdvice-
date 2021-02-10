import UIKit

class AdviceViewController: UIViewController {
    
    @IBOutlet private weak var containerView: UIView!
    @IBOutlet private weak var backgroundImageView: UIImageView!
    @IBOutlet private var containerViewConstraints: [NSLayoutConstraint]!
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    private var randomPictureNumber:String {
        let randomPictureNumber = Int.random(in: 1...4)
        return "\(randomPictureNumber)"
    }
    
    private var advices = [Advice]()
    private var isTapped = false
    private var adviceLabel:UILabel?
    private var adviceLabelConstraint:NSLayoutConstraint?
    
    //MARK: - Main functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadAdvices()
        addLabel()
        addTap()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        animateBackgroundImage(changeConstraintsTo: 35, alpha: 0)
    }
    
    //MARK: - IBActions
    
    @IBAction private func animateAdviceChange() {
        isTapped = true
        animateBackgroundImage(changeConstraintsTo: 35, alpha: 0)
    }
    
    //MARK: - Flow functions
    
    private func loadAdvices() {
        NetworkManager.shared.fetchAdvices { (advices) in
            DispatchQueue.main.async {
                self.advices = advices
            }
        }
    }
    
    private func addTap() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(animateAdviceChange))
        self.view.addGestureRecognizer(tap)
    }
    
    private func animateBackgroundImage(changeConstraintsTo size: CGFloat,alpha: CGFloat) {
        prepareBackgroundImageForAnimation(dueTo: alpha)
        changeContainterViewConstraintConstants(with: size)
        UIView.animate(withDuration: 0.3) {
            self.animateLabel(dueTo: alpha)
            self.backgroundImageView.alpha = alpha
            self.view.layoutIfNeeded()
        } completion: { (_) in
            self.completionAction(dueTo: alpha)
        }
    }
    
    private func prepareBackgroundImageForAnimation(dueTo alpha: CGFloat) {
        if alpha != 0 {
            backgroundImageView.image = UIImage(named: randomPictureNumber)
        }
    }
    
    private func changeContainterViewConstraintConstants(with value: CGFloat) {
        for constraint in containerViewConstraints {
            constraint.constant = value
        }
    }
    
    private func animateLabel(dueTo alpha: CGFloat) {
        guard let label = adviceLabel, let adviceLabelConstraint = adviceLabelConstraint else {
            return
        }
        if alpha == 1 {
            showLabel()
        }
        if alpha == 0 && isTapped {
            adviceLabelConstraint.constant = -(self.view.frame.width/2 + label.frame.size.width/2)
        }
    }
    
    private func completionAction(dueTo alpha: CGFloat) {
        guard let label = adviceLabel else {
            return
        }
        if alpha == 0 && isTapped {
            adviceLabelConstraint = nil
            label.removeFromSuperview()
        }
        if alpha == 0 {
            addLabel()
            animateBackgroundImage(changeConstraintsTo: 0, alpha: 1)
        }
    }
    
    private func showLabel() {
        guard let label = adviceLabel else {
            return
        }
        label.isHidden = false
        adviceLabelConstraint?.constant = 0
    }
    
    private func addLabel() {
        adviceLabel = createNewLabel()
        guard let label = adviceLabel else {
            return
        }
        configLabel(label)
        self.view.addSubview(label)
        setUpLabelConstraints(label)
    }
    
    private func createNewLabel() -> UILabel {
        let label = UILabel()
        label.frame.origin.x = self.view.frame.size.width
        label.frame.origin.y = self.view.frame.size.height/2 - label.frame.size.height/2
        return label
    }
    
    private func configLabel(_ label: UILabel) {
        label.numberOfLines = 0
        label.font = UIFont(name: "BebasNeueBold", size: 55.0)!
        label.adjustsFontSizeToFitWidth = true
        setUpLabelText(label)
        label.isHidden = true
        label.textColor = .white
    }
    
    private func setUpLabelConstraints(_ label: UILabel) {
        label.translatesAutoresizingMaskIntoConstraints = false
        if label.frame.size.width > self.view.frame.size.width {
            label.widthAnchor.constraint(equalToConstant: self.view.frame.size.width).isActive = true
        }
        adviceLabelConstraint = label.centerXAnchor.constraint(equalTo: self.view.centerXAnchor, constant: self.view.frame.width/2 + label.frame.size.width/2)
        adviceLabelConstraint?.isActive = true
        label.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
        label.heightAnchor.constraint(equalToConstant: self.view.frame.size.height).isActive = true
    }
    
    private func setUpLabelText(_ label: UILabel) {
        if advices.count == 0 {
            label.text = "ПОДОЖДИ,\nБЛЯТЬ!\nГРУЗИТСЯ!"
        } else {
            label.text = returnAdvice()
        }
    }
    
    private func returnAdvice() -> String {
        let randomAdviceNumber = Int.random(in: 0...advices.count - 1)
        let adviceText = advices[randomAdviceNumber].html
        guard let text = adviceText, !text.isEmpty else {
            return ""
        }
        let clearAdviceText = clearTextFromHTML(text)
        advices.remove(at: randomAdviceNumber)
        if advices.count == 0 {
            loadAdvices()
        }
        return clearAdviceText
    }
    
    private func clearTextFromHTML(_ text: String) -> String {
        let clearedText = text.replacingOccurrences(of: "<br>", with: "\n")
        let againClearedText = clearedText.replacingOccurrences(of: "<br/>", with: "\n")
        let newClearedText = againClearedText.replacingOccurrences(of: "&nbsp;", with: " ")
        return newClearedText.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression, range: nil).replacingOccurrences(of: "&[^;]+;", with: "", options:.regularExpression, range: nil)
    }
    
}
