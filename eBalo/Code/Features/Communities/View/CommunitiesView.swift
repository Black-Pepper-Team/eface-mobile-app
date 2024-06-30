import SwiftUI

import Web3
import Web3PromiseKit
import Web3ContractABI
import ExyteChat

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
                                CommunityView(community: community)
                            }
                            .navigationBarBackButtonHidden()
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
    @EnvironmentObject private var appViewModel: AppView.ViewModel
    
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
                
                let _ = try await CommunitiesApi.shared.createCommunity(
                    appViewModel.secretKey!,
                    collectionName,
                    collectionSymbol
                )
                
                onFinish()
            } catch {
                print("error: \(error)")
            }
        }
    }
}

struct CommunityView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    @EnvironmentObject private var appViewModel: AppView.ViewModel
    
    let community: Community
    
    @State var messages: [Message] = []
    
    @State private var isSettings = false
    @State private var isMinting = false
    
    @State private var minToAddress = ""
    
    var body: some View {
        ZStack {
            Color.dullBlue
                .edgesIgnoringSafeArea(.all)
            VStack {
                ZStack {
                    HStack {
                        Text(community.name)
                            .font(.customFont(font: .helvetica, style: .bold, size: 18))
                            .foregroundStyle(.white)
                    }
                    HStack {
                        Button(action: {
                            self.presentationMode.wrappedValue.dismiss()
                        }) {
                            Image(systemName: "arrow.left")
                                .resizable()
                                .frame(width: 20, height: 20)
                                .foregroundColor(.white)
                                .scenePadding()
                        }
                        Spacer()
                        Button(action: {
                            self.isSettings = true
                        }) {
                            Image(systemName: "gearshape")
                                .resizable()
                                .frame(width: 20, height: 20)
                                .foregroundColor(.white)
                                .scenePadding()
                        }
                    }
                }
                .padding(.top, 20)
                Spacer()
                ChatView(messages: messages) { draw in
                }
            }
        }
        .sheet(isPresented: $isSettings) {
            VStack {
                Text("Settings")
                    .font(.customFont(font: .helvetica, style: .bold, size: 20))
                    .foregroundStyle(.dullBlue)
                    .scenePadding()
                if isMinting {
                    TextField("Address", text: $minToAddress)
                        .textFieldStyle(.roundedBorder)
                        .scenePadding()
                    Spacer()
                    Button(action: mintNft) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 8)
                                .foregroundColor(.dullBlue)
                            Text("Mint NFT")
                                .font(.customFont(font: .helvetica, style: .regular, size: 14))
                                .foregroundStyle(.white)
                                .scenePadding()
                        }
                    }
                    .frame(width: 350, height: 25)
                    .scenePadding()
                } else {
                    Spacer()
                    Button(action: registerInCommunity) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 8)
                                .foregroundColor(.dullBlue)
                            Text("Register in community")
                                .font(.customFont(font: .helvetica, style: .regular, size: 14))
                                .foregroundStyle(.white)
                                .scenePadding()
                        }
                    }
                    .frame(width: 350, height: 25)
                    .scenePadding()
                    if community.ownerAddress == appViewModel.ethAdderess {
                        Button(action: { isMinting = true }) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 8)
                                    .foregroundColor(.dullBlue)
                                Text("Add participant")
                                    .font(.customFont(font: .helvetica, style: .regular, size: 14))
                                    .foregroundStyle(.white)
                                    .scenePadding()
                            }
                        }
                        .frame(width: 350, height: 25)
                        .scenePadding()
                    }
                }
            }
        }
        .onAppear {
            Task { @MainActor in
                do {
                    let address = community.contractAddress
                    
                    var offset = try await ChatContract.shared.getMessagesCount(address)
                    
                    if offset > 100 {
                        offset -= 100
                    } else {
                        offset = 0
                    }
                    
                    let messages = try await ChatContract.shared.listMessages(address, Int(offset), 100)
                    
                    for message in messages {
                        self.messages.append(
                            .init(
                                id: UUID().uuidString,
                                user: .init(
                                    id: "Local",
                                    name: "PIRATE",
                                    avatarURL: URL(string: "https://i.ibb.co/FnwZMzM/Daco-5704371.png")!,
                                    isCurrentUser: false
                                ),
                                createdAt: message.timestamp,
                                text: message.message
                            )
                        )
                    }
                } catch {
                    print("error: \(error)")
                }
            }
        }
    }
    
    func registerInCommunity() {
        Task { @MainActor in
            do {
                let nftContract = try NFTContract(community.contractAddress)
                
                let tokens = try await nftContract.getTokensByOwner(self.appViewModel.ethAdderess)
                
                print("tokens: \(tokens)")
                
                guard let token = tokens.last else {
                    return
                }
                
                let _ = try await CommunitiesApi.shared.registerInCommunity(
                    token.description,
                    community.ownerAddress,
                    community.contractAddress,
                    appViewModel.secretKey ?? "",
                    appViewModel.secretKey ?? ""
                )
                
                print("User registered in community")
            } catch {
                print("error: \(error)")
            }
        }
    }
    
    func mintNft() {
        if minToAddress.count != 42 {
            minToAddress = ""
            
            return
        }
        
        defer {
            isMinting = false
        }
        
        Task { @MainActor in
            do {
                let _ = try await CommunitiesApi.shared.mintNft(
                    community.contractAddress,
                    appViewModel.secretKey ?? "",
                    minToAddress
                )
                
                print("NFT minted")
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
