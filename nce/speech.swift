//
//  speech.swift
//  nce
//
//  Created by jk on 2020/3/8.
//  Copyright © 2020 ssl. All rights reserved.
//

//import Foundation
import Speech
//import SwiftUI
import AVFoundation

class SpeechRecognizer {
  private let audioEngine: AVAudioEngine //perform audio input or output
  private let session: AVAudioSession //specify to OS what kind of audio to work with
  private let recognizer: SFSpeechRecognizer // initiate speech recognition
  private let inputBus: AVAudioNodeBus // establish connections with input hardware
  private let inputNode: AVAudioInputNode // establish connections with input hardware
  
  private var request: SFSpeechAudioBufferRecognitionRequest? // capture audio from a live buffer to recognize
  //private var request: SFSpeechURLRecognitionRequest? // perform recognition on a preexisting audio record file
  
  private var task: SFSpeechRecognitionTask? // represents an ongoing task, to see when the task is done or cancel
  private var permissions: Bool = false //
  
  init?(inputBus: AVAudioNodeBus = 0 ) {
    //self.
    audioEngine = AVAudioEngine()
    //self.
    session = AVAudioSession.sharedInstance()
    
    guard let recognizer = SFSpeechRecognizer() else {return nil}
    
    self.recognizer = recognizer
    self.inputBus = inputBus
    self.inputNode = audioEngine.inputNode
  }
  
  func checkSessionPermissions(_ session: AVAudioSession,completion:@escaping (Bool)->()) {
    if session.responds(to: #selector(AVAudioSession.requestRecordPermission(_:)))
    {
      session.requestRecordPermission(completion)
    }
  }
  
  // start the recording and some setup at the top
  func startRecording(completion:@escaping (String?) -> ()) {
    audioEngine.prepare()
    request = SFSpeechAudioBufferRecognitionRequest()
    request?.shouldReportPartialResults = true
    // check for audion and microphone access permissions
    checkSessionPermissions(session){ success in
      self.permissions = success
    }
    guard let _ = try? session.setCategory(.record,mode: .measurement,options: .duckOthers),
      let _ = try? session.setActive(true, options: .notifyOthersOnDeactivation),
      let _ = try? audioEngine.start(),
      let request = self.request else {
      return completion(nil)
    }
    // set then recording format and create the necccessary buffer
    let recordingFormat = inputNode.outputFormat(forBus: inputBus)
    inputNode.installTap(onBus: inputBus, bufferSize: 1024, format: recordingFormat){
      (buffer:AVAudioPCMBuffer,when:AVAudioTime) in
      self.request?.append(buffer)
    }
    // print out a message to the console
    print("started recording")
    // begin the recognition
    task = recognizer.recognitionTask(with: request){ result,error in
      if let result = result {
        let transcript = result.bestTranscription.formattedString
        print("Heard:\"\(transcript)\"")
        completion(transcript)
      }
      if error != nil || result?.isFinal == true {
        self.stopRecording()
        completion(nil)
      }
    }
  }
  func stopRecording(){
    print("...stopped recording")
    request?.endAudio()
    audioEngine.stop()
    inputNode.removeTap(onBus: 0)
    request = nil
    task = nil
  }
}
