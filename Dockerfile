# Base Python image
FROM python:3.12-slim

# Define the application directory
ARG APP_HOME=/app
WORKDIR ${APP_HOME}

# Set environment variables
ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1
ENV PYTHONPATH=${APP_HOME}

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    build-essential \
    libpq-dev \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Install Node.js and Yarn
RUN curl -fsSL https://deb.nodesource.com/setup_18.x | bash - && \
    apt-get update && apt-get install -y nodejs && \
    npm install -g yarn

# Install Python dependencies
COPY requirements.txt ${APP_HOME}/
RUN pip install --upgrade pip && pip install --no-cache-dir -r requirements.txt

# Copy project files
COPY . ${APP_HOME}

# Prepare static files and migrations
RUN python manage.py collectstatic --noinput
RUN python manage.py migrate --noinput

# Build frontend
WORKDIR ${APP_HOME}/src
RUN yarn install && yarn build

# Expose the application port
EXPOSE 8000

# Command to run the application
WORKDIR ${APP_HOME}
CMD ["gunicorn", "--bind", "0.0.0.0:8000", "--config", "gunicorn-cfg.py", "config.wsgi"]
