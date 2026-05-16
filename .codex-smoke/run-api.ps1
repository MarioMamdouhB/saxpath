Set-Location 'C:\Users\Dell\Desktop\sax path\saxpath\services\api'
& py -3.12 -m uvicorn app.main:app --host 127.0.0.1 --port 8000 *>> 'C:\Users\Dell\Desktop\sax path\saxpath\.codex-smoke\api.log'
