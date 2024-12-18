//
//  MindfulnessView.swift
//  Challenge3
//
//  Created by Federica Ziaco on 13/12/24.
//


import SwiftUI
import CoreHaptics
import AVFoundation


func speak(text: String) {
    let synthesizer = AVSpeechSynthesizer()
    let utterance = AVSpeechUtterance(string: text)
    
    
    utterance.voice = AVSpeechSynthesisVoice(language: "en-EN")
    utterance.rate = AVSpeechUtteranceDefaultSpeechRate
    utterance.pitchMultiplier = 1.0
    utterance.volume = 1.0
    
    
    synthesizer.speak(utterance)
}


struct MindfulnessView: View {
    @State private var showMessage: Bool = false
    @State private var motivationalMessage: String = ""
    @State private var engine: CHHapticEngine?
    @State private var showTimeCapsuleSheet: Bool = false
    @State private var timeCapsules: [TimeCapsule] = []
    
    
    struct TimeCapsule: Identifiable {
        let id = UUID()
        let unlockDate: Date
        let message: String
        let image: Image?
    }

    struct AddTimeCapsuleView: View {
        @Environment(\.dismiss) var dismiss
        var onSave: (TimeCapsule) -> Void
        
        @State private var messageText: String = ""
        @State private var selectedImage: Image? = nil
        @State private var showImagePicker: Bool = false

        var body: some View {
            NavigationStack {
                VStack(spacing: 20) {
                    Text("Time capsule")
                        .font(.title)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)

                    TextEditor(text: $messageText)
                        .frame(height: 200)
                        .padding()
                        .overlay(
                            RoundedRectangle(cornerRadius: 15)
                                .stroke(Color.gray, lineWidth: 1)
                        )

                    if let selectedImage = selectedImage {
                        selectedImage
                            .resizable()
                            .scaledToFit()
                            .frame(height: 150)
                            .cornerRadius(15)
                    } else {
                        Button("Add a picture") {
                            showImagePicker = true
                        }
                        .padding()
                        .background(Color.liliacc)
                        .foregroundColor(.white)
                        .cornerRadius(15)
                    }

                    Spacer()

                    Button("Done") {
                        let newCapsule = TimeCapsule(
                            unlockDate: Calendar.current.date(byAdding: .year, value: 1, to: Date())!,
                            message: messageText,
                            image: selectedImage
                        )
                        onSave(newCapsule)
                        dismiss()
                    }
                    .padding()
                    .frame(width: 200)
                    .background(Color.blueish)
                    .foregroundColor(.white)
                    .cornerRadius(15)
                }
                .padding()
                .sheet(isPresented: $showImagePicker) {
                    ImagePicker(image: $selectedImage)
                }
            }
        }
    }

    
    struct ImagePicker: UIViewControllerRepresentable {
        @Binding var image: Image?

        func makeUIViewController(context: Context) -> UIImagePickerController {
            let picker = UIImagePickerController()
            picker.delegate = context.coordinator
            return picker
        }

        func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

        func makeCoordinator() -> Coordinator {
            Coordinator(self)
        }

        class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
            let parent: ImagePicker

            init(_ parent: ImagePicker) {
                self.parent = parent
            }

            func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
                if let uiImage = info[.originalImage] as? UIImage {
                    parent.image = Image(uiImage: uiImage)
                }
                picker.dismiss(animated: true)
            }
        }
    }

    
    let messages = [
        "You got this.",
        "You're smashing it!",
        "Keep going!",
        "Don't give up!",
     //   "You can do whatever you set your mind to."
    ]

    var body: some View {
        VStack(spacing: 40) {
            Spacer()

            Image( "mindfull")
                .resizable()
                .scaledToFit()
                .frame(width: 320, height: 320)
                .onTapGesture {
                    triggerHaptic()
                    showMotivationalMessage()
                }
                .animation(.easeInOut(duration: 0.5), value: showMessage)

            if showMessage {
                Text(motivationalMessage)
                    .font(.title)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.blueish)
                    .padding()
                    .transition(.slide)
            }

            Spacer()

            Button(action: {
                showTimeCapsuleSheet = true
            }) {
                Text("Time capsule")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(50)
                    .frame(width: 250)
                    .background(Color.blueish)
                    .cornerRadius(15)
            }
            .padding(.bottom, 100)
            .sheet(isPresented: $showTimeCapsuleSheet) {
                AddTimeCapsuleView { newCapsule in
                    timeCapsules.append(newCapsule)
                }
            }
        }
        .padding()
        .onAppear {
            prepareHapticEngine()
        }
    }

    func showMotivationalMessage() {
        motivationalMessage = messages.randomElement() ?? "Sei fantastico!"
        withAnimation {
            showMessage = true
        }
    }

    func prepareHapticEngine() {
        do {
            engine = try CHHapticEngine()
            try engine?.start()
        } catch {
            print("Errore nell'avvio del motore aptico: \(error.localizedDescription)")
        }
    }

    func triggerHaptic() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        let pattern = try? CHHapticPattern(events: [
            CHHapticEvent(eventType: .hapticTransient, parameters: [], relativeTime: 0)
        ], parameters: [])
        
        do {
            let player = try engine?.makePlayer(with: pattern!)
            try player?.start(atTime: 0)
        } catch {
            print("Errore durante la vibrazione: \(error.localizedDescription)")
        }
    }
}


struct TimeCapsule: Identifiable {
    let id = UUID()
    let unlockDate: Date
    let message: String
    let image: Image?
}


struct LockedCapsuleView: View {
    let capsule: TimeCapsule

    var timeRemaining: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return formatter.localizedString(for: capsule.unlockDate, relativeTo: Date())
    }

    var body: some View {
        VStack(spacing: 10) {
            Text("Capsula del Tempo Bloccata")
                .font(.headline)
                .foregroundColor(.gray)

            Text("Sblocco: \(capsule.unlockDate, formatter: DateFormatter.fullDate)")
                .font(.subheadline)
                .foregroundColor(.gray)

            Text("Tempo rimanente: \(timeRemaining)")
                .font(.subheadline)
                .foregroundColor(.blueish)
                .padding(.top, 5)
        }
        .padding()
        .background(Color.liliacc.opacity(0.2))
        .cornerRadius(15)
    }
}


struct UnlockedCapsuleView: View {
    let capsule: TimeCapsule

    var body: some View {
        VStack(spacing: 15) {
            Text("Capsula Sbloccata!")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.green)

            Text(capsule.message)
                .font(.body)
                .multilineTextAlignment(.center)

            if let image = capsule.image {
                image
                    .resizable()
                    .scaledToFit()
                    .frame(height: 150)
                    .cornerRadius(15)
            }
        }
        .padding()
        .background(Color.blueish.opacity(0.1))
        .cornerRadius(15)
    }
}



#Preview {
    MindfulnessView()
}
