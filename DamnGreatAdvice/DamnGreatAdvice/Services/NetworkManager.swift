import UIKit

class NetworkManager {
    
    let fuckingGreatAdviceApi = FuckingGreatAdviceAPI()
    
    static let shared = NetworkManager()
    private init () {}
    
    func fetchAdvices(completion: @escaping ([Advice]) -> Void) {
        let urlString = fuckingGreatAdviceApi.body + fuckingGreatAdviceApi.randomAdvicesEndpoint
        guard let url = URL(string: urlString) else {
            return
        }
        let session = URLSession.shared
        let request = URLRequest(url: url)
        session.dataTask(with: request) { (data, response, error) in
            if let data = data {
                if let advicesData = try? JSONDecoder().decode(Advices.self, from: data) {
                    if let advices = advicesData.data {
                        completion(advices)
                    }
                }
            }
        }.resume()
    }
    
}
