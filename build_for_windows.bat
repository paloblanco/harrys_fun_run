7z a -tzip game.zip *.lua resources
copy /b C:\src\lovr\lovr.exe+game.zip dist\game.exe
7z a -tzip game_win.zip dist\*