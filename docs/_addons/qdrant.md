---
name: qdrant
title: Qdrant - Vector Database
description: High-performance vector database for AI applications
category: AI & Machine Learning
version: 1.0.14
architectures: 
  - amd64
  - aarch64
ports:
  - 6333
  - 6334
---

# Qdrant Vector Database App

High-performance vector database designed for AI applications, providing both REST and gRPC APIs for vector search and storage.

## Features

- 🚀 **High Performance**: Optimized for vector similarity search
- 🔍 **Semantic Search**: Build search engines that understand meaning
- 📊 **REST & gRPC APIs**: Flexible integration options
- 🎯 **Filtering Support**: Combine vector search with metadata filters
- 🌐 **Web UI**: Built-in dashboard for monitoring and management
- 💾 **Persistent Storage**: Data survives restarts and updates
- 🔒 **Optional Authentication**: API key protection available

## Use Cases

### 1. Semantic Search
Build search systems that understand context and meaning rather than just keywords.

### 2. Recommendation Systems
Create personalized recommendations based on user preferences and behavior patterns.

### 3. RAG Applications
Retrieval-Augmented Generation for enhancing LLM responses with relevant context.

### 4. Image Similarity Search
Find similar images based on visual features using image embeddings.

### 5. Anomaly Detection
Identify outliers in your data by finding vectors that are dissimilar to the norm.

## Installation

1. Add the J0rsa repository to your Home Assistant
2. Search for "Qdrant" in the App Store (formerly Add-on Store)
3. Click Install and wait for the download to complete
4. Configure the app (see Configuration below)
5. Start the app

## Configuration

```yaml
# Example configuration
web_ui_enabled: true           # Enable web dashboard
api_key: ""                    # Optional API key for authentication
read_only_api_key: ""          # Optional read-only API key
read_only: false               # Enable read-only mode
log_level: "INFO"              # Logging level
max_request_size_mb: 32        # Maximum request size in MB
```

### Configuration Options

| Option | Description | Default | Required |
|--------|-------------|---------|----------|
| `web_ui_enabled` | Enable the web dashboard interface | `true` | No |
| `api_key` | API key for full access (leave empty for no auth) | `""` | No |
| `read_only_api_key` | API key for read-only access | `""` | No |
| `read_only` | Enable read-only mode (prevents modifications) | `false` | No |
| `log_level` | Logging verbosity (TRACE/DEBUG/INFO/WARN/ERROR) | `INFO` | No |
| `max_request_size_mb` | Maximum request size in megabytes (1-1024) | `32` | No |

## Usage

### Accessing the Services

After starting the app, you can access:

- **REST API**: `http://homeassistant.local:6333`
- **gRPC API**: `homeassistant.local:6334`
- **Web Dashboard**: `http://homeassistant.local:6333/dashboard`

### API Examples

#### Create a Collection

Collections are the primary way to organize vectors in Qdrant:

```bash
curl -X PUT 'http://homeassistant.local:6333/collections/my_collection' \
  -H 'Content-Type: application/json' \
  -H 'api-key: your-api-key' \
  -d '{
    "vectors": {
      "size": 384,
      "distance": "Cosine"
    }
  }'
```

Distance metrics available:
- `Cosine` - Cosine similarity (recommended for normalized vectors)
- `Euclid` - Euclidean distance
- `Dot` - Dot product (for non-normalized vectors)

#### Insert Vectors

Add vectors with associated metadata:

```bash
curl -X PUT 'http://homeassistant.local:6333/collections/my_collection/points' \
  -H 'Content-Type: application/json' \
  -H 'api-key: your-api-key' \
  -d '{
    "points": [
      {
        "id": 1,
        "vector": [0.1, 0.2, 0.3, ...],
        "payload": {
          "text": "Example document",
          "category": "tutorial",
          "timestamp": 1700000000
        }
      }
    ]
  }'
```

#### Search for Similar Vectors

Find the most similar vectors:

```bash
curl -X POST 'http://homeassistant.local:6333/collections/my_collection/points/search' \
  -H 'Content-Type: application/json' \
  -H 'api-key: your-api-key' \
  -d '{
    "vector": [0.1, 0.2, 0.3, ...],
    "limit": 5,
    "filter": {
      "must": [
        {
          "key": "category",
          "match": {
            "value": "tutorial"
          }
        }
      ]
    }
  }'
```

#### List Collections

View all collections in your database:

```bash
curl -X GET 'http://homeassistant.local:6333/collections' \
  -H 'api-key: your-api-key'
```

## Integration with Home Assistant

### REST Sensor Example

Monitor collection statistics:

```yaml
sensor:
  - platform: rest
    name: "Qdrant Collection Count"
    resource: http://localhost:6333/collections
    method: GET
    headers:
      api-key: "your-api-key"
    value_template: "{{ value_json.result.collections | length }}"
    scan_interval: 300
```

### REST Command Example

Create a service to search vectors:

```yaml
rest_command:
  search_qdrant:
    url: "http://localhost:6333/collections/{{ collection }}/points/search"
    method: POST
    headers:
      Content-Type: "application/json"
      api-key: "your-api-key"
    payload: '{"vector": {{ vector }}, "limit": {{ limit | default(5) }}}'
```

## Python Integration Example

```python
from qdrant_client import QdrantClient
from qdrant_client.http.models import Distance, VectorParams, PointStruct

# Connect to Qdrant
client = QdrantClient(
    host="homeassistant.local",
    port=6333,
    api_key="your-api-key"
)

# Create collection
client.create_collection(
    collection_name="test_collection",
    vectors_config=VectorParams(size=384, distance=Distance.COSINE),
)

# Insert points
points = [
    PointStruct(
        id=1,
        vector=[0.1] * 384,
        payload={"text": "Hello world"}
    )
]
client.upsert(collection_name="test_collection", points=points)

# Search
search_result = client.search(
    collection_name="test_collection",
    query_vector=[0.1] * 384,
    limit=5
)
```

## Hardware Requirements

### Minimum Requirements
- **CPU**: 2 cores
- **RAM**: 2GB (more for larger datasets)
- **Storage**: 1GB + space for vectors

### Recommended for Production
- **CPU**: 4+ cores
- **RAM**: 8GB+
- **Storage**: SSD with sufficient space for your data

### Memory Guidelines by Dataset Size
- **10K vectors (384 dims)**: ~100MB RAM
- **100K vectors (384 dims)**: ~1GB RAM
- **1M vectors (384 dims)**: ~10GB RAM

## Performance Optimization

### 1. Index Configuration
- Use appropriate distance metrics for your use case
- Consider quantization for large datasets

### 2. Batch Operations
- Insert/update vectors in batches for better performance
- Use the `max_request_size_mb` setting appropriately

### 3. Filtering
- Create indexes on frequently filtered fields
- Use pre-filtering when possible

### 4. Memory Management
- Monitor RAM usage via the dashboard
- Consider mmap storage for very large collections

## Data Persistence

- **Storage Location**: `/config/qdrant/storage`
- **Backup**: Regular backups recommended for production
- **Snapshots**: Available via the API for point-in-time backups

### Creating a Snapshot

```bash
curl -X POST 'http://homeassistant.local:6333/collections/my_collection/snapshots' \
  -H 'api-key: your-api-key'
```

## Security Best Practices

1. **Always use API keys** in production environments
2. **Use read-only keys** for query-only applications
3. **Limit network exposure** - only expose ports if needed
4. **Regular backups** of your vector data
5. **Monitor logs** for unauthorized access attempts

## Troubleshooting

### App Won't Start
- Check logs for error messages
- Ensure ports 6333 and 6334 are not in use
- Verify sufficient disk space and RAM

### Connection Refused
- Ensure the app is running
- Check if API key is required but not provided
- Verify network connectivity

### Slow Performance
- Check RAM usage - Qdrant loads indexes into memory
- Consider optimizing vector dimensions
- Review batch sizes for bulk operations
- Enable quantization for large datasets

### Web UI Not Loading
- Ensure `web_ui_enabled` is set to `true`
- Clear browser cache
- Check console for JavaScript errors

## Advanced Features

### Quantization
Reduce memory usage with scalar quantization:

```json
{
  "vectors": {
    "size": 384,
    "distance": "Cosine"
  },
  "quantization_config": {
    "scalar": {
      "type": "int8",
      "quantile": 0.99,
      "always_ram": true
    }
  }
}
```

### Payload Indexing
Create indexes for faster filtering:

```bash
curl -X PUT 'http://homeassistant.local:6333/collections/my_collection/index' \
  -H 'Content-Type: application/json' \
  -H 'api-key: your-api-key' \
  -d '{
    "field_name": "category",
    "field_schema": "keyword"
  }'
```

## Support

- [GitHub Issues](https://github.com/j0rsa/home-assistant-addons/issues)
- [Qdrant Documentation](https://qdrant.tech/documentation/)
- [Qdrant API Reference](https://api.qdrant.tech/)
- [Community Forum](https://community.home-assistant.io/)

---

[← Back to Apps](/addons/) | [View on GitHub](https://github.com/j0rsa/home-assistant-addons/tree/main/qdrant)