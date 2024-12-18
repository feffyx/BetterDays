import SwiftUI

struct DiaryEntry: Identifiable {
    let id = UUID()
    let date: Date
    let text: String
    let emotion: String
    let photo: Image?
}

struct MainView: View {
    @State private var dayWeek: Date = Date() // Days of the week
    @State private var thisDay: Date = Date() // Selected date
    @State private var diaryEntries: [Date: [DiaryEntry]] = [:] // Displaying of the diary entries
    @State private var isAddingEntry: Bool = false // State var to show the Adding entry sheet
    @State private var isEditingEntry: Bool = false // State var to show the Editing entry sheet

    private var week: [Date] {
        let calendar = Calendar.current
        let firstDay = calendar.date(byAdding: .day, value: -calendar.component(.weekday, from: thisDay) + 1, to: thisDay)! // First day of the week
        return (0..<7).compactMap {
            calendar.date(byAdding: .day, value: $0, to: firstDay) // Array of week's day
        }
    }

    
    
    
    // Names of the days of the week
    private let dayNames: [String] = ["Su", "Mo", "Tu", "We", "Th", "Fr", "Sa"]

    
    var body: some View {
        // Calendar View
        NavigationStack {
            VStack(spacing: 20) {
                VStack {
                    Text(thisDay, formatter: DateFormatter.fullDate)  // Shows the complete date of the selected day (Day, Number, Month, Year)
                        .font(.title2)
                        .padding(.top, 30)
                        .padding(.bottom, 20)
                        .foregroundStyle(Color.blueish)
                        .fontWeight(.bold)
                } .frame(alignment: .trailing)
            

                // For Each displaying the names of the week
                HStack {
                    ForEach(0..<7, id: \.self) { index in
                        Text(dayNames[index])
                            .fontWeight(.bold)
                            .foregroundColor(.liliacc)
                            .frame(width: 40, height: 20)
                            
                    }
                }
                
            
                // Selectable numbers of the calendar
                HStack {
                    ForEach(week, id: \.self) { date in
                        let day = Calendar.current.component(.day, from: date)
                        let weekdayIndex = Calendar.current.component(.weekday, from: date) - 1
                        let weekdayName = dayNames[weekdayIndex]

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
                        
                        .accessibilityLabel("\(weekdayName), \(day)")
                    }
                }

                Divider()
                    .padding(.horizontal, 20)

                
                // Sheet to add an entry
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

        
                // List that displays the cards of each entered entry
                List {
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
                            .listRowSeparator(.hidden)
                            
                            .onTapGesture {
                                isEditingEntry = true
                            }
                        }
                        .onDelete { index in
                            diaryEntries[thisDay]?.remove(atOffsets: index)
                        }
                        
                    } else {
                        Text("No entries for this day.")
                            .foregroundColor(.gray)
                            .padding(.top, 150)
                            .padding(.leading, 95)
                            .frame(alignment: .center)
                        
                            .listRowSeparator(.hidden)
                            
                    }

                    // .padding(.horizontal, 20) // Padding attorno alla card
                }
                .listStyle(.plain)
            }
        
            
            // Sheet to edit the entry
            .sheet(isPresented: $isEditingEntry) {
                
            }
            
            // Add Entry button
            Button(action: {
                isAddingEntry = true
            }) {
                Text("Add Entry")
                    .padding()
                    .frame(width: 120)
                    .background(Color.blueish)
                    .foregroundColor(.white)
                    .cornerRadius(15)
            }
            
            
            .padding()
        }
        
        
    }
    

    
    // Emojis that represent the selected emotion
    private let emotionToIcons: [String: [String]] = [
        "Happy": ["☀️"],
        "Sad": ["🌧️"],
        "Excited": ["🎉"],
        "Angry": ["🔥"],
        "Relaxed": ["🌊"]
    ]
}




// Add entry sheet view
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
                    .padding(15)
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
                .cornerRadius(15)
            }
            .padding(50)
            .sheet(isPresented: $showImagePicker) {
                ImagePicker(image: $selectedPhoto)
            }
        }
    }
}


// Image picker view
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


// Date formatter data extension
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
