//
//  TodoCell.swift
//  TodoListMission
//
//  Created by 김라영 on 2023/02/06.
//

import Foundation
import UIKit
import Alamofire

class TodoCell: UITableViewCell {
    @IBOutlet weak var todoID: UILabel!
    @IBOutlet weak var todoContent: UILabel!
    
    @IBOutlet weak var editBtn: UIButton!
    @IBOutlet weak var deleteBtn: UIButton!
    
    @IBOutlet weak var selectedSwitch: UISwitch!
    
    var editBtnClousre : (() -> ())? = nil
    var deleteBtnClousre: (() -> ())? = nil
    var selectedSwitchClousre: ((_ selectedBool: Bool) -> ())? = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()
        editBtn.addTarget(self, action: #selector(editBtnClicked(_ :)), for: .touchUpInside)
        deleteBtn.addTarget(self, action: #selector(deleteBtnClicked(_ :)), for: .touchUpInside)
        selectedSwitch.addTarget(self, action: #selector(selectedSwitchClicked(_ :)), for: .touchUpInside)
    }
    
    //tableviewCell에 수정버튼 클릭시
    @objc func editBtnClicked(_ sender: UIButton!) {
        print(#fileID, #function, #line, "- todoId: \(todoID.text ?? "0")")
        if let editBtnClousre = self.editBtnClousre {
            editBtnClousre()
        }
    }
    
    //tableviewCell에 삭제버튼 클릭
    @objc func deleteBtnClicked(_ sender: UIButton!) {
        print(#fileID, #function, #line, "- ")
        if let deleteBtnClousre = self.deleteBtnClousre {
            deleteBtnClousre()
        }
    }
    
    //switchBtn클릭
    @objc func selectedSwitchClicked(_ sender: UISwitch!) {
        print(#fileID, #function, #line, "- selectedSwitch, \(sender.isOn)")
        if let selectedSwitchClousre = self.selectedSwitchClousre {
            selectedSwitchClousre(sender.isOn)
        }
    }
}
