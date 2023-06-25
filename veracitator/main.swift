//
//  main.swift
//  veracitator
//
//  Created by bill donner on 6/25/23.
//

 

import Darwin
import Foundation
import q20kshare


let ChatGPTModel = "text-davinci-003"
let ChatGPTURLString = "https://api.openai.com/v1/completions"
 

import ArgumentParser
struct Veracitator: ParsableCommand {
 
  static let configuration = CommandConfiguration(
    abstract: "Step 3: Veracitator executes a script file from Prepper, sending each prompt to (another) Chatbot and generates a single output file of JSON data which is read by Blender.",
    version: "0.1.6",
    subcommands: [],
    defaultSubcommand: nil,
    helpNames: [.long, .short]
  )

  @Argument(help: "Input text script file (Between_2_3.txt):")
  var input: String
  
  @Argument( help:"Output json file (Between_3_4.json):")
  var output: String

  
  @Option(name: .long, help: "How many prompts to execute")
  var max: Int = 65535
  
  @Option(name: .long, help: "Print dots whilst awaiting AI")
  var dots: Bool = false
  
  @Option(name: .long, help: "Print a lot more")
  var verbose: Bool = false
  
  @Option(name: .long , help: "Generate Unique File Names")
  var unique : Bool = true
  
  @Option(name: .long, help: "Don't call AI")
  var dontcall: Bool = false
  
  @Option(name:.long,help: "The pattern to use to split the file")
  var split_pattern: String = "***"
  
  @Option(name:.long,help: "The pattern to use to indicate a comments line")
  var comments_pattern: String = "///"
  

    func run() throws {
      print(">Veracitator Command Line: \(CommandLine.arguments)")
      print(">Veracitator running at \(Date())")
      
      let  looky = ProcessInfo.processInfo.environment["OPENAI_API_KEY"]
      guard let looky=looky  else { throw PumpingErrors.noAPIKey }
    
      print(">Veracitator Using apikey: " + looky)
      guard let apiurl = URL(string: ChatGPTURLString) else {
        fatalError("Invalid API URL")
      }
      guard let outURL = URL(string:output) else {
        fatalError("Invalid Output URL")
      }
      let ctx = ChatContext(apiKey: looky, apiURL: apiurl, outURL: outURL, model:ChatGPTModel, verbose:verbose, dots:dots,dontcall:dontcall,comments_pattern:comments_pattern,split_pattern:split_pattern, style:.promptor)
 
      guard let url = URL(string:input) else {  print ("bad url"); return  }
      let contents = try String(contentsOf: url)
      let templates = contents.split(separator: split_pattern)
                   .map{$0.trimmingCharacters(in: .whitespacesAndNewlines)}
      if  verbose {
        print(">Prompts url: \(url)  (\(contents.count) bytes, \(templates.count) templates)")
        print(">Contacting: \(ChatGPTURLString)")
      }
     
      try pumpItUp(ctx:ctx,templates:templates) // end pumpcount<=max
      
      if ctx.pumpCount < ctx.max  {
        RunLoop.current.run() // suggested by fivestars blog
      }
      print(">Veracitator Exiting Normally - Pumped:\(ctx.pumpCount)" + " Bad Json: \( ctx.badJsonCount)" + " Network Issues: \(ctx.networkGlitches)\n")
    }// otherwise we should exit
  }
  

  
Veracitator.main()

