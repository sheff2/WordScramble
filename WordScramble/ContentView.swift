//
//  ContentView.swift
//  WordScramble
//
//  Created by Shaun Heffernan on 1/16/24.
//

import SwiftUI

struct ContentView: View {
    @State private var usedWords = [String]()
    @State private var rootWord = ""
    @State private var newWord = ""
    
    
    @State private var errorTitle = ""
    @State private var errorMessage = ""
    @State private var showingError = false
    
    @State private var currentScore = 0
    @State private var sessionScore = 0
    var body: some View {
        NavigationStack{
            List{
                Section{
                    TextField("Enter your word", text: $newWord)
                        .textInputAutocapitalization(.never)
                }
                Section{
                    ForEach(usedWords, id: \.self){ word in
                        HStack{
                            Image(systemName: "\(word.count).circle")
                            Text(word)
                            
                        }
                    }
                }
                Section{
                    Text("""
                         Word score: \(currentScore)
                         Session score: \(sessionScore)
                         """)
                    .font(.headline)
                }
            }
            .navigationTitle(rootWord)
            .onSubmit(addNewWord)
            .onAppear(perform: startGame)
            .alert(errorTitle, isPresented: $showingError){
                Button("OK") { }
            } message: {
                Text(errorMessage)
            }
            .toolbar{
                Button{
                    nextRound()
                } label: {
                    Text("New Word")
                }
                
            }
        }
        
    }

    func addNewWord(){
        let answer = newWord.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard answer.count > 0 else{ return }

        guard isOriginal(answer) else{
            wordError(title: "word used alread", message: "be more original")
            return
        }
        
        guard isPossible(answer) else{
            wordError(title: "word not possible", message: "you can't spell \(answer) from \(rootWord)")
            return
        }
        
        guard isRealWord(answer) else{
            wordError(title: "word not recognized", message: "you can't just make them up")
            return
        }
        
        guard isLong(answer) else {
            wordError(title: "too short", message: "word must be longer than 2 letters")
            return
        }
        
        guard isUniqueFromRoot(answer) else{
            wordError(title: "same as starting", message: "words must be different from starting word")
            return
        }
        withAnimation{
            usedWords.insert(answer, at: 0)
            
        }
        currentScore += answer.count
        sessionScore += answer.count
        newWord = ""
        
    }
    func startGame(){
        if let startWordsURL = Bundle.main.url(forResource: "start", withExtension: "txt"){
            if let startWords = try? String(contentsOf: startWordsURL){
                let allWords = startWords.components(separatedBy: "\n")
                rootWord = allWords.randomElement() ?? "silkworm"
                return
            }
        }
        fatalError("Could not load start.txt from bundle.")
    }
    
    func isOriginal(_ word: String) -> Bool {
        !usedWords.contains(word)
    }
    
    func isLong(_ word: String) -> Bool{
        return (word.count > 2 ? true : false)
    }
    
    func isUniqueFromRoot(_ word:String) -> Bool{
        return (word == rootWord ? false : true)
    }
    
    func isPossible(_ word: String) -> Bool {
        var tempWord = rootWord
        
        for letter in word {
            if let pos = tempWord.firstIndex(of: letter){
                tempWord.remove(at: pos)
            } else{
                return false
            }
        }
        return true
    }
    
    func isRealWord(_ word:String) -> Bool{
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)
        let mispelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
        return mispelledRange.location == NSNotFound
    }
    
    func wordError(title:String, message:String){
        errorTitle = title
        errorMessage = message
        showingError = true
    }
    
    func nextRound(){
        usedWords = [String]()
        currentScore = 0
        startGame()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
