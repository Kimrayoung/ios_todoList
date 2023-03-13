//
//  EditTodoModel.swift
//  TodoListMission
//
//  Created by 김라영 on 2023/02/13.
//

import Foundation
import UIKit
import Alamofire
import RxSwift
import RxCocoa
import RxAlamofire

class EditTodoModel: UIViewController {
    @IBOutlet weak var editView: UIView!
    @IBOutlet weak var todoId: UILabel!
    @IBOutlet weak var todoOriginalLabel: UILabel!
    
    @IBOutlet weak var todoContent: UITextField!
    
    @IBOutlet weak var errMessage: UILabel!
    var disposeBag = DisposeBag()
    
//    var editBtnCompleteClousre : ((AddATodoData) -> ())? = nil
    var editBtnCompleteClousre : ((_ indexPathRow: Int, _ todoId: Int, _ todoTitle: String) -> ())? = nil
    var indexPathRow: Int? = nil
    
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
        
//        todoId.rx.text -> 뭔가 여기를 text가 있다면 이니까 rx로 바꿀 수 있지 않을까?
        if let todoId = todoId.text {
            RxAlamofire.request(TodosRouter.editATodoJson(param: data, id: todoId))
                .data()
                .decode(type: AddATodoDataResponse.self, decoder: JSONDecoder())
                .subscribe (
                    onNext: { value in
                        print(#fileID, #function, #line, "- value: \(value)")
                        if let editBtnCompleteClousre = self.editBtnCompleteClousre {
                            if  value.data == nil {
                                print(#fileID, #function, #line, "- nil?")
                                self.errMessage.text = value.message
                                self.errMessage.isHidden = false
                            } else {
                                self.dismiss(animated: true)
                                editBtnCompleteClousre(self.indexPathRow!, (value.data?.id!)!, (value.data?.title!)!)
                            }
                        }
                    },
                    onError: { error in
                        print(#fileID, #function, #line, "- err message: \(error)")
                    }
                )
                .disposed(by: disposeBag)
        }
        
    }
}
