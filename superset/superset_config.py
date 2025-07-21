import os
import logging

# Redis Configuration
REDIS_HOST = os.getenv("REDIS_HOST", "redis")
REDIS_PORT = os.getenv("REDIS_PORT", 6379)

# Cache Configuration
CACHE_CONFIG = {
    'CACHE_TYPE': 'RedisCache',
    'CACHE_DEFAULT_TIMEOUT': 300,
    'CACHE_KEY_PREFIX': 'superset_',
    'CACHE_REDIS_HOST': REDIS_HOST,
    'CACHE_REDIS_PORT': REDIS_PORT,
}

# Database Configuration
DATABASE_DIALECT = 'postgresql'
DATABASE_USER = os.getenv("DATABASE_USER", "superset")
DATABASE_PASSWORD = os.getenv("DATABASE_PASSWORD", "superset")
DATABASE_HOST = os.getenv("DATABASE_HOST", "postgres-superset")
DATABASE_PORT = os.getenv("DATABASE_PORT", "5432")
DATABASE_DB = os.getenv("DATABASE_DB", "superset")

# The SQLAlchemy connection string
SQLALCHEMY_DATABASE_URI = f"{DATABASE_DIALECT}://{DATABASE_USER}:{DATABASE_PASSWORD}@{DATABASE_HOST}:{DATABASE_PORT}/{DATABASE_DB}"

# Security
SECRET_KEY = os.getenv("SUPERSET_SECRET_KEY", "your-secret-key-change-this-in-production")
WTF_CSRF_ENABLED = True
WTF_CSRF_TIME_LIMIT = None

# Feature flags
FEATURE_FLAGS = {
    "ENABLE_TEMPLATE_PROCESSING": True,
    "DASHBOARD_NATIVE_FILTERS": True,
    "DASHBOARD_CROSS_FILTERS": True,
    "DASHBOARD_NATIVE_FILTERS_SET": True,
    "ENABLE_ADVANCED_DATA_TYPES": True,
}

# Enable embedding
ENABLE_PROXY_FIX = True
TALISMAN_ENABLED = False

# Additional configuration
ENABLE_CORS = True
CORS_OPTIONS = {
    'supports_credentials': True,
    'allow_headers': ['*'],
    'resources': ['*'],
    'origins': ['*']
}

# Webserver Configuration
WEBSERVER_THREADS = 8
WEBSERVER_TIMEOUT = 60

# SQL Lab Configuration
SQLLAB_TIMEOUT = 300
SQLLAB_ASYNC_TIME_LIMIT_SEC = 600

# Email Configuration (optional)
SMTP_HOST = "localhost"
SMTP_STARTTLS = True
SMTP_SSL = False
SMTP_USER = "superset"
SMTP_PORT = 25
SMTP_PASSWORD = ""
SMTP_MAIL_FROM = "superset@superset.com"

# Logging
logging.basicConfig(level=logging.INFO)
