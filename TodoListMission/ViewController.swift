//
//  ViewController.swift
//  TodoListMission
//
//  Created by 김라영 on 2023/02/06.
//

import UIKit
import Alamofire
import RxSwift
import RxCocoa
import RxAlamofire

class MainViewController: UIViewController, UITableViewDelegate {
    //tableView IBOutlet만들어주기
    @IBOutlet weak var todoListTableView: UITableView!
    @IBOutlet weak var selectedTodoLabel: UILabel!
    
    @IBOutlet weak var nowPageCnt: UILabel!
    var nowFetching: Bool = false //현재 새로운 페이지의 데이터를 불러와도 되는지 확인하는 변수
    
    @IBOutlet weak var selectedTodo: UILabel!
    var selectedTodoData: [Int] = []
    
    //tableview에 들어갈 데이터목록
    var todoListData: [TodoAllData] = []
//    var todoListData: Observable<[TodoAllData]> = Observable.just([])
    
    var disposeBag = DisposeBag()
    
    @IBOutlet weak var selectedDeleteBtn: UIButton!
    @IBOutlet weak var addTodoBtn: UIButton!
    
     
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        //table View에 셀 등록해주기
        self.todoListTableView.register(TodoCell.uiNib, forCellReuseIdentifier: TodoCell.reuseIdentifier)
        
        //dataSource넣어주기
        self.todoListTableView.dataSource = self
        self.todoListTableView.delegate = self
        
        //todoList목록 불러오기
        requestTodoData()
        
        //선택된 할일 삭제 버튼 클릭시
        selectedDeleteBtn.rx.tap.bind {
            self.deleteSelectedTodos(selectedTodoIds: self.selectedTodoData) { deleteArray in
                self.todoListData =  self.todoListData.filter{ aTodo in
                    deleteArray.contains(where: {aTodo.id ?? 0 != $0})
                }
            }
        }
        .disposed(by: disposeBag)
        
        //할일 추가 버튼 클릭시
        addTodoBtn.rx.tap.bind { [weak self] in
            self?.addTodo()
        }
        .disposed(by: disposeBag)
        
    }
    
    
    //TodoList 데이터를 받아오는 부분
    func requestTodoData() {
        print(#fileID, #function, #line, "- requestTodoData")
        RxAlamofire.request(TodosRouter.fetchAll())
            .data() //observable()를 만들어서 나옴
            .decode(type: TotalAllResponse.self, decoder: JSONDecoder())
            .subscribe(
                onNext: { value in
                    guard let todoData = value.data else { return }
                    //데이터 몇개인지 파악하기
                    let dataCnt: Int = todoData.count

                    //데이터 개수만큼 돌려서 todoData만들어주기
                    for i in 0..<dataCnt {
                        let todo = TodoAllData(id: todoData[i].id, title: todoData[i].title, content: todoData[i].content, images: todoData[i].images, isPublished: todoData[i].isPublished, createdAt: todoData[i].createdAt, updatedAt: todoData[i].updatedAt)
                        //만들어준 todoData를 tableView에 뿌려줄 데이터 list에 넣어주기
                        self.todoListData.append(todo)
                        self.todoListTableView.reloadData()
                    }
                }
            )
            .disposed(by: disposeBag)
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
        print(#fileID, #function, #line, "- \(indexPath.section)")
        guard let cell = tableView.dequeueReusableCell(withIdentifier: TodoCell.reuseIdentifier, for: indexPath) as? TodoCell else { return UITableViewCell() }
        
        //데이터를 UI에 반영한다
        //그리고 클로져의 장점 -> 함수를 변수로 사용 가능하다 그러므로 아래 extension을 통해서 정의해준 cellDeleteAction(todoId: Int) 함수를 변수의 형태로 전달해줄 수 있다
        //이렇게 변수의 형태로 전달을 해주면 굳이 여기서 실행해줄 필요가 없음
        cell.configureUI(data: data,
                         indexPathRow: indexPath.row,
                         deleteAction: cellDeleteAction,
                         editAction: cellEditAction,
                         selectedSwithAction: cellSelectedSwitch)
        
        return cell
    }
}

//MARK: - Cell Event
extension MainViewController {
    fileprivate func cellDeleteAction(_ dataId: Int, _ indexPathRow: Int) {
        RxAlamofire.request(TodosRouter.deleteATodo(id: String(describing: dataId)))
            .data()
            .decode(type: AddATodoDataResponse.self, decoder: JSONDecoder())
            .subscribe (
                onNext: { value in
                    print(#fileID, #function, #line, "- cellDeleeteAction value: \(value)")
                    self.todoListData.remove(at: indexPathRow)
                    self.todoListTableView.reloadData()
                },
                onError: { Error in
                    print(#fileID, #function, #line, "- err message: \(Error)")
                }
                
            )
            .disposed(by: disposeBag)
    }
    
    //Rxswift를 이용한 선택된 할일 삭제
    fileprivate func deleteATodo(_ dataId: Int, completion: @escaping (Int?) -> Void) {
        RxAlamofire.request(TodosRouter.deleteATodo(id: String(describing: dataId)))
            .data()
            .decode(type: AddATodoDataResponse.self, decoder: JSONDecoder())
            .subscribe (
                onNext: { value in
                    print(#fileID, #function, #line, "- value: \(value)")
                    completion(value.data?.id)
                },
                onError: { Error in
                    print(#fileID, #function, #line, "- err message: \(Error)")
                }
                
            )
            .disposed(by: disposeBag)
    }
    
    fileprivate func cellEditAction(_ dataId: Int, _ dataTitle: String, _ indexPathRow: Int) {
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
        //어떤 할일 이었는지 입력
        editTodoModelVC.todoId.text = "\(String(describing: dataId))" //기존 할일의 ID
        editTodoModelVC.todoOriginalLabel.text = "기존 내용: \(dataTitle)" //기존 할일의 내용
        editTodoModelVC.indexPathRow = indexPathRow
        
        //수정 팝업이 닫히고 나서 cell 수정
        editTodoModelVC.editBtnCompleteClousre = { indexPathRow, dataId, dataTitle in
            self.todoListData[indexPathRow].title = dataTitle
            
            self.todoListTableView.reloadRows(at: [IndexPath(row: indexPathRow, section: 0)], with: .fade)
            
        }

    }
    
    fileprivate func cellSelectedSwitch(_ dataID: Int, _ indexPathRow: Int, _ selectedBool: Bool) {
        print(#fileID, #function, #line, "- \(selectedBool)")
        let data = self.todoListData[indexPathRow]
        if selectedBool {
            self.selectedTodoData.append(dataID)
            self.selectedTodo.text! = "\(self.selectedTodoData)"
        } else {
            self.selectedTodoData = self.selectedTodoData.filter({
                $0 != dataID
            })
            self.selectedTodo.text! = "\(self.selectedTodoData)"
        }
    }
}

//MARK: - API처리
extension MainViewController {
    func deleteSelectedTodos(selectedTodoIds: [Int],
                                    completion: @escaping ([Int]) -> Void){
        
        let group = DispatchGroup()
        
        // 성공적으로 삭제가 이뤄진 녀석들
        var deletedTodoIds : [Int] = [Int]()
        
        selectedTodoIds.forEach { aTodoId in
            
            // 디스패치 그룹에 넣음
            group.enter()
            
            //deleteATodo함수 실행 -> completion을 통해서 삭제가 된 애들을 deleteTodoIds 배열에 담는다
            self.deleteATodo(aTodoId, completion: { deletedId in
                // 삭제된 아이디를 삭제된 아이디 배열에 넣는다
                if let id = deletedId {
                    deletedTodoIds.append(id)
                }
                group.leave() //삭제가 완료되었으므로 디스패치 그룹에서 삭제
            })
        }
        
        // Configure a completion callback
        group.notify(queue: .main) {
            // All requests completed
            print("모든 api 완료 됨")
            completion(deletedTodoIds) //삭제된 아이들의 다음 작업 실행
        }
    }
    
    func addTodo() {
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
            
            self.todoListData.insert(addTodoData, at: 0)
            print(#fileID, #function, #line, "- todoListData: \(self.todoListData)")
            self.todoListTableView.reloadData()
        }
    }
}
