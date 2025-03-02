#!/bin/bash

# Function to handle cleanup on exit
cleanup() {
    echo "Shutting down servers..."
    kill $BACKEND_PID $FRONTEND_PID 2>/dev/null
    exit 0
}

# Set up trap to catch Ctrl+C and other termination signals
trap cleanup SIGINT SIGTERM

# Start the backend server
echo "Starting Django backend server..."
source venv/bin/activate
python manage.py runserver &
BACKEND_PID=$!
echo "Backend server running with PID: $BACKEND_PID"

# Wait a moment for the backend to initialize
sleep 2

# Start the frontend server
echo "Starting Flutter frontend..."
cd frontend
flutter run -d chrome &
FRONTEND_PID=$!
echo "Frontend running with PID: $FRONTEND_PID"

echo "Both servers are now running!"
echo "Press Ctrl+C to stop both servers."

# Wait for both processes
wait $BACKEND_PID $FRONTEND_PID 