# Wheel of Year (WoY) Calendar

A beautiful interactive calendar application that visualizes different cyclical time systems in concentric rings. The application features a central wheel with multiple rings representing different time cycles (lunar phases, seasons, menstrual cycles, etc.) that can be rotated and explored.

![Wheel Calendar](frontend/assets/images/symbols/pentacle.svg)

## Project Overview

The Wheel of Year Calendar is a full-stack application with:

- **Frontend**: Flutter web application with an interactive wheel interface
- **Backend**: Django REST API that provides data for the rings, eras, and events

The application allows users to:
- Visualize different time cycles as concentric rings
- Rotate and explore different days within each cycle
- See how different cycles align with each other
- View detailed information about specific days

## Prerequisites

- [Flutter](https://flutter.dev/docs/get-started/install) (version 2.18+)
- [Python](https://www.python.org/downloads/) (version 3.8+)
- [Django](https://www.djangoproject.com/) (version 3.2+)
- [pip](https://pip.pypa.io/en/stable/installation/) (Python package manager)
- [Git](https://git-scm.com/downloads) (for cloning the repository)

## Setup Instructions

### Clone the Repository

```bash
git clone <repository-url>
cd woy
```

### Backend Setup

1. Create and activate a virtual environment:

```bash
# On macOS/Linux
python -m venv venv
source venv/bin/activate

# On Windows
python -m venv venv
venv\Scripts\activate
```

2. Install the required Python packages:

```bash
pip install -r requirements.txt
```

3. Initialize the database:

```bash
python manage.py migrate
```

4. Load initial data:

```bash
python manage.py load_rings_data
```

5. Create a superuser (optional, for admin access):

```bash
python manage.py createsuperuser
```

### Frontend Setup

1. Navigate to the frontend directory:

```bash
cd frontend
```

2. Install Flutter dependencies:

```bash
flutter pub get
```

## Running the Application

### One-Command Startup (Recommended)

We've included convenient scripts that start both the backend and frontend with a single command:

#### On macOS/Linux:

```bash
# From the project root directory
./run.sh
```

#### On Windows:

```bash
# From the project root directory
run.bat
```

This will:
- Start the Django backend server
- Launch the Flutter frontend in Chrome
- Handle proper shutdown of both servers when you exit

### Manual Startup

If you prefer to start the servers manually:

#### Start the Backend Server

```bash
# From the project root directory
# On macOS/Linux
source venv/bin/activate
# On Windows
venv\Scripts\activate

python manage.py runserver
```

The backend API will be available at http://localhost:8000/

#### Start the Frontend Application

```bash
# From the frontend directory
cd frontend
flutter run -d chrome
```

The frontend application will open in Chrome.

## API Endpoints

- `GET /api/rings/`: List all rings
- `GET /api/rings/{id}/`: Get details for a specific ring
- `GET /admin/`: Django admin interface (requires superuser)

## Project Structure

- `frontend/`: Flutter web application
  - `lib/`: Dart source code
  - `assets/`: Images and other static assets
- `woy/`: Django backend application
  - `models.py`: Database models
  - `views.py`: API views
  - `serializers.py`: REST API serializers
  - `management/commands/`: Custom management commands

## Development

### Adding New Rings

1. Add the ring data to the `load_rings_data.py` management command
2. Run `python manage.py load_rings_data` to update the database

### Customizing the Frontend

The main components of the wheel interface are:
- `lib/main.dart`: Main application and wheel calendar
- `lib/widgets/ring.dart`: Ring visualization
- `lib/widgets/central_circle.dart`: Central circle with pentacle

## License

[MIT License](LICENSE)

## Contributors

- Your Name
- Other Contributors

---

*Note: This project is for educational and personal use only.* 