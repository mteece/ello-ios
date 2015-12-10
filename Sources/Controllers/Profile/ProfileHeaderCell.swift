//
//  ProfileHeaderCell.swift
//  Ello
//
//  Created by Ryan Boyajian on 2/12/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import UIKit
import Foundation

@objc
public protocol EditProfileResponder {
    func onEditProfile()
}

@objc
public protocol PostsTappedResponder {
    func onPostsTapped()
}

public class ProfileHeaderCell: UICollectionViewCell {
    typealias WebContentReady = (webView : UIWebView) -> Void

    // this little hack prevents constraints from breaking on initial load
    override public var bounds: CGRect {
        didSet {
          contentView.frame = bounds
        }
    }

    @IBOutlet weak var avatarButton: AvatarButton!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var viewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var bioWebView: UIWebView!
    @IBOutlet weak var postsButton: TwoLineButton!
    @IBOutlet weak var followersButton: TwoLineButton!
    @IBOutlet weak var followingButton: TwoLineButton!
    @IBOutlet weak var lovesButton: TwoLineButton!

    weak var webLinkDelegate: WebLinkDelegate?
    weak var simpleStreamDelegate: SimpleStreamDelegate?
    var user: User? {
        didSet {
            avatarButton.setUser(user)
        }
    }
    var currentUser: User?
    var webContentReady: WebContentReady?

    override public func awakeFromNib() {
        super.awakeFromNib()
        style()
        bioWebView.delegate = self
        avatarButton.starIconHidden = true
    }

    func onWebContentReady(handler: WebContentReady?) {
        webContentReady = handler
    }

    override public func layoutSubviews() {
        super.layoutSubviews()
        bioWebView.scrollView.scrollEnabled = false
        bioWebView.scrollView.scrollsToTop = false
    }

    override public func prepareForReuse() {
        super.prepareForReuse()
        bioWebView.stopLoading()
    }

    func setAvatarImage(image: UIImage) {
        avatarButton.pin_cancelImageDownload()
        avatarButton.setImage(image, forState: .Normal)
    }

    private func style() {
        usernameLabel.font = UIFont.regularBoldFont(18.0)
        usernameLabel.textColor = UIColor.blackColor()

        nameLabel.font = UIFont.typewriterFont(12.0)
        nameLabel.textColor = UIColor.greyA()
    }

    @IBAction func editProfileTapped(sender: UIButton) {
        let responder = targetForAction("onEditProfile", withSender: self) as? EditProfileResponder
        responder?.onEditProfile()
    }

    @IBAction func followingTapped(sender: UIButton) {
        if let user = user {
            let noResultsTitle: String
            let noResultsBody: String
            if user.id == currentUser?.id {
                noResultsTitle = InterfaceString.Following.CurrentUserNoResultsTitle.localized
                noResultsBody = InterfaceString.Following.CurrentUserNoResultsBody.localized
            }
            else {
                noResultsTitle = InterfaceString.Following.NoResultsTitle.localized
                noResultsBody = InterfaceString.Following.NoResultsBody.localized
            }
            simpleStreamDelegate?.showSimpleStream(.UserStreamFollowing(userId: user.id), title: InterfaceString.Following.Title.localized, noResultsMessages: (title: noResultsTitle, body: noResultsBody))
        }
    }

    @IBAction func followersTapped(sender: UIButton) {
        if let user = user {
            let noResultsTitle: String
            let noResultsBody: String
            if user.id == currentUser?.id {
                noResultsTitle = InterfaceString.Followers.CurrentUserNoResultsTitle.localized
                noResultsBody = InterfaceString.Followers.CurrentUserNoResultsBody.localized
            }
            else {
                noResultsTitle = InterfaceString.Followers.NoResultsTitle.localized
                noResultsBody = InterfaceString.Followers.NoResultsBody.localized
            }
            simpleStreamDelegate?.showSimpleStream(.UserStreamFollowers(userId: user.id), title: InterfaceString.Followers.Title.localized, noResultsMessages: (title: noResultsTitle, body: noResultsBody))
        }
    }

    @IBAction func lovesTapped(sender: UIButton) {
        if let user = user {
            let noResultsTitle: String
            let noResultsBody: String
            if user.id == currentUser?.id {
                noResultsTitle = InterfaceString.Loves.CurrentUserNoResultsTitle.localized
                noResultsBody = InterfaceString.Loves.CurrentUserNoResultsBody.localized
            }
            else {
                noResultsTitle = InterfaceString.Loves.NoResultsTitle.localized
                noResultsBody = InterfaceString.Loves.NoResultsBody.localized
            }
            simpleStreamDelegate?.showSimpleStream(.Loves(userId: user.id), title: InterfaceString.Loves.Title.localized, noResultsMessages: (title: noResultsTitle, body: noResultsBody))
        }
    }

    @IBAction func postsTapped(sender: UIButton) {
        let responder = targetForAction("onPostsTapped", withSender: self) as? PostsTappedResponder
        responder?.onPostsTapped()
    }
}

extension ProfileHeaderCell: UIWebViewDelegate {
    public func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        return ElloWebViewHelper.handleRequest(request, webLinkDelegate: webLinkDelegate)
    }

    public func webViewDidFinishLoad(webView: UIWebView) {
        UIView.animateWithDuration(0.15) {
            self.contentView.alpha = 1.0
        }
        webContentReady?(webView: webView)
    }
}
