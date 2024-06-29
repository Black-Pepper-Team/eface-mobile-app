import SwiftUI

struct ContactsView: View {
    @EnvironmentObject private var appViewModel: AppView.ViewModel
    
    @State var isRequesting = false
    
    @State private var isManually = false
    @State private var isByEBalo = false
    
    @State private var name = ""
    @State private var address = ""
    
    @State private var showCamera = false
    @State private var selectedImage: UIImage?
    @State var image: UIImage?
    
    @State var nickname: String = ""
    @State var pubkey: String = ""
    @State var userId: String = ""
    @State var sendingAddress: String = ""
    
    @State var isError = false
    
    var body: some View {
        VStack {
            header
                .scenePadding()
            if appViewModel.contacts.isEmpty {
                Spacer()
                Text("No contacts")
                    .font(.customFont(font: .helvetica, style: .bold, size: 16))
                    .foregroundStyle(.dullBlue)
            } else {
                List {
                    ForEach(appViewModel.contacts, id: \.name) { contact in
                        contactItem(contact)
                    }
                    .onDelete(perform: { indexSet in
                        appViewModel.contacts.remove(atOffsets: indexSet)
                        
                        SimpleStorage.saveContacts(appViewModel.contacts)
                    })
                }
                .listStyle(.plain)
            }
            Spacer()
            footerButtons
        }
        .sheet(isPresented: $isManually) {
            addManuallySheet
        }
        .sheet(isPresented: $isByEBalo) {
            addByEBaloSheet
        }
    }
    
    var header: some View {
        Text("Contacts")
            .font(.customFont(font: .helvetica, style: .bold, size: 20))
            .foregroundStyle(.dullBlue)
            .align(.leading)
    }
    
    func contactItem(_ contact: Contact) -> some View {
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
                Text(contact.name)
                    .font(.customFont(font: .helvetica, style: .bold, size: 16))
                    .foregroundStyle(.white)
                    .padding()
                Spacer()
                Text(contact.address)
                    .font(.customFont(font: .helvetica, style: .bold, size: 16))
                    .foregroundStyle(.white)
                    .padding()
                    .frame(width: 150)
            }
                
        }
        .frame(width: 350, height: 50)
    }
    
    var footerButtons: some View {
        ZStack {
            Rectangle()
                .foregroundStyle(.dullBlue)
            HStack {
                Spacer()
                Button(action: { isManually = true }) {
                    Text("Manually")
                        .font(.customFont(font: .helvetica, style: .bold, size: 16))
                        .foregroundStyle(.white)
                }
                Spacer()
                Rectangle()
                    .frame(width: 2)
                    .foregroundStyle(.white)
                Spacer()
                Button(action: { isByEBalo = true }) {
                    Text("By eBalo")
                        .font(.customFont(font: .helvetica, style: .bold, size: 16))
                        .foregroundStyle(.white)
                }
                Spacer()
            }
        }
        .ignoresSafeArea()
        .frame(height: 50)
    }
    
    var addManuallySheet: some View {
        VStack {
            Text("Add Manually")
                .font(.customFont(font: .helvetica, style: .bold, size: 20))
                .foregroundStyle(.dullBlue)
                .align(.leading)
                .scenePadding()
            TextField("Name", text: $name)
                .font(.customFont(font: .helvetica, style: .bold, size: 16))
                .foregroundStyle(.dullBlue)
                .scenePadding()
            TextField("Address", text: $address)
                .font(.customFont(font: .helvetica, style: .bold, size: 16))
                .foregroundStyle(.dullBlue)
                .scenePadding()
            Spacer()
            HStack {
                Spacer()
                Button(action: {
                    if name.isEmpty || address.isEmpty {
                        return
                    }
                    
                    if address.count != 42 {
                        address = ""
                        
                        return
                    }
                    
                    appViewModel.contacts.append(Contact(name: name, address: address))
                    SimpleStorage.saveContacts(appViewModel.contacts)
                    isManually = false
                }) {
                    Text("Add")
                        .font(.customFont(font: .helvetica, style: .bold, size: 16))
                        .foregroundStyle(.white)
                }
                .padding()
                .background(.dullBlue)
                .cornerRadius(8)
                Spacer()
            }
        }
    }
    
    var addByEBaloSheet: some View {
        VStack {
            Text("Add By eBalo")
                .font(.customFont(font: .helvetica, style: .bold, size: 20))
                .foregroundStyle(.dullBlue)
                .align(.leading)
                .scenePadding()
            Spacer()
            ProgressView()
                .controlSize(.large)
            Spacer()
        }
        .onAppear {
            self.showCamera.toggle()
        }
        .alert("eBalo wasn't found", isPresented: $isError) {
            Button("OK", role: .cancel) {
                selectedImage = nil
                
                nickname = ""
                pubkey = ""
                userId = ""
                sendingAddress = ""
            }
        }
        .onChange(of: userId) { changed in
            if !userId.isEmpty {
                isRequesting = true
                
                Task { @MainActor in
                    defer {
                        isRequesting = false
                    }
                    do {
                        sendingAddress = try await appViewModel.getAddressByUserId(userId)
                        
                        appViewModel.contacts.append(Contact(name: nickname, address: sendingAddress))
                        
                        SimpleStorage.saveContacts(appViewModel.contacts)
                        
                        self.isByEBalo = false
                    } catch let error {
                        print(error)
                    }
                }
            }
        }
        .onChange(of: selectedImage) { image in
            if let image = image {
                isRequesting = true
                
                Task { @MainActor in
                    defer {
                        isRequesting = false
                    }
                    
                    do {
                        let resp = try await appViewModel.getEbalo(image)
                        
                        nickname = resp.metadata
                        pubkey = resp.publicKey
                        userId = resp.userId
                    } catch let error {
                        if "\(error)".contains("ERROREBALONOTFOUND") {
                            isError = true
                        }
                        
                        print(error)
                    }
                }
            }
        }
        .fullScreenCover(isPresented: self.$showCamera) {
            accessCameraView(selectedImage: self.$selectedImage)
                .ignoresSafeArea()
        }
    }
}

#Preview {
    return ContactsView()
        .environmentObject(AppView.ViewModel())
}
