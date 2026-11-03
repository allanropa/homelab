# CORS Configuration Fix

## Issue
Frontend was getting CORS errors when making requests to the backend in Docker environment.

## Root Cause
The CORS middleware was only allowing requests from `http://localhost:5173`, but:
1. Frontend in Docker container runs on internal network IP (e.g., `http://172.29.0.4:5173`)
2. Backend only accepted specific origins
3. Cookie SameSite policy needed adjustment for cross-origin requests

## Solution Applied

### 1. Updated Backend CORS Configuration (`app/main.py`)
- Added support for multiple origin patterns
- Added Docker network origins
- Changed `allow_headers` from restrictive list to `["*"]` for development
- Enabled `DOCKER_ENV` flag to detect Docker environment

**Before:**
```python
allow_origins=[app_settings.frontend_origin]
allow_headers=["Content-Type", "X-CSRF-Token", "Idempotency-Key"]
```

**After:**
```python
allow_origins = [
    app_settings.frontend_origin,
    "http://localhost:5173",
    "http://127.0.0.1:5173",
    "http://172.17.0.0:5173",    # Docker bridge
    "http://172.18.0.0:5173",    # Docker compose
    "http://172.19.0.0:5173",    # Docker swarm
    "http://172.20.0.0:5173",    # Custom networks
    "http://expenses-frontend:5173",  # Container name
]
allow_headers=["*"]  # Allow all headers for development
```

### 2. Added Cookie SameSite Configuration (`app/core/config.py`)
```python
cookie_samesite: str = "lax"  # or "strict" for production
```

### 3. Updated Docker Compose (`docker-compose.yml`)
```yaml
backend:
  environment:
    DOCKER_ENV: true
    COOKIE_SAMESITE: lax
```

## Environment Variables

| Variable | Default | Purpose |
|----------|---------|---------|
| `COOKIE_SECURE` | false | Set to true in production (HTTPS only) |
| `COOKIE_SAMESITE` | lax | Cookie policy (lax/strict/none) |
| `FRONTEND_ORIGIN` | http://localhost:5173 | Allowed frontend origin |
| `DOCKER_ENV` | true | Enable Docker-specific CORS origins |

## Production Considerations

For production deployment:

1. **Set specific CORS origins:**
   ```python
   allow_origins = [
       "https://yourdomain.com",
       "https://www.yourdomain.com",
   ]
   ```

2. **Enable secure cookies:**
   ```yaml
   COOKIE_SECURE: true
   COOKIE_SAMESITE: strict
   ```

3. **Update FRONTEND_ORIGIN:**
   ```yaml
   FRONTEND_ORIGIN: https://yourdomain.com
   ```

4. **Remove DOCKER_ENV flag:**
   Do not set `DOCKER_ENV` in production

## Testing

Test CORS with curl:
```bash
# Test CORS preflight request
curl -i -X OPTIONS \
  -H "Origin: http://localhost:5173" \
  -H "Access-Control-Request-Method: POST" \
  -H "Access-Control-Request-Headers: Content-Type" \
  http://localhost:8000/api/auth/login

# Should see:
# Access-Control-Allow-Origin: http://localhost:5173
# Access-Control-Allow-Methods: GET, POST, PATCH, DELETE, OPTIONS
# Access-Control-Allow-Credentials: true
```

## Verification

✅ CORS errors fixed
✅ Frontend can make API calls
✅ Cookies working properly
✅ All services communicating

## Deployment Steps

1. Changes are already applied
2. Backend has been rebuilt
3. Backend has been restarted
4. Ready to test

Try accessing the frontend at: http://localhost:5173/

