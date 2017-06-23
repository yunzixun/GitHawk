//
//  IssueCommentReactionCell.swift
//  Freetime
//
//  Created by Ryan Nystrom on 5/29/17.
//  Copyright © 2017 Ryan Nystrom. All rights reserved.
//

import UIKit
import SnapKit
import IGListKit

protocol IssueCommentReactionCellDelegate {
    func didAdd(cell: IssueCommentReactionCell, reaction: ReactionContent)
    func didRemove(cell: IssueCommentReactionCell, reaction: ReactionContent)
}

final class IssueCommentReactionCell: UICollectionViewCell,
ListBindable,
UICollectionViewDataSource,
UICollectionViewDelegateFlowLayout {

    static let reuse = "cell"

    public var delegate: IssueCommentReactionCellDelegate? = nil

    private let addButton = ResponderButton()
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.register(IssueReactionCell.self, forCellWithReuseIdentifier: IssueCommentReactionCell.reuse)
        return view
    }()
    private var reactions = [ReactionViewModel]()

    override init(frame: CGRect) {
        super.init(frame: frame)

        contentView.backgroundColor = .white

        addButton.tintColor = Styles.Colors.Gray.light.color
        addButton.setTitle("+", for: .normal)
        addButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: -5, bottom: 0, right: 0)
        addButton.setTitleColor(Styles.Colors.Gray.light.color, for: .normal)
        addButton.semanticContentAttribute = .forceRightToLeft
        addButton.setImage(UIImage(named: "smiley-small")?.withRenderingMode(.alwaysTemplate), for: .normal)
        addButton.addTarget(self, action: #selector(IssueCommentReactionCell.onAddButton), for: .touchUpInside)
        contentView.addSubview(addButton)
        addButton.snp.makeConstraints { make in
            make.left.equalTo(Styles.Sizes.gutter)
            make.centerY.equalTo(contentView)
        }

        collectionView.backgroundColor = .clear
        collectionView.dataSource = self
        collectionView.delegate = self
        contentView.addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.left.equalTo(addButton.snp.right).offset(Styles.Sizes.columnSpacing)
            make.top.bottom.right.equalTo(contentView)
        }

        contentView.addBorder(bottom: false)
        contentView.addBorder(bottom: true)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Private API

    func onAddButton() {
        addButton.becomeFirstResponder()

        let actions = [
            (ReactionContent.thumbsUp.emoji, #selector(IssueCommentReactionCell.onThumbsUp)),
            (ReactionContent.thumbsDown.emoji, #selector(IssueCommentReactionCell.onThumbsDown)),
            (ReactionContent.laugh.emoji, #selector(IssueCommentReactionCell.onLaugh)),
            (ReactionContent.hooray.emoji, #selector(IssueCommentReactionCell.onHooray)),
            (ReactionContent.confused.emoji, #selector(IssueCommentReactionCell.onConfused)),
            (ReactionContent.heart.emoji, #selector(IssueCommentReactionCell.onHeart)),
        ]

        let menu = UIMenuController.shared
        menu.menuItems = actions.map { UIMenuItem(title: $0.0, action: $0.1) }
        menu.setTargetRect(addButton.imageView?.frame ?? .zero, in: addButton)
        menu.setMenuVisible(true, animated: true)
    }

    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        switch action {
        case #selector(IssueCommentReactionCell.onThumbsUp),
             #selector(IssueCommentReactionCell.onThumbsDown),
             #selector(IssueCommentReactionCell.onLaugh),
             #selector(IssueCommentReactionCell.onHooray),
             #selector(IssueCommentReactionCell.onConfused),
             #selector(IssueCommentReactionCell.onHeart):
            return true
        default: return false
        }
    }

    func onThumbsUp() {
        delegate?.didAdd(cell: self, reaction: .thumbsUp)
    }

    func onThumbsDown() {
        delegate?.didAdd(cell: self, reaction: .thumbsDown)
    }

    func onLaugh() {
        delegate?.didAdd(cell: self, reaction: .laugh)
    }

    func onHooray() {
        delegate?.didAdd(cell: self, reaction: .hooray)
    }

    func onConfused() {
        delegate?.didAdd(cell: self, reaction: .confused)
    }

    func onHeart() {
        delegate?.didAdd(cell: self, reaction: .heart)
    }

    // MARK: ListBindable

    func bindViewModel(_ viewModel: Any) {
        guard let viewModel = viewModel as? IssueCommentReactionViewModel else { return }
        reactions = viewModel.models
        collectionView.reloadData()
    }

    // MARK: UICollectionViewDataSource

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return reactions.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: IssueCommentReactionCell.reuse,
            for: indexPath
            ) as! IssueReactionCell
        let model = reactions[indexPath.item]
        cell.label.text = "\(model.content.emoji) \(model.count)"
        cell.contentView.backgroundColor = model.viewerDidReact ? Styles.Colors.Blue.light.color : .clear
        return cell
    }

    // MARK: UICollectionViewDelegateFlowLayout

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
        ) -> CGSize {
        let modifier = CGFloat(reactions[indexPath.item].count.description.characters.count - 1)
        return CGSize(width: 50 + modifier * 5, height: collectionView.bounds.height)
    }

    // MARK: UICollectionViewDelegate

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let model = reactions[indexPath.item]
        if model.viewerDidReact {
            delegate?.didRemove(cell: self, reaction: model.content)
        } else {
            delegate?.didAdd(cell: self, reaction: model.content)
        }
    }

}
