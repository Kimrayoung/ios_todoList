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
    
    var editBtnClousre : ((_ id: Int, _ title: String, _ indexPathRow: Int) -> ())? = nil
    var deleteBtnClousre: ((_ id: Int, _ indexPathRow: Int) -> ())? = nil
    var indexPathRow: Int? = nil
    var selectedSwitchClousre: ((_ id: Int, _ indexPathRow: Int, _ selectedBool: Bool) -> ())? = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()
        editBtn.addTarget(self, action: #selector(editBtnClicked(_ :)), for: .touchUpInside)
        deleteBtn.addTarget(self, action: #selector(deleteBtnClicked(_ :)), for: .touchUpInside)
        selectedSwitch.addTarget(self, action: #selector(selectedSwitchClicked(_ :)), for: .touchUpInside)
    }
    
    //UI에 데이터를 넣어주는 부분
    func configureUI(data: TodoAllData, indexPathRow: Int, deleteAction: @escaping (Int, Int) -> (), editAction: @escaping (Int, String, Int) -> (), selectedSwithAction: @escaping (Int, Int, Bool) -> ()) {
        if let dataID: Int = data.id {
            todoID.text = "todoID: \(String(describing: dataID))"
            todoID.tag = dataID
    //        할일 내용 넣어주기
            todoContent.text = data.title
        }
        self.indexPathRow = indexPathRow
        
        //deleteBtnClousre이 어떤 역할을 해줄지 미리 정해준다
        self.deleteBtnClousre = deleteAction //이거는 실제로는 viewController에 있는 cellDeleteAction함수가 실행되는 것이라고 생각하면 된다
        self.editBtnClousre = editAction
        
        self.selectedSwitchClousre = selectedSwithAction
    }
    
    //tableviewCell에 수정버튼 클릭시
    @objc func editBtnClicked(_ sender: UIButton!) {
        print(#fileID, #function, #line, "- todoId: \(todoID.text ?? "0")")
        if let editBtnClousre = self.editBtnClousre {
            editBtnClousre(todoID.tag, todoContent.text ?? "내용 없음", indexPathRow!)
        }
    }
    
    //tableviewCell에 삭제버튼 클릭
    @objc func deleteBtnClicked(_ sender: UIButton!) {
        print(#fileID, #function, #line, "- ")
        if let deleteBtnClousre = self.deleteBtnClousre,
           let indexPathRow = self.indexPathRow {
            deleteBtnClousre(todoID.tag, indexPathRow) //이때 configureUI에 정의해준 deleteBtnClousre가 실행된다
        }
    }
    
    //switchBtn클릭
    @objc func selectedSwitchClicked(_ sender: UISwitch!) {
        print(#fileID, #function, #line, "- selectedSwitch, \(sender.isOn)")
        if let selectedSwitchClousre = self.selectedSwitchClousre {
            selectedSwitchClousre(todoID.tag, indexPathRow!, sender.isOn)
        }
    }
}
