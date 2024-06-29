import Speech
import SwiftUI
import AVFoundation
import ExyteChat

struct ELeleChatView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    @EnvironmentObject private var appViewModel: AppView.ViewModel

    @State private var isRecording = false
    @State private var audioRecorder: AVAudioRecorder!
    @State private var audioPlayer: AVAudioPlayer!
    @State private var audioFileURL: URL?
    @State private var confirmed = false
    
    @State var messages: [Message] = []
    
    var body: some View {
        ZStack {
            Color.dullBlue
                .edgesIgnoringSafeArea(.all)
            VStack {
                ZStack {
                    HStack {
                        Image(Icons.assistentIcon)
                            .resizable()
                            .frame(width: 50, height: 50)
                        Text("eLele")
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
                            Spacer()
                        }
                    }
                }
                .padding(.top, 20)
                Spacer()
                ChatView(messages: messages, didSendMessage: processMessage)
            }
        }
        .onAppear {
            self.messages.append(
                .init(
                    id: UUID().uuidString,
                    user: User(
                        id: "remote",
                        name: "eLele",
                        avatarURL: URL(string: "https://i.ibb.co/DCZxTBy/2024-06-29-13-42-32.jpg")!,
                        isCurrentUser: false
                    ),
                    text: "Hello, I'm eLele, your personal assistant. How can I help you today?"
                )
            )
        }
    }
    
    func processMessage(_ draftMessage: DraftMessage) {
        if let recording = draftMessage.recording {
            transcribeAudio(url: recording.url!)
            
            return
        }
        
        if draftMessage.text.isEmpty {
            return
        }
        
        self.messages.append(
            .init(
                id: UUID().uuidString,
                user: User(
                    id: "local",
                    name: "user",
                    avatarURL: nil,
                    isCurrentUser: true
                ),
                text: draftMessage.text
            )
        )
        
        self.sendMessage(
            draftMessage.text
        )
    }
    
    func transcribeAudio(url: URL) {
        // create a new recognizer and point it at our audio
        let recognizer = SFSpeechRecognizer()
        let request = SFSpeechURLRecognitionRequest(url: url)

        // start recognition!
        recognizer?.recognitionTask(with: request) {(result, error) in
            // abort if we didn't get any transcription back
            guard let result = result else {
                print("There was an error: \(error!)")
                return
            }

            // if we got the final transcription back, print it
            if result.isFinal {
                processMessage(
                    .init(
                        id: nil,
                        text: result.bestTranscription.formattedString,
                        medias: [],
                        recording: nil,
                        replyMessage: nil,
                        createdAt: Date()
                    )
                )
            }
        }
    }
    
    func sendMessage(_ message: String) {
        Task { @MainActor in
            do {
                let id = UUID().uuidString
                
                let response = try await ChatApi.shared.sendMessage(id, message)
                
                print("response id: \(response.id)")
                
                var isTextSet = false
                
                while true {
                    try await Task.sleep(nanoseconds: 250_000_000)
                    
                    let pollResponse = try await ChatApi.shared.pollResponse(id)
                    
                    if !isTextSet {
                        if let text = pollResponse.text {
                            receiveMessage(text)
                            
                            isTextSet = true
                        }
                        
                        continue
                    }
                    
                    if let file =  pollResponse.file {
                        playRawResponse(file)
                        
                        return
                    }
                }
            } catch {
                print("Failed to send message: \(error)")
            }
        }
    }
    
    func receiveMessage(_ text: String) {
        self.messages.append(
            .init(
                id: UUID().uuidString,
                user: User(
                    id: "remote",
                    name: "eLele",
                    avatarURL: URL(string: "https://i.ibb.co/DCZxTBy/2024-06-29-13-42-32.jpg")!,
                    isCurrentUser: false
                ),
                text: text
            )
        )
    }
    
    func playRawResponse(_ rawAudio: Data) {
        do {
            self.audioPlayer = try AVAudioPlayer(data: rawAudio)
            self.audioPlayer.play()
        } catch {
            print("Failed to play audio: \(error)")
        }
    }
}

#Preview {
    ELeleChatView()
        .environmentObject(AppView.ViewModel())
}
