import SwiftUI

import Web3
import Web3PromiseKit
import Web3ContractABI

struct CommunitiesView: View {
    @EnvironmentObject private var appViewModel: AppView.ViewModel
    
    @StateObject var viewModel = ViewModel()
    
    @State private var showAddCommunity = false
    
    var body: some View {
        VStack {
            header
                .scenePadding()
            if viewModel.communities.isEmpty {
                Spacer()
                emptyState
            } else {
                ScrollView {
                    ForEach(viewModel.communities.filter { $0.status == .ready }, id: \.id) { community in
                        NavigationLink {
                            ZStack {
                                Text("Help")
                            }
                        } label: {
                            communityItem(community)
                        }
                        .navigationBarBackButtonHidden()
                    }
                }
            }
            Spacer()
        }
        .onAppear {
            Task { @MainActor in
                await viewModel.fetchCommunities()
            }
        }
        .sheet(isPresented: $showAddCommunity) {
            AddCommunityView() {
                showAddCommunity = false
            }
        }
    }
    
    var header: some View {
        HStack {
            Text("Communities")
                .font(.customFont(font: .helvetica, style: .bold, size: 20))
                .foregroundStyle(.dullBlue)
            Spacer()
            addCommunityButton
        }
    }
    
    var emptyState: some View {
        VStack {
            Text("No communities found")
                .font(.customFont(font: .helvetica, style: .regular, size: 18))
                .foregroundStyle(.dullBlue)
        }
    }
    
    func communityItem(_ community: Community) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8)
                .fill(
                    LinearGradient(
                        colors: [.grad2, .grad1],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
            HStack {
                VStack {
                    Spacer()
                    Text(community.name)
                        .font(.customFont(font: .helvetica, style: .bold, size: 16))
                        .foregroundStyle(.white)
                        .align(.leading)
                        .scenePadding()
                }
            }
        }
        .frame(width: 350, height: 75)
    }
    
    var addCommunityButton: some View {
        Button(action: { showAddCommunity = true }) {
            ZStack {
                Circle()
                    .foregroundStyle(.dullBlue)
                Image(systemName: "plus")
                    .foregroundStyle(.white)
            }
            .frame(width: 35, height: 35)
        }
    }
}

struct AddCommunityView: View {
    let onFinish: () -> Void
    
    @State private var isImporting = false
    @State private var isCreating = false
    
    var body: some View {
        VStack {
            header
                .scenePadding()
            Spacer()
            if isImporting {
                ImportCommunity() {
                    onFinish()
                }
            } else if isCreating {
                CreateCommunity() {
                    onFinish()
                }
            } else {
                HStack {
                    importButton
                    createButton
                }
            }
        }
    }
    
    var header: some View {
        Text("Add Community")
            .font(.customFont(font: .helvetica, style: .bold, size: 20))
            .foregroundStyle(.dullBlue)
    }
    
    var importButton: some View {
        Button(action: { isImporting = true }) {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .foregroundColor(.dullBlue)
                Text("Import Community")
                    .font(.customFont(font: .helvetica, style: .regular, size: 14))
                    .foregroundStyle(.white)
                    .scenePadding()
            }
        }
        .frame(width: 150, height: 30)
    }
    
    var createButton: some View {
        Button(action: { isCreating = true }) {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .foregroundColor(.dullBlue)
                Text("Create Community")
                    .font(.customFont(font: .helvetica, style: .regular, size: 14))
                    .foregroundStyle(.white)
                    .scenePadding()
            }
        }
        .frame(width: 150, height: 20)
    }
}

struct ImportCommunity: View {
    let onFinish: () -> Void
    
    @State private var contractAddress = ""
    
    var body: some View {
        VStack {
            TextField("Contract Address", text: $contractAddress)
                .textFieldStyle(.roundedBorder)
                .scenePadding()
            Spacer()
            Button(action: importCommunity) {
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .foregroundColor(.dullBlue)
                    Text("Import")
                        .font(.customFont(font: .helvetica, style: .regular, size: 14))
                        .foregroundStyle(.white)
                        .scenePadding()
                }
            }
            .frame(width: 150, height: 25)
        }
    }
    
    func importCommunity() {
        Task { @MainActor in
            do {
                if contractAddress.count != 42 {
                    contractAddress = ""
                    
                    return
                }
                
                let _ = try await CommunitiesApi.shared.importCommunity(contractAddress)
                
                onFinish()
            } catch {
                print("error: \(error)")
            }
        }
    }
}

struct CreateCommunity: View {
    let onFinish: () -> Void
    
    @State private var collectionName = ""
    @State private var collectionSymbol = ""
    
    var body: some View {
        VStack {
            TextField("Collection Name", text: $collectionName)
                .textFieldStyle(.roundedBorder)
                .scenePadding()
            TextField("Collection Symbol", text: $collectionSymbol)
                .textFieldStyle(.roundedBorder)
                .scenePadding()
            Spacer()
            Button(action: createCommunity) {
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .foregroundColor(.dullBlue)
                    Text("Create")
                        .font(.customFont(font: .helvetica, style: .regular, size: 14))
                        .foregroundStyle(.white)
                        .scenePadding()
                }
            }
            .frame(width: 150, height: 25)
        }
    }
    
    func createCommunity() {
        Task { @MainActor in
            do {
                if collectionName.isEmpty || collectionSymbol.isEmpty {
                    return
                }
                
                let _ = try await CommunitiesApi.shared.createCommunity(collectionName, collectionSymbol)
                
                onFinish()
            } catch {
                print("error: \(error)")
            }
        }
    }
}

#Preview {
    NavigationStack {
        CommunitiesView()
            .environmentObject(AppView.ViewModel())
    }
}
