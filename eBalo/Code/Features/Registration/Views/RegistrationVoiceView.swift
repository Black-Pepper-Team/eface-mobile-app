//
//  RegistrationVoiceView.swift
//  eBalo
//
//  Created by Ivan Lele on 23.03.2024.
//

import SwiftUI
import AVFoundation

struct RegistrationVoiceView: View {
    @EnvironmentObject var appViewModel: AppView.ViewModel
    
    @ObservedObject var registrationStatus: RegistrationStatus
    
    @State private var isRecording = false
    @State private var audioRecorder: AVAudioRecorder!
    @State private var audioPlayer: AVAudioPlayer!
    @State private var audioFileURL: URL?
    @State private var confirmed = false
    
    @State var nickName = ""
    
    @State var isRequesting = false
    
    @State var isError = false
    
    var body: some View {
        VStack {
            HStack {
                Text("hleBalo Registration")
                    .font(.customFont(font: .helvetica, style: .bold, size: 20))
                    .foregroundStyle(.dullBlue)
                Spacer()
                Button(action: {
                    registrationStatus.isVoicePassing = false
                }) {
                    ZStack {
                        Circle()
                            .foregroundStyle(.dullBlue)
                        Image(systemName: "xmark")
                            .foregroundStyle(.white)
                        
                    }
                    .frame(width: 50, height: 50)
                }
            }
            .padding()
            if isRequesting {
                Spacer()
                ProgressView()
                    .controlSize(.large)
                Spacer()
            } else {
                VStack {
                    LottieView(animationFileName: "VoiceRecording", loopMode: .loop)
                        .frame(width: 250, height: 300)
                    ZStack {}
                        .frame(width: 30)
                    Text("We generate your identity based on the provided voice biometrics using advanced AI algorithm")
                        .font(.customFont(font: .helvetica, style: .regular, size: 16))
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.lightGrey)
                        .frame(width: 300)
                    Spacer()
                }
                if !isRecording && self.audioFileURL != nil{
                    if confirmed {
                        ZStack {
                            RoundedRectangle(cornerRadius: 16)
                                .foregroundStyle(.white)
                            HStack {
                                TextField("Nickname", text: $nickName)
                                Spacer()
                                Button(action: {
                                    isRequesting = true
                                    
                                    Task { @MainActor in
                                        defer {
                                            isRequesting = false
                                        }
                                        
                                        do {
                                            let claimId = try await self.appViewModel.testMisha(
                                                self.audioFileURL!,
                                                registrationStatus,
                                                nickName
                                            )
                                            
                                            print("voice claim id: \(claimId)")
                                            
                                            registrationStatus.voiceClaimId = claimId
                                            
                                            registrationStatus.isVoicePassed = true
                                            registrationStatus.isVoicePassing = false
                                        } catch let error {
                                            if "\(error)".contains("ERRWRONGVOICE") {
                                                isError = true
                                            }
                                            
                                            print(error)
                                        }
                                    }
                                }) {
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 16)
                                            .foregroundStyle(.dullBlue)
                                        Text("Register your hleBalo")
                                            .font(.customFont(font: .helvetica, style: .bold, size: 14))
                                            .foregroundStyle(.white)
                                            .disabled(appViewModel.secretKey == nil)
                                    }
                                }
                                .frame(width: 200, height: 35)
                            }
                            .padding(.leading)
                        }
                        .frame(width: 350, height: 42)
                    } else {
                        HStack {
                            Button(action: {
                                confirmed = true
                            }) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 1_000)
                                        .foregroundStyle(.dullBlue)
                                    Text("Confirm preimage")
                                        .font(.customFont(font: .helvetica, style: .bold, size: 14))
                                        .foregroundStyle(.white)
                                }
                            }
                            .buttonStyle(.plain)
                            .frame(width: 250, height: 48)
                            Button(action: {
                                do {
                                    self.audioPlayer = try AVAudioPlayer(contentsOf: self.audioFileURL!)
                                    self.audioPlayer.play()
                                } catch {
                                    print("Error playing audio: \(error.localizedDescription)")
                                }
                            }) {
                                ZStack {
                                    Circle()
                                        .foregroundStyle(.dullBlue)
                                    Image(systemName: "waveform.circle")
                                        .foregroundStyle(.white)
                                }
                            }
                            .buttonStyle(.plain)
                            .frame(width: 45, height: 48)
                            Button(action: {
                                audioFileURL = nil
                            }) {
                                ZStack {
                                    Circle()
                                        .foregroundStyle(.blood)
                                    Image(systemName: "trash")
                                        .foregroundStyle(.white)
                                }
                            }
                            .buttonStyle(.plain)
                            .frame(width: 45, height: 48)
                        }
                        .padding(.horizontal)
                    }
                } else {
                    CommonButtonView(!isRecording ? "Record preimage for your hleBalo": "Stop recording") {
                        if self.isRecording {
                            self.audioRecorder.stop()
                            self.isRecording = false
                        } else {
                            self.startRecording()
                        }
                    }
                }
            }
        }
        .alert("Failed to detect salt in speech try again", isPresented: $isError) {
            Button("OK", role: .cancel) {
                audioFileURL = nil
                confirmed = false
            }
        }
        .onAppear {
            setupRecorder()
        }
    }
    
    func setupRecorder() {
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(.playAndRecord, options: .defaultToSpeaker)
            try session.setActive(true)
        } catch {
            print("Could not set up recording session: \(error)")
        }
    }
    
    func startRecording() {
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.playAndRecord, mode: .default)
            try audioSession.setActive(true)

            let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let audioFilename = documentsPath.appendingPathComponent("recording.m4a")
            self.audioFileURL = audioFilename

            let settings = [
                AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                AVSampleRateKey: 44100,
                AVNumberOfChannelsKey: 2,
                AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
            ]

            self.audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
            self.audioRecorder.record()

            self.isRecording = true
        } catch {
            print("Error recording audio: \(error.localizedDescription)")
        }
    }
}

#Preview {
    RegistrationVoiceView(registrationStatus: RegistrationStatus())
        .environmentObject(AppView.ViewModel())
}
