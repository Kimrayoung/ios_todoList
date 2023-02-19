//
//  ViewController.swift
//  TodoListMission
//
//  Created by 김라영 on 2023/02/06.
//

import UIKit
import Alamofire

class MainViewController: UIViewController {
    //tableView IBOutlet만들어주기
    @IBOutlet weak var todoListTableView: UITableView!
    @IBOutlet weak var selectedTodoLabel: UILabel!
    
    @IBOutlet weak var nowPageCnt: UILabel!
    var nowFetching: Bool = false //현재 새로운 페이지의 데이터를 불러와도 되는지 확인하는 변수
    
    @IBOutlet weak var selectedTodo: UILabel!
    var selectedTodoData: [Int] = []
    
    //tableview에 들어갈 데이터목록
    var todoListData: [TodoAllData] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        //table View에 셀 등록해주기
        self.todoListTableView.register(TodoCell.uiNib, forCellReuseIdentifier: TodoCell.reuseIdentifier)
        
        //dataSource넣어주기
        self.todoListTableView.dataSource = self
//        self.todoListTableView.delegate = self
        
        //todoList목록 불러오기
        requestTodoData()
    }
    
//    override func viewDidLayoutSubviews() {
//        super.viewDidLayoutSubviews()
//    }
    
    //TodoList 데이터를 받아오는 부분
    func requestTodoData() {
        print(#fileID, #function, #line, "- requestTodoData")
        AF.request(TodosRouter.fetchAll())
        //response데이터 바로 디코딩하기
        .responseDecodable (of: TotalAllResponse.self, completionHandler: { (response: DataResponse<TotalAllResponse, AFError>) in
            switch response.result {
            case .failure(let err):
                print(#fileID, #function, #line, "- err message: \(err)")
            case .success(let data):
                print(#fileID, #function, #line, "- data: \(data)")
                guard let todoData = data.data else { return }
                //데이터 몇개인지 파악하기
                let dataCnt: Int = todoData.count
                
                //데이터 개수만큼 돌려서 todoData만들어주기
                for i in 0..<dataCnt {
                    let todo = TodoAllData(id: todoData[i].id, title: todoData[i].title, content: todoData[i].content, images: todoData[i].images, isPublished: todoData[i].isPublished, createdAt: todoData[i].createdAt, updatedAt: todoData[i].updatedAt)
                    //만들어준 todoData를 tableView에 뿌려줄 데이터 list에 넣어주기
                    self.todoListData.append(todo)
                    self.todoListTableView.reloadData()
                }
                
                print(#fileID, #function, #line, "- todoListData: \(self.todoListData)")
            }
        })
    }
    
    //푸터에 스피너 만들기 -> 로딩창
    private func createSpinnerFooter() -> UIView {
        let footerView = UIView(frame:CGRect(x: 0, y: 0, width: view.frame.width, height: 70))
        
        let spinner = UIActivityIndicatorView()
        spinner.center = footerView.center
        footerView.addSubview(spinner)
        spinner.startAnimating()
        
        return footerView
    }
    
    //table view 안에는 스크롤 뷰가 포함이 되어있는데 이 스크롤뷰가 실제로 스크롤이 될때 타는 함수
    //scrollViewDidScroll
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let position = scrollView.contentOffset.y
        
        //현재 y축의 위치가 특정 위치에 도달했을 때 api를 더 호출해준다
        if position > (todoListTableView.contentSize.height - 70 - scrollView.frame.size.height) {
            //테이블 뷰의 퓨터에 스피너 붙이기
            self.todoListTableView.tableFooterView = createSpinnerFooter()
            
            //현재 현재 api호출이 아닐때만 들어올 수 있다
            if !nowFetching {
                print(#fileID, #function, #line, "- nowFetching")
                nowFetching = true //여기에 들어오면 호출 중이라는 것이므로
                if let text = self.nowPageCnt.text, let value = Int(text) {
                    print(#fileID, #function, #line, "- page chcecking: \(value + 1)")
                    AF.request(TodosRouter.fetchAll(page: value + 1))
                        .responseDecodable(of: TotalAllResponse.self) { (response: DataResponse<TotalAllResponse, AFError>) in
                            debugPrint(response)
                            self.nowPageCnt.text = String(describing: value + 1)
                            self.nowFetching = false //decoding까지 끝났으므로 다시 api호출 중이 아니라는 것을 알려야 한다
                            switch response.result {
                            case .failure(let err):
                                print(#fileID, #function, #line, "- err: \(err)")
                            case .success(let data):
                                print(#fileID, #function, #line, "- data checking: \(data)")
                                self.todoListTableView.tableFooterView = nil
                                self.todoListData.append(contentsOf: data.data!)
                                self.todoListTableView.reloadData()
                            }
                        }
                }
            }
            
        }
    }
    
    //할일 추가 버튼 클릭
    @IBAction func addTodoBtnClicked(_ sender: UIButton) {
        print(#fileID, #function, #line, "- <#comment#>")
        //스토리보드 가져오기
        let addTodoStoryboard = UIStoryboard.init(name: "AddTodoModal", bundle: nil)
        //viewController가져오기
        guard let addTodoModalVC = addTodoStoryboard.instantiateViewController(withIdentifier: AddTodoModal.withIdentifier) as? AddTodoModal else { return }
        
        //모달 띄우는 스타일 정하기
        addTodoModalVC.modalPresentationStyle = .overCurrentContext
        addTodoModalVC.modalTransitionStyle = .crossDissolve
        
        //모달 띄우기
        self.present(addTodoModalVC, animated: true)
        //클로저 정의 -> 클로저로 값을 받아서 그 값을 데이터에 넣어주기
        addTodoModalVC.addBtnCompletionClousre = { data, message in
            print(#fileID, #function, #line, "")
            guard let todoData = data else { return }
            let addTodoData = TodoAllData(id: todoData.id, title: todoData.title, content: todoData.title, images: nil, isPublished: todoData.isDone, createdAt: todoData.createdAt, updatedAt: todoData.updatedAt)
            
            self.todoListData.append(addTodoData)
            self.todoListTableView.reloadData()
        }
    }
    
}

extension MainViewController : UITableViewDataSource {
    //몇개의 section인지
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print(#fileID, #function, #line, "- todoListData.count: \(self.todoListData.count)")
        return todoListData.count
    }
    
    //어떤 셀을 만들어줄건지
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let data = todoListData[indexPath.row]
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: TodoCell.reuseIdentifier, for: indexPath) as? TodoCell else { return UITableViewCell() }
        //String(describing)을 이용해서 data.id를 String으로 변경해준다
        if let dataID: Int = data.id {
            cell.todoID.text = "todoID: \(String(describing: dataID))"
    //        할일 내용 넣어주기
            cell.todoContent.text = data.title
        }
        
        //todoCell에 있는 수정버튼 클릭했을 때 실행해줄 부분 정의해주기
        cell.editBtnClousre = {
            //수정popup스토리보드 가져오기
            let editTodoStoryboard = UIStoryboard.init(name: "EditTodoModel", bundle: nil)
            //수정팝업 뷰컨가져오기
            guard let editTodoModelVC = editTodoStoryboard.instantiateViewController(withIdentifier: EditTodoModel.withIdentifier) as? EditTodoModel else { return }
            //모달 띄우는 스타일 정하기
            editTodoModelVC.modalPresentationStyle = .overCurrentContext
            editTodoModelVC.modalTransitionStyle = .crossDissolve
            
            //수정하기 모달 보여주기
            self.present(editTodoModelVC, animated: true)
            
            //수정 팝업에서 데이터 넣어주기
            if let todoId = data.id, let todoTitle = data.title {
                //어떤 할일 이었는지 입력
                editTodoModelVC.todoId.text = "\(String(describing: todoId))" //기존 할일의 ID
                editTodoModelVC.todoOriginalLabel.text = "기존 내용: \(todoTitle)" //기존 할일의 내용
            }
            
            //수정 팝업이 닫히고 나서 cell 수정
            editTodoModelVC.editBtnCompleteClousre = { data in
                if let dataId = data.id {
                    cell.todoID.text = "todoID: \(String(describing: dataId))"
                    cell.todoContent.text = data.title
                }
            }
        }
        
        //cell에 삭제 버튼을 눌렀을 때
        cell.deleteBtnClousre = {
            AF.request(TodosRouter.deleteATodo(id: String(describing: data.id)))
                .responseDecodable (of: AddATodoDataResponse.self){ (response: DataResponse<AddATodoDataResponse, AFError>) in
                    debugPrint(response)
                    
                    switch response.result {
                    case .failure(let err):
                        print(#fileID, #function, #line, "- err: \(err)")
                    case .success(let data):
                        print(#fileID, #function, #line, "- data: \(data.data!)")
                    }
                }
            self.todoListData.remove(at: indexPath.row)
            self.todoListTableView.reloadData()
            return
        }
        
        cell.selectedSwitchClousre = { selectedBool in
            print(#fileID, #function, #line, "- \(selectedBool)")
            let data = self.todoListData[indexPath.row]
            if selectedBool {
                if let dataID = data.id {
                    self.selectedTodoData.append(dataID)
                    self.selectedTodo.text! = "\(self.selectedTodoData)"
                }
            } else {
                if let dataID = data.id {
                    self.selectedTodoData = self.selectedTodoData.filter({
                        $0 != dataID
                    })
                    self.selectedTodo.text! = "\(self.selectedTodoData)"
                }
            }
        }
        
        return cell
    }
}



