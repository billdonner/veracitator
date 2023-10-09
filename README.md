# VERACITATOR - Read a veracity script and Pump thru ChatGPT

Freeport.Software - 0.3.1
```
OVERVIEW: Step 3: Veracitator executes a script file from Prepper, sending each
prompt to (another) Chatbot and generates a single output file of JSON data
which is read by Blender.

USAGE: veracitator <input> <output> [--max <max>] [--dots <dots>] [--verbose <verbose>] [--unique <unique>] [--dontcall <dontcall>] [--split_pattern <split_pattern>] [--comments_pattern <comments_pattern>]

ARGUMENTS:
  <input>                 Input text script file (Between_2_3.txt):
  <output>                Output json file (Between_3_4.json):

OPTIONS:
  --max <max>             How many prompts to execute (default: 65535)
  --dots <dots>           Print dots whilst awaiting AI (default: false)
  --verbose <verbose>     Print a lot more (default: false)
  --unique <unique>       Generate Unique File Names (default: true)
  --dontcall <dontcall>   Don't call AI (default: false)
  --split_pattern <split_pattern>
                          The pattern to use to split the file (default: ***)
  --comments_pattern <comments_pattern>
                          The pattern to use to indicate a comments line
                          (default: ///)
  --version               Show the version.
  -h, --help              Show help information.
  ```

