AGENT RULES — Insight Engine Flutter App
Build Protocol

Build ONE module at a time. Never start the next module until explicitly told "GO".
After completing a module, run all automated tests for that module before reporting to Moeez.
After automated tests pass, report results and then give manual testing instructions.
Wait for green light ("GO") before proceeding.
After green light, mark the completed module as done in MOEEZ_Antigravity_Prompt.md by checking its checkbox (- [ ] → - [x]) if applicable.

Testing Protocol (per module)

Automated first: write and run unit/widget tests, check for errors, fix any failures
Then report: tell Moeez exactly what was tested, what passed, what to watch for
Manual testing: give clear step-by-step instructions Moeez can follow on device/emulator
Never mark a module done until Moeez gives green light

Code Standards

Follow the exact file structure defined in MOEEZ_Antigravity_Prompt.md
Do not rename files, screens, or classes
Use the exact dependencies from pubspec.yaml in the prompt
All placeholders in config.dart remain as-is until Moeez provides real credentials
