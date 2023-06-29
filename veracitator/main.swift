//
//  main.swift
//  veracitator
//
//  Created by bill donner on 6/25/23.
//

//Step 3: Veracitator executes a script file from Prepper, sending each prompt to (another) Chatbot and generates a single output file of JSON data which is read by Blender."


import Darwin
import Foundation
import q20kshare
import ArgumentParser

let ChatGPTModel = "text-davinci-003"
let ChatGPTURLString = "https://api.openai.com/v1/completions"
//public  func getOpinion(_ xitem:String,source:String,originalID:String) throws -> Opinion?
func handleItem(ctx:ChatContext,item:String,jsonOut:FileHandle?) throws {
  let opinion = try getOpinion(item, source:ChatGPTModel)
  if let opinion = opinion {
    let encoder = JSONEncoder()
    encoder.outputFormatting = .prettyPrinted
    // 3. write JSON to file
    if let fileHandle = jsonOut  {
      // append response with prepended comma if we need one
      if !ctx.first {
        fileHandle.write(",".data(using: .utf8)!)
      } else {
        ctx.first  = false
      }
      // 4. encode Challenge as JSON and write that out
      let data = try encoder.encode(opinion)
      let str = String(data:data,encoding: .utf8)
      if let str = str {
        fileHandle.write(str.data(using: .utf8)!)
      }
    }
  }
}
struct Veracitator: ParsableCommand {
  
  static let configuration = CommandConfiguration(
    abstract: "Step 3: Veracitator executes a script file from Prepper, sending each prompt to (another) Chatbot and generates a single output file of JSON data which is read by Blender.",
    version: "0.2.13",
    subcommands: [],
    defaultSubcommand: nil,
    helpNames: [.long, .short]
  )
  
  @Argument(help: "Input text script file (Between_2_3.txt)")
  var input: String
  
  @Argument( help:"Output json file (Between_3_4.json)")
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
    print(">Veracitator is STEP3 running at \(Date())")
    
    let apiKey = try getAPIKey()
    
    print(">Veracitator Using apikey: " + apiKey)
    guard let apiurl = URL(string: ChatGPTURLString) else {
      fatalError("Invalid API URL")
    }
    guard let outURL = URL(string:output) else {
      fatalError("Invalid Output URL")
    }
    let ctx = ChatContext(max:max,apiKey:apiKey, apiURL: apiurl, outURL: outURL, model:ChatGPTModel, verbose:verbose, dots:dots,dontcall:dontcall,comments_pattern:comments_pattern,split_pattern:split_pattern, style:.promptor)
    
    guard let url = URL(string:input) else {  print ("bad url"); return  }
    let contents = try String(contentsOf: url)
    let templates = contents.split(separator: split_pattern)
      .map{$0.trimmingCharacters(in: .whitespacesAndNewlines)}
    if  verbose {
      print(">Prompts url: \(url)  (\(contents.count) bytes, \(templates.count) templates)")
      print(">Contacting: \(ChatGPTURLString)")
    }
    
    
    let jsonOutHandle = try prepOutputChannels(ctx:ctx)
    do {
      if let jsonOutHandle = jsonOutHandle {
        try pumpItUp(ctx:ctx,templates:templates, jsonOut: jsonOutHandle, cleaner: {s in
          [s.trimmingCharacters(in: .whitespacesAndNewlines)]
        },itemHandler: { x,y,z in
          try handleItem(ctx: x, item: y, jsonOut: z)
        })
      }
    }
    catch {
      if error as? PumpingErrors == PumpingErrors.reachedMaxLimit {
        print("\n>Veracitator reached max limit of \(ctx.max) prompts sent to the AI")
      }
      else {
        print ("Unknown error: \(error)")
      }
    }
    
    
    if ctx.pumpCount < ctx.max  {
      RunLoop.current.run() // suggested by fivestars blog
    }
    print(">Veracitator Exiting Normally - Pumped:\(ctx.pumpCount)" + " Bad Json: \( ctx.badJsonCount)" + " Network Issues: \(ctx.networkGlitches)\n")
  }// otherwise we should exit
}

Veracitator.main()

