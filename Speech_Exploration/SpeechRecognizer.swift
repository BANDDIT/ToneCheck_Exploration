//
//  SpeechRecognizer.swift
//  Speech_Exploration
//
//  Created by Arrick Russell Adinoto on 15/11/24.
//
import Foundation
import AVFoundation
import K3Pinyin
import Speech

class SpeechRecognizer: ObservableObject {
    private var recognizer: SFSpeechRecognizer?
    private var recognitionTask: SFSpeechRecognitionTask?
    private var audioEngine = AVAudioEngine()
    private let synthesizer = AVSpeechSynthesizer()

    @Published var recognizedText: String = ""
    
    /*
     Coba cari yang terbaik untuk Tone Checking
     Gaharus pake speech, mau pake hugging face juga oke
     */
    
    init() {
        recognizer = SFSpeechRecognizer(locale: Locale(identifier: "zh-CN")) // Menggunakan bahasa Mandarin (Simplified)
    }
    

    
    // Meminta izin pengenalan suara
    func requestSpeechAuthorization() {
        SFSpeechRecognizer.requestAuthorization { authStatus in
            switch authStatus {
            case .authorized:
                print("Speech recognition authorized.")
            case .denied:
                print("Speech recognition denied.")
            case .restricted:
                print("Speech recognition restricted.")
            case .notDetermined:
                print("Speech recognition not determined.")
            @unknown default:
                fatalError("Unknown authorization status")
            }
        }
    }
    
    // Mulai merekam dan mengenali ucapan
    func startRecording() {
        guard let recognizer = recognizer, recognizer.isAvailable else {
            print("Speech recognizer is not available.")
            return
        }
        
        let request = SFSpeechAudioBufferRecognitionRequest()
        let inputNode = audioEngine.inputNode
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer, _) in
            request.append(buffer)
        }
        
        audioEngine.prepare()
        try? audioEngine.start()
        
        recognitionTask = recognizer.recognitionTask(with: request) { result, error in
            if let result = result {
                self.recognizedText = result.bestTranscription.formattedString
            }
            
            if let error = error {
                print("Error: \(error.localizedDescription)")
            }
        }
    }
    
    // Hentikan rekaman dan pengenalan suara
    func stopRecording() {
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        recognitionTask?.finish()
    }
    
    private func configureAndSpeak(text: String, rate: Float) {
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "zh-CN")
        utterance.rate = rate
        utterance.pitchMultiplier = 1.0
        utterance.volume = 0.8
        
        synthesizer.speak(utterance)
        
        print("Speaking: \(text)")
        
        // Wait for speech to complete
        while synthesizer.isSpeaking {
            RunLoop.current.run(until: Date(timeIntervalSinceNow: 0.1))
        }
        
        print("Finished speaking")
    }
    
    func speakSlow(text: String) {
        configureAndSpeak(text: text, rate: 0.25) // Adjusted rate for slower speech
    }
    
    func removeTone(_ pinyin: String) -> String {
        let toneMapping: [Character: Character] = [
            "ā": "a", "á": "a", "ǎ": "a", "à": "a",
            "ē": "e", "é": "e", "ě": "e", "è": "e",
            "ī": "i", "í": "i", "ǐ": "i", "ì": "i",
            "ō": "o", "ó": "o", "ǒ": "o", "ò": "o",
            "ū": "u", "ú": "u", "ǔ": "u", "ù": "u",
            "ǖ": "ü", "ǘ": "ü", "ǚ": "ü", "ǜ": "ü",
            "ü": "ü"
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
    
    
    func removeToneEasy(_ pinyin: String) -> String {
        let toneMapping: [Character: Character] = [
            "ā": "a", "á": "a", "ǎ": "a", "à": "a",
            "ē": "e", "é": "e", "ě": "e", "è": "e",
            "ī": "i", "í": "i", "ǐ": "i", "ì": "i",
            "ō": "o", "ó": "o", "ǒ": "o", "ò": "o",
            "ū": "u", "ú": "u", "ǔ": "u", "ù": "u",
            "ǖ": "ü", "ǘ": "ü", "ǚ": "ü", "ǜ": "ü",
            "ü": "ü"
        ]

        // Langkah 1: Menghapus nada
        var result = ""
        for char in pinyin {
            if let mappedChar = toneMapping[char] {
                result.append(mappedChar)
            } else {
                result.append(char)
            }
        }
        
        // Langkah 2: Mengganti kombinasi karakter tertentu untuk mentoleransi perbedaan
        result = result.replacingOccurrences(of: "zh", with: "z")
        result = result.replacingOccurrences(of: "ch", with: "c")
        result = result.replacingOccurrences(of: "sh", with: "s")
        
        return result
    }
    
    func removeToneSuperEasy(_ pinyin: String) -> String {
        let toneMapping: [Character: Character] = [
            "ā": "a", "á": "a", "ǎ": "a", "à": "a",
            "ē": "e", "é": "e", "ě": "e", "è": "e",
            "ī": "i", "í": "i", "ǐ": "i", "ì": "i",
            "ō": "o", "ó": "o", "ǒ": "o", "ò": "o",
            "ū": "u", "ú": "u", "ǔ": "u", "ù": "u",
            "ǖ": "ü", "ǘ": "ü", "ǚ": "ü", "ǜ": "ü",
            "ü": "ü"
        ]

        // Langkah 1: Menghapus nada
        var result = ""
        for char in pinyin {
            if let mappedChar = toneMapping[char] {
                result.append(mappedChar)
            } else {
                result.append(char)
            }
        }
        
        // Langkah 2: Mengganti kombinasi karakter tertentu untuk mentoleransi perbedaan
        result = result.replacingOccurrences(of: "zh", with: "c")
        result = result.replacingOccurrences(of: "ch", with: "c")
        result = result.replacingOccurrences(of: "sh", with: "c")
        result = result.replacingOccurrences(of: "z", with: "c")
        result = result.replacingOccurrences(of: "s", with: "c")
        result = result.replacingOccurrences(of: "p", with: "b")
        result = result.replacingOccurrences(of: "q", with: "j")
        result = result.replacingOccurrences(of: "x", with: "j")
        result = result.replacingOccurrences(of: "ang", with: "an")
        result = result.replacingOccurrences(of: "eng", with: "en")
        result = result.replacingOccurrences(of: "ing", with: "in")
        result = result.replacingOccurrences(of: "t", with: "d")
        result = result.replacingOccurrences(of: "g", with: "k")

        return result
    }
    
    func comparison(speech: String, answer: String, tolerance: Double) -> Bool {
        guard answer.count == speech.count else {
            return false
        }
        
        var wrongPinyin: Bool = false
        var wrongTone: Double = 0
        var totalHanzi: Int = answer.count
        

        
        for i in 0..<totalHanzi {
            let speechIndex = speech.index(speech.startIndex, offsetBy: i)
            let answerIndex = answer.index(answer.startIndex, offsetBy: i)

            var firstChar = String(speech[speechIndex]).k3.pinyin
            var secondChar = String(answer[answerIndex]).k3.pinyin
            
            if firstChar != secondChar {
                if removeToneSuperEasy(firstChar) == removeToneSuperEasy(secondChar) {
                    print("Masuk atas")
                    print(removeToneSuperEasy(firstChar))
                    print(removeToneSuperEasy(secondChar))
                    wrongTone += 1
                }
                else{
                    print("Masuk bawah")
                    print(removeToneSuperEasy(firstChar))
                    print(removeToneSuperEasy(secondChar))
                    wrongPinyin = true
                    break
                }
            }
        }
        
        
        var wrongPercentage = wrongTone / Double(totalHanzi)
        print(wrongTone)
        print(totalHanzi)
        if wrongPinyin {
            return false
        }
        
        return true
    }
}
