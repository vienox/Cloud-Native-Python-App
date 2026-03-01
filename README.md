# Cloud Native Python App - FastAPI

Simple REST API built with FastAPI framework.

## Features

- ✅ CRUD operations for items
- ✅ Built-in API documentation (Swagger UI & ReDoc)
- ✅ Health check endpoint
- ✅ Pydantic data validation
- ✅ Async/await support

## Installation

1. Install dependencies:
```bash
pip install -r requirements.txt
```

## Running the Application

### Development Mode
```bash
uvicorn main:app --reload
```

### Production Mode
```bash
python main.py
```

The API will be available at `http://localhost:8000`

## API Documentation

Once the server is running, visit:
- Swagger UI: `http://localhost:8000/docs`
- ReDoc: `http://localhost:8000/redoc`

## API Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/` | Welcome message |
| GET | `/health` | Health check |
| GET | `/items` | Get all items |
| GET | `/items/{item_id}` | Get item by ID |
| POST | `/items` | Create new item |
| PUT | `/items/{item_id}` | Update item |
| DELETE | `/items/{item_id}` | Delete item |

## Example Usage

### Create an item:
```bash
curl -X POST "http://localhost:8000/items" \
  -H "Content-Type: application/json" \
  -d '{"name": "Laptop", "description": "Gaming laptop", "price": 1299.99, "in_stock": true}'
```

### Get all items:
```bash
curl http://localhost:8000/items
```

### Get specific item:
```bash
curl http://localhost:8000/items/1
```
