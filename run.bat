@echo off
echo Starting Wheel of Year Calendar...

REM Start the backend server
echo Starting Django backend server...
start cmd /k "call venv\Scripts\activate.bat && python manage.py runserver"

REM Wait a moment for the backend to initialize
timeout /t 3 /nobreak > nul

REM Start the frontend server
echo Starting Flutter frontend...
start cmd /k "cd frontend && flutter run -d chrome"

echo Both servers are now running!
echo Close the command windows to stop the servers. 