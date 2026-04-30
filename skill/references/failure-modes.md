# Failure Modes

## Mojibake on read

Symptom:
- a Chinese folder name appears as unreadable gibberish

Meaning:
- a UTF-8 file was decoded with GBK or CP936

Primary fix:
- re-read with explicit UTF-8

## Path destruction before execution

Symptom:
- a real path becomes `??`
- Python raises `OSError: [Errno 22] Invalid argument`

Meaning:
- the Unicode path was destroyed before the target process opened it

Primary fix:
- stop using piped inline scripts
- use a real script file plus arguments
- set a UTF-8 preamble before launching the native process
