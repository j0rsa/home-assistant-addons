# Qdrant App

![](logo.png)

High-performance vector database for AI applications with REST and gRPC APIs.

![Supports aarch64 Architecture][aarch64-shield]
![Supports amd64 Architecture][amd64-shield]

## About

This app runs Qdrant, a high-performance vector database designed for AI applications. It provides both REST and gRPC APIs for vector search and storage, making it ideal for:

- **Semantic Search**: Build search engines that understand meaning
- **Recommendation Systems**: Create personalized recommendations
- **RAG Applications**: Retrieval-Augmented Generation for LLMs
- **AI Embeddings Storage**: Store and query vector embeddings

## Configuration

The app provides a minimal configuration for quick setup with optional security and performance tuning.

### Option: `api_key`

Optional API key for authentication. If not provided, the database will run without authentication (not recommended for production).

### Option: `read_only`

Enable read-only mode to prevent data modifications. Default: `false`

### Option: `log_level`

Set the log level for Qdrant. Available options:
- `TRACE` - Most verbose logging
- `DEBUG` - Debug information
- `INFO` - Information messages (default)
- `WARN` - Warning messages
- `ERROR` - Error messages only

### Option: `max_request_size_mb`

Maximum request size in megabytes. Default: `32` MB. Range: 1-1024 MB.

## Example Configuration

### Basic setup without authentication:
```yaml
log_level: INFO
max_request_size_mb: 32
read_only: false
```

### Production setup with authentication:
```yaml
api_key: "your-secure-api-key-here"
log_level: WARN
max_request_size_mb: 64
read_only: false
```

### Read-only setup for query-only applications:
```yaml
api_key: "your-api-key"
read_only: true
log_level: INFO
max_request_size_mb: 16
```

## Usage

1. Configure your Qdrant settings in the app configuration
2. Start the app
3. Access the APIs:
   - **REST API**: `http://homeassistant-ip:6333`
   - **gRPC API**: `homeassistant-ip:6334`
   - **Web UI**: `http://homeassistant-ip:6333/dashboard`

## API Examples

### Create a collection (REST API):
```bash
curl -X PUT 'http://homeassistant-ip:6333/collections/my_collection' \
  -H 'Content-Type: application/json' \
  -H 'api-key: your-api-key' \
  -d '{
    "vectors": {
      "size": 384,
      "distance": "Cosine"
    }
  }'
```

### Insert vectors:
```bash
curl -X PUT 'http://homeassistant-ip:6333/collections/my_collection/points' \
  -H 'Content-Type: application/json' \
  -H 'api-key: your-api-key' \
  -d '{
    "points": [
      {
        "id": 1,
        "vector": [0.1, 0.2, 0.3, ...],
        "payload": {"text": "example document"}
      }
    ]
  }'
```

### Search for similar vectors:
```bash
curl -X POST 'http://homeassistant-ip:6333/collections/my_collection/points/search' \
  -H 'Content-Type: application/json' \
  -H 'api-key: your-api-key' \
  -d '{
    "vector": [0.1, 0.2, 0.3, ...],
    "limit": 5
  }'
```

## Data Persistence

All vector data and collections are stored in the `/config/storage` directory, which is automatically created and persisted across container restarts.

## Performance Notes

- **Memory Usage**: Qdrant loads indexes into memory for optimal performance
- **Storage**: Uses efficient binary format for vector storage
- **Scaling**: Single-node setup; for clustering, consider external Qdrant deployment
- **Request Size**: Adjust `max_request_size_mb` based on your batch sizes

## Security

- **API Key**: Always set an API key for production deployments
- **Read-Only Mode**: Use for applications that only need to query existing data
- **Network**: The app binds to all interfaces (0.0.0.0) for Home Assistant integration

## Support

For issues and feature requests, please visit the [GitHub repository](https://github.com/j0rsa/home-assistant-apps).

For Qdrant-specific documentation, see the [official Qdrant docs](https://qdrant.tech/documentation/).

[aarch64-shield]: https://img.shields.io/badge/aarch64-yes-green.svg
[amd64-shield]: https://img.shields.io/badge/amd64-yes-green.svg
[armv7-shield]: https://img.shields.io/badge/armv7-yes-green.svg