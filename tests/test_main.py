import pytest
from fastapi.testclient import TestClient
from main import app, items_db

client = TestClient(app)


@pytest.fixture(autouse=True)
def clear_db():
    """Clear the database before each test"""
    items_db.clear()
    yield
    items_db.clear()


def test_read_root():
    """Test the root endpoint"""
    response = client.get("/")
    assert response.status_code == 200
    assert "message" in response.json()
    assert response.json()["message"] == "Welcome to the FastAPI application!"


def test_health_check():
    """Test the health check endpoint"""
    response = client.get("/health")
    assert response.status_code == 200
    assert response.json() == {"status": "healthy"}


def test_get_empty_items():
    """Test getting items when database is empty"""
    response = client.get("/items")
    assert response.status_code == 200
    assert response.json() == []


def test_create_item():
    """Test creating a new item"""
    item = {
        "name": "Test Item",
        "description": "A test item",
        "price": 10.99,
        "in_stock": True
    }
    response = client.post("/items", json=item)
    assert response.status_code == 201
    data = response.json()
    assert data["name"] == "Test Item"
    assert data["price"] == 10.99
    assert "id" in data


def test_get_items():
    """Test getting all items"""
    # Create some items
    client.post("/items", json={"name": "Item 1", "price": 10.0})
    client.post("/items", json={"name": "Item 2", "price": 20.0})
    
    response = client.get("/items")
    assert response.status_code == 200
    assert len(response.json()) == 2


def test_get_item_by_id():
    """Test getting a specific item by ID"""
    # Create an item
    create_response = client.post("/items", json={
        "name": "Specific Item",
        "price": 15.99
    })
    item_id = create_response.json()["id"]
    
    # Get the item
    response = client.get(f"/items/{item_id}")
    assert response.status_code == 200
    assert response.json()["name"] == "Specific Item"


def test_update_item():
    """Test updating an item"""
    # Create an item
    create_response = client.post("/items", json={
        "name": "Old Name",
        "price": 10.0
    })
    item_id = create_response.json()["id"]
    
    # Update the item
    updated_item = {
        "name": "New Name",
        "price": 20.0,
        "in_stock": False
    }
    response = client.put(f"/items/{item_id}", json=updated_item)
    assert response.status_code == 200
    assert response.json()["name"] == "New Name"
    assert response.json()["price"] == 20.0


def test_delete_item():
    """Test deleting an item"""
    # Create an item
    create_response = client.post("/items", json={
        "name": "To Delete",
        "price": 5.0
    })
    item_id = create_response.json()["id"]
    
    # Delete the item
    response = client.delete(f"/items/{item_id}")
    assert response.status_code == 200
    assert "deleted successfully" in response.json()["message"]
    
    # Verify it's gone
    get_response = client.get(f"/items/{item_id}")
    assert "error" in get_response.json()
