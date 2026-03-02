# API Usage Examples

## Base URL
```
Local: http://localhost:8000
Production: http://YOUR_SERVER_IP:30080
```

## 1. Health Check

```bash
curl http://localhost:8000/health
```

**Response:**
```json
{
  "status": "healthy"
}
```

## 2. Welcome Message

```bash
curl http://localhost:8000/
```

**Response:**
```json
{
  "message": "Welcome to the FastAPI application!",
  "docs": "/docs",
  "redoc": "/redoc"
}
```

## 3. Create Item

```bash
curl -X POST http://localhost:8000/items \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Laptop Dell XPS 15",
    "description": "High-performance laptop for developers",
    "price": 1499.99,
    "in_stock": true
  }'
```

**Response:**
```json
{
  "id": 1,
  "name": "Laptop Dell XPS 15",
  "description": "High-performance laptop for developers",
  "price": 1499.99,
  "in_stock": true
}
```

## 4. Get All Items

```bash
curl http://localhost:8000/items
```

**Response:**
```json
[
  {
    "id": 1,
    "name": "Laptop Dell XPS 15",
    "description": "High-performance laptop for developers",
    "price": 1499.99,
    "in_stock": true
  },
  {
    "id": 2,
    "name": "Wireless Mouse",
    "description": "Ergonomic wireless mouse",
    "price": 29.99,
    "in_stock": true
  }
]
```

## 5. Get Item by ID

```bash
curl http://localhost:8000/items/1
```

**Response:**
```json
{
  "id": 1,
  "name": "Laptop Dell XPS 15",
  "description": "High-performance laptop for developers",
  "price": 1499.99,
  "in_stock": true
}
```

## 6. Update Item

```bash
curl -X PUT http://localhost:8000/items/1 \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Laptop Dell XPS 15 (Updated)",
    "description": "High-performance laptop for developers - Now with more RAM!",
    "price": 1599.99,
    "in_stock": true
  }'
```

**Response:**
```json
{
  "id": 1,
  "name": "Laptop Dell XPS 15 (Updated)",
  "description": "High-performance laptop for developers - Now with more RAM!",
  "price": 1599.99,
  "in_stock": true
}
```

## 7. Delete Item

```bash
curl -X DELETE http://localhost:8000/items/1
```

**Response:**
```json
{
  "message": "Item 1 deleted successfully"
}
```

## PowerShell Examples (Windows)

### Create Item
```powershell
$body = @{
    name = "MacBook Pro"
    description = "Apple laptop"
    price = 2499.99
    in_stock = $true
} | ConvertTo-Json

Invoke-RestMethod -Uri "http://localhost:8000/items" -Method Post -Body $body -ContentType "application/json"
```

### Get All Items
```powershell
Invoke-RestMethod -Uri "http://localhost:8000/items" -Method Get
```

### Update Item
```powershell
$updateBody = @{
    name = "MacBook Pro M3"
    description = "Latest Apple laptop with M3 chip"
    price = 2799.99
    in_stock = $true
} | ConvertTo-Json

Invoke-RestMethod -Uri "http://localhost:8000/items/1" -Method Put -Body $updateBody -ContentType "application/json"
```

### Delete Item
```powershell
Invoke-RestMethod -Uri "http://localhost:8000/items/1" -Method Delete
```

## Python Requests Examples

```python
import requests

BASE_URL = "http://localhost:8000"

# Create item
response = requests.post(
    f"{BASE_URL}/items",
    json={
        "name": "Python Book",
        "description": "Learn Python in 30 days",
        "price": 39.99,
        "in_stock": True
    }
)
print(response.json())

# Get all items
response = requests.get(f"{BASE_URL}/items")
print(response.json())

# Get specific item
response = requests.get(f"{BASE_URL}/items/1")
print(response.json())

# Update item
response = requests.put(
    f"{BASE_URL}/items/1",
    json={
        "name": "Python Book - Second Edition",
        "description": "Learn Python in 30 days - Updated for Python 3.12",
        "price": 44.99,
        "in_stock": True
    }
)
print(response.json())

# Delete item
response = requests.delete(f"{BASE_URL}/items/1")
print(response.json())
```

## JavaScript/Fetch Examples

```javascript
const BASE_URL = 'http://localhost:8000';

// Create item
fetch(`${BASE_URL}/items`, {
  method: 'POST',
  headers: {
    'Content-Type': 'application/json',
  },
  body: JSON.stringify({
    name: 'JavaScript Course',
    description: 'Complete JavaScript course',
    price: 49.99,
    in_stock: true
  })
})
.then(response => response.json())
.then(data => console.log(data));

// Get all items
fetch(`${BASE_URL}/items`)
  .then(response => response.json())
  .then(data => console.log(data));

// Get specific item
fetch(`${BASE_URL}/items/1`)
  .then(response => response.json())
  .then(data => console.log(data));

// Update item
fetch(`${BASE_URL}/items/1`, {
  method: 'PUT',
  headers: {
    'Content-Type': 'application/json',
  },
  body: JSON.stringify({
    name: 'JavaScript Course - Advanced',
    description: 'Complete JavaScript course with ES2024',
    price: 59.99,
    in_stock: true
  })
})
.then(response => response.json())
.then(data => console.log(data));

// Delete item
fetch(`${BASE_URL}/items/1`, {
  method: 'DELETE'
})
.then(response => response.json())
.then(data => console.log(data));
```

## Testing with HTTPie

```bash
# Install: pip install httpie

# Create item
http POST http://localhost:8000/items \
  name="Mechanical Keyboard" \
  description="RGB Gaming Keyboard" \
  price=89.99 \
  in_stock:=true

# Get all items
http GET http://localhost:8000/items

# Get specific item
http GET http://localhost:8000/items/1

# Update item
http PUT http://localhost:8000/items/1 \
  name="Mechanical Keyboard Pro" \
  description="RGB Gaming Keyboard with Cherry MX switches" \
  price=129.99 \
  in_stock:=true

# Delete item
http DELETE http://localhost:8000/items/1
```

## Bulk Operations Script

```bash
#!/bin/bash
# bulk-create.sh - Create multiple items

BASE_URL="http://localhost:8000"

# Array of items
items=(
  '{"name":"Laptop","description":"Dell XPS 15","price":1499.99,"in_stock":true}'
  '{"name":"Mouse","description":"Logitech MX Master 3","price":99.99,"in_stock":true}'
  '{"name":"Keyboard","description":"Keychron K8","price":79.99,"in_stock":true}'
  '{"name":"Monitor","description":"Dell 27 4K","price":399.99,"in_stock":true}'
  '{"name":"Webcam","description":"Logitech C920","price":69.99,"in_stock":false}'
)

# Create each item
for item in "${items[@]}"; do
  echo "Creating: $item"
  curl -X POST "$BASE_URL/items" \
    -H "Content-Type: application/json" \
    -d "$item"
  echo ""
done

# Get all items
echo "All items:"
curl "$BASE_URL/items" | python -m json.tool
```

## Load Testing with Apache Bench

```bash
# Install Apache Bench (ab)
# Ubuntu: sudo apt-get install apache2-utils
# macOS: brew install ab

# Simple load test - 1000 requests, 10 concurrent
ab -n 1000 -c 10 http://localhost:8000/health

# POST test with file
echo '{"name":"Test","price":10.0,"in_stock":true}' > /tmp/item.json
ab -n 100 -c 10 -p /tmp/item.json -T application/json http://localhost:8000/items
```

## Monitoring Endpoints

```bash
# Check API metrics (if implemented)
curl http://localhost:8000/metrics

# OpenAPI specification
curl http://localhost:8000/openapi.json | python -m json.tool
```
