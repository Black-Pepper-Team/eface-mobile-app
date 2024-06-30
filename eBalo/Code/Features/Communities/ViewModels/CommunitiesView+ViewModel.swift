import Foundation

extension CommunitiesView {
    class ViewModel: ObservableObject {
        @Published var communities: [Community] = []
        
        func fetchCommunities() async {
            do {
                let response = try await CommunitiesApi.shared.fetchCommunities()
                
                DispatchQueue.main.async {
                    self.communities = response.communities
                }
            } catch {
                print("Error fetching communities: \(error)")
            }
        }
    }
}
