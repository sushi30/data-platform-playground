FROM python:3.11-slim

# Set working directory
WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Copy requirements first to leverage Docker layer caching
COPY requirements.txt .

# Install Python dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Install dbt-postgres adapter
RUN pip install dbt-postgres

# Copy dbt project files
COPY . .

# Create profiles directory and set up basic profile
RUN mkdir -p ~/.dbt

# Set environment variables
ENV DBT_PROFILES_DIR=/app/profiles

# Create profiles directory in the app
RUN mkdir -p /app/profiles

# Install dbt dependencies
RUN dbt deps

# Default command
CMD ["dbt", "--version"]
