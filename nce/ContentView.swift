//
//  ContentView.swift
//  nce
//
//  Created by jk on 2020/3/7.
//  Copyright © 2020 ssl. All rights reserved.
//
import Speech
import SwiftUI
import AVFoundation

struct ButtonLabel: View {
  private let title: String
  private let background: Color
  var body: some View {
    HStack{
        Spacer()
        Text(title)
            .font(.title)
            .bold()
            .foregroundColor(.white)
        Spacer()
    }.padding().background(background).cornerRadius(10)
  }
  init(_ title:String,background:Color){
      self.title = title
      self.background = background
  }
}

struct ContentView: View {
  @State var recording: Bool = false
  @State var speech: String = ""
  private let recognizer: SpeechRecognizer
  init() {
    guard let recognizer = SpeechRecognizer() else {
      fatalError("something gone wrong")
    }
    self.recognizer = recognizer

  }
  var body: some View {
      Button(action: {}) {
      Text("Hold to Talk")
      }
  }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
