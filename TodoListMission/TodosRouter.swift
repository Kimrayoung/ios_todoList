//
//  TodosRouter.swift
//  TodoListMission
//
//  Created by 김라영 on 2023/02/08.
//

import Foundation
import Alamofire

var BASE_URL = "https://phplaravel-574671-2962113.cloudwaysapps.com/api/v1/"

enum TodosRouter: URLRequestConvertible {
    case fetchAll(page: Int = 1) //모든 할일 목록 가져오기
    case fetchATodo(id: Int) //특정 할일 가져오기
    //page는 enum에 변수를 셋팅해주는 것을 의미한다
    case addATodo(param: Todo)
//    case addATodo(title: String, isDone: Bool) //할일 추가하기 -> title, is_done //만약에 Todo자료형에 param이라는 데이터를 생성해주지 않았다면 일일이 이렇게 변수로 추가해줘야 한다
    case addATodoJson(param: Todo) //dataJson의 형태로 추가하기
    case editATodoJson(param: Todo, id: String) //todoData 수정하기
    case deleteATodo(id: String) //기존할일 삭제하기
    
    /*
     ?page = 1, order_by=desc 등은 query params에 해당한다
     https://phplaravel-574671-2962113.cloudwaysapps.com/api/v1/posts?page=1&order_by=desc&per_page=10&status=all
     */
    
//    var baseURL: URL {
//        let BASE_URL = BASE_URL.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
//        return URL(string: BASE_URL)!
//    }

    
    var endPoint: String {
        switch self  {
        case .fetchAll(let page):
            return "todos?page=\(page)"
        case .addATodoJson:
            return "todos-json"
        case .fetchATodo(let id):
            return "todos/\(id)"
        case .editATodoJson(let param, let id):
            return "todos-json/\(id)"
        case .deleteATodo(let id):
            return "todos/\(id)"
        default: return "todos"
        }
    }
    
    //헤더
    var headers: HTTPHeaders {
        switch self {
        default: return HTTPHeaders(["accept":"application/json"])
        }
    }
    
    //어떤 방식(get, post, delete, update)
    var method: HTTPMethod {
        switch self {
        case .addATodo, .addATodoJson, .editATodoJson: return .post
        case .deleteATodo: return .delete
        default: return .get
        }
    }
    
    //파라미터 -> ex. post로 데이터를 보낼때 같이 보내야 하는 데이터들
    var parameters: Parameters {
        return Parameters()
    }
    
    //여기서 URLRequest를 반환해준다
    func asURLRequest() throws -> URLRequest {
        var url = BASE_URL.appending(endPoint)
        url = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        let urlResult = URL(string: url)!
//        let url = baseURL.appendingPathComponent(endPoint) //baseURL이라는 변수뒤에 endPoint를 붙여준다
        print(#fileID, #function, #line, "- url: \(url)")
        var request = URLRequest(url: urlResult)
        print(#fileID, #function, #line, "- request checking: \(request)")
        
        request.method = method
        request.headers = headers
        
        //parameter와 encoding방식은 Get방식일때와 post방식일 때 다를 수 있다 -> 그러므로 switch self를 이용해서 구분해준다
        switch self {
        case .fetchAll(let page):
            print(#fileID, #function, #line, "- page checking: \(page)")
            request = try URLEncoding.queryString.encode(request, with: parameters)
        case .addATodo(let param):
            print(#fileID, #function, #line, "- param checking: \(param)")
            request = try JSONParameterEncoder().encode(param, into: request)
        case .addATodoJson(let param):
            print(#fileID, #function, #line, "- appATodoJson param checking: \(param)")
            request = try JSONParameterEncoder().encode(param, into: request)
        case .editATodoJson(let param,let id):
            print(#fileID, #function, #line, "- editATodoJSON: \(id)")
            request = try JSONParameterEncoder().encode(param, into: request)
        case .deleteATodo:
            print(#fileID, #function, #line, "- deleteATodo")
            request = try URLEncoding.queryString.encode(request, with: parameters)
        default:
            print(#fileID, #function, #line, "- request checking: \(request)")
            request = try URLEncoding.queryString.encode(request, with: parameters)
        }
        
        return request
    }
}
