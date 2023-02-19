//
//  EditTodoModel.swift
//  TodoListMission
//
//  Created by 김라영 on 2023/02/13.
//

import Foundation
import UIKit
import Alamofire

class EditTodoModel: UIViewController {
    @IBOutlet weak var editView: UIView!
    @IBOutlet weak var todoId: UILabel!
    @IBOutlet weak var todoOriginalLabel: UILabel!
    
    @IBOutlet weak var todoContent: UITextField!
    
    @IBOutlet weak var errMessage: UILabel!
    
    var editBtnCompleteClousre : ((AddATodoData) -> ())? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white.withAlphaComponent(0.5)
        
        editView.layer.masksToBounds = true
        editView.layer.cornerRadius = 10
        
        errMessage.isHidden = true
    }
    
    @IBAction func closePopUpBtnClicked(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
    
    @IBAction func checkPopUpBtnClicked(_ sender: UIButton) {
        let data : Todo = Todo(title: todoContent.text, is_done: false)
        
        if let todoId = todoId.text {
            AF.request(TodosRouter.editATodoJson(param: data, id: todoId))
                .responseDecodable(of: AddATodoDataResponse.self) { (response: DataResponse<AddATodoDataResponse, AFError>) in
                    debugPrint(response)
                
                    switch response.result {
                    case .failure(let err):
                        print(#fileID, #function, #line, "- err: \(err)")
                    case .success(let data):
                        print(#fileID, #function, #line, "- data: \(data)")
                        
                        if let editBtnCompleteClousre = self.editBtnCompleteClousre {
                            if  data.data == nil {
                                print(#fileID, #function, #line, "- nil?")
                                self.errMessage.text = data.message
                                self.errMessage.isHidden = false
                            } else {
                                self.dismiss(animated: true)
                                editBtnCompleteClousre(data.data!)
                            }
                        }
                        
                    }
                }
        }
        
    }
}
