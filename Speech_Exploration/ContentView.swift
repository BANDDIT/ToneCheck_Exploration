//
//  ContentView.swift
//  Speech_Exploration
//
//  Created by Arrick Russell Adinoto on 14/11/24.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var speechRecognizer = SpeechRecognizer()
    @State private var isRecording = false
    var ans = "请问最近的地铁站在哪里"
    
    var body: some View {
        VStack {
            Text("Hanzi yang Diucapkan")
                .font(.title)
                .padding()

            Text(speechRecognizer.recognizedText)
            Text(speechRecognizer.recognizedText.k3.pinyin)
            
            if speechRecognizer.comparison(speech: speechRecognizer.recognizedText, answer:ans, tolerance: 1) {
                Text("Correct")
            }
            else{
                Text("Wrong")
            }

            Button(action: {
                if isRecording {
                    speechRecognizer.stopRecording()
                } else {
                    speechRecognizer.startRecording()
                }
                isRecording.toggle()
            }) {
                Text(isRecording ? "Stop Recording" : "Start Recording")
                    .font(.title2)
                    .padding()
                    .background(isRecording ? Color.red : Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding()
            
            
            Button(action:{
                speechRecognizer.speakSlow(text: ans)
            }){
                Text("Say Speech")
                    .font(.title2)
                    .padding()
                    .background(isRecording ? Color.red : Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            
        }
        .onAppear {
            speechRecognizer.requestSpeechAuthorization()
        }
    }
    
    func removeTone(_ pinyin: String) -> String {
        let toneMapping: [Character: Character] = [
            "ā": "a", "á": "a", "ǎ": "a", "à": "a",
            "ē": "e", "é": "e", "ě": "e", "è": "e",
            "ī": "i", "í": "i", "ǐ": "i", "ì": "i",
            "ō": "o", "ó": "o", "ǒ": "o", "ò": "o",
            "ū": "u", "ú": "u", "ǔ": "u", "ù": "u",
            "ǖ": "u", "ǘ": "u", "ǚ": "u", "ǜ": "u",
            "ü": "u"
        ]

        var result = ""
        for char in pinyin {
            if let mappedChar = toneMapping[char] {
                result.append(mappedChar)
            } else {
                result.append(char)
            }
        }
        return result
    }
}
