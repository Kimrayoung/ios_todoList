//
//  AddTodoModal.swift
//  TodoListMission
//
//  Created by 김라영 on 2023/02/07.
//

import Foundation
import UIKit
import Alamofire
import RxAlamofire
import RxCocoa
import RxSwift

class AddTodoModal: UIViewController {
    @IBOutlet weak var addTodoPopUp: UIView!
    @IBOutlet weak var todoTextField: UITextField!
    @IBOutlet weak var todoCntErrorLabel: UILabel!

    var disposeBag = DisposeBag()
    
    //다른 곳에서 클로저를 정의할꺼니까 여기서는 클로저를 실행만 할 수 있도록 로직 빼기
    var addBtnCompletionClousre : ((AddATodoData?,_ message: String?) -> ())? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //가장 상단의 view
        view.backgroundColor = UIColor.white.withAlphaComponent(0.5)
        
        //popup뷰 코너 둥글게 만들어주기
        addTodoPopUp.layer.masksToBounds = true
        addTodoPopUp.layer.cornerRadius = 10
        todoCntErrorLabel.isHidden = true
    }
    
    @IBAction func closePopUpBtnClicked(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
    
    
    @IBAction func addPopUpBtnClicked(_ sender: UIButton) {
        guard let todoTitle = todoTextField.text else { return }
        
        let parameters = Todo(title: todoTitle, is_done: false)
        print(#fileID, #function, #line, "- parameters checking: \(parameters)")
        RxAlamofire.request(TodosRouter.addATodoJson(param: parameters))
            .data()
            .decode(type: AddATodoDataResponse.self, decoder: JSONDecoder())
            .subscribe (
                onNext: { value in
                    print(#fileID, #function, #line, "- value: \(value)")
                    if let addBtnCompletionClousre = self.addBtnCompletionClousre  {
                            if value.data == nil {
                                self.todoCntErrorLabel.text = value.message
                                self.todoCntErrorLabel.isHidden = false
                            } else {
                                addBtnCompletionClousre(value.data, value.message)
                                self.dismiss(animated: true)
                            }
                        }
                },
                onError: { Error in
                    print(#fileID, #function, #line, "- err  message:\(Error)")
                }
            )
            .disposed(by: disposeBag)
    }
    
}
