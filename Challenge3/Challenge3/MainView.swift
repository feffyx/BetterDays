import SwiftUI

struct DiaryEntry: Identifiable {
    let id = UUID()
    let date: Date
    let text: String
    let emotion: String
    let photo: Image?
}

struct MainView: View {
    @State private var dayWeek: Date = Date()
    @State private var thisDay: Date = Date() // Data selezionata
    @State private var diaryEntries: [Date: [DiaryEntry]] = [:] // Dizionario delle entry del diario
    @State private var isAddingEntry: Bool = false // Stato per mostrare la schermata di aggiunta entry

    private var week: [Date] {
        let calendar = Calendar.current
        let firstDay = calendar.date(byAdding: .day, value: -calendar.component(.weekday, from: thisDay) + 1, to: thisDay)! // Primo giorno della settimana
        return (0..<7).compactMap {
            calendar.date(byAdding: .day, value: $0, to: firstDay) // Array di giorni della settimana
        }
    }

    private let dayNames: [String] = ["Mo", "Tu", "We", "Th", "Fr", "Sa", "Su"] // Nomi dei giorni

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                // Mostra la data completa del giorno selezionato
                Text(thisDay, formatter: DateFormatter.fullDate)
                    .font(.title2)

                // Nomi dei giorni della settimana
                HStack {
                    ForEach(0..<7, id: \.self) { index in
                        Text(dayNames[index])
                            .font(.caption)
                            .foregroundColor(.gray)
                            .frame(width: 40, height: 20)
                    }
                }

                // Numeri dei giorni con sfondo selezionabile
                HStack {
                    ForEach(week, id: \.self) { date in
                        let day = Calendar.current.component(.day, from: date)
                        Button(action: {
                            thisDay = date
                        }) {
                            Text("\(day)")
                                .font(.headline)
                                .frame(width: 40, height: 40)
                                .foregroundColor(thisDay == date ? .white : .black)
                                .background(thisDay == date ? Color.liliacc : Color.clear)
                                .clipShape(Circle())
                        }
                    }
                }

                Spacer()

                
                .sheet(isPresented: $isAddingEntry) {
                    AddEntryView(thisDay: thisDay) { newEntry in
                        // Salva l'entry per il giorno selezionato
                        if diaryEntries[thisDay] != nil {
                            diaryEntries[thisDay]?.append(newEntry)
                        } else {
                            diaryEntries[thisDay] = [newEntry]
                        }
                    }
                }

                Spacer()

                // Mostra le entry del giorno selezionato
                ScrollView {
                    VStack(alignment: .leading, spacing: 10) {
                        if let entries = diaryEntries[thisDay], !entries.isEmpty {
                            ForEach(entries) { entry in
                                HStack(spacing: 10) {
                                    if let photo = entry.photo {
                                        photo
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 100, height: 100)
                                            .cornerRadius(8)
                                    }

                                    VStack(alignment: .leading, spacing: 5) {
                                        Text(thisDay, formatter: DateFormatter.fullDate)
                                            .font(.headline)
                                            .foregroundColor(.white)

                                        HStack(spacing: 5) {
                                            ForEach(emotionToIcons[entry.emotion] ?? [], id: \.self) { icon in
                                                Text(icon)
                                                    .font(.title3)
                                            }
                                        }

                                        Text(entry.text)
                                            .font(.body)
                                            .foregroundColor(.white)
                                            .lineLimit(2)
                                    }
                                    

                                    Spacer()
                                }
                                .padding()
                                .background(Color.liliacc)
                                .cornerRadius(15)
                            }
                            
                        } else {
                            Text("No entries for this day.")
                                .foregroundColor(.gray)
                                .padding(.top, 150)
                                
                        }
                    }
                    .padding(.horizontal, 20) // Padding attorno alla card
                }
            }
            
            // Bottone per aggiungere una nuova entry
            Button(action: {
                isAddingEntry = true
            }) {
                Text("Add Entry")
                    .padding()
                    .frame(width: 150)
                    .background(Color.blueish)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            
            .padding(100)
        }
    }

    private let emotionToIcons: [String: [String]] = [
        "Happy": ["☀️"],
        "Sad": ["🌧️"],
        "Excited": ["🎉"],
        "Angry": ["🔥"],
        "Relaxed": ["🌊"]
    ]
}

struct AddEntryView: View {
    @Environment(\.dismiss) var dismiss
    let thisDay: Date
    var onSave: (DiaryEntry) -> Void

    @State private var entryText: String = ""
    @State private var selectedEmotion: String = "Happy"
    @State private var selectedPhoto: Image? = nil
    @State private var showImagePicker: Bool = false

    private let emotions = ["Happy", "Sad", "Excited", "Angry", "Relaxed"]

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("\(thisDay, formatter: DateFormatter.fullDate)")
                    .font(.headline)

                // Selezione emozione
                Picker("Emotion", selection: $selectedEmotion) {
                    ForEach(emotions, id: \.self) { emotion in
                        Text(emotion)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())

                // TextEditor per il testo
                TextEditor(text: $entryText)
                    .frame(height: 300)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.bg, lineWidth: 1)
                    )

                // Selezione immagine
                if let selectedPhoto = selectedPhoto {
                    selectedPhoto
                        .resizable()
                        .scaledToFit()
                        .frame(height: 100)
                        .cornerRadius(20)
                } else {
                    Button("Add a picture") {
                        showImagePicker = true
                    }
                    .padding()
                    .background(Color.liliacc)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }

                Spacer()

                // Bottone per salvare l'entry
                Button("Done") {
                    let newEntry = DiaryEntry(date: thisDay, text: entryText, emotion: selectedEmotion, photo: selectedPhoto)
                    onSave(newEntry)
                    dismiss()
                }
                .padding()
                .frame(width: 100)
                .background(Color.blueish)
                .foregroundColor(.white)
                .cornerRadius(8)
            }
            .padding(50)
            .sheet(isPresented: $showImagePicker) {
                ImagePicker(image: $selectedPhoto)
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

extension DateFormatter { // Estensione per il formato completo della data
    static var fullDate: DateFormatter {
        let format = DateFormatter()
        format.dateStyle = .full
        return format
    }
}

#Preview {
    MainView()
}
