Set-Location 'C:\Users\Dell\Desktop\sax path\saxpath\services\audio-engine'
& py -3.12 -m uvicorn app.main:app --host 127.0.0.1 --port 8010 *>> 'C:\Users\Dell\Desktop\sax path\saxpath\.codex-smoke\audio-engine.log'
